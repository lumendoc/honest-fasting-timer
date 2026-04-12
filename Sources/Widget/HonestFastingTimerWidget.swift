import WidgetKit
import SwiftUI

struct FastingEntry: TimelineEntry {
    let date: Date
    let activeFast: ActiveFast?
    
    var isActive: Bool {
        activeFast != nil && !(activeFast?.isComplete ?? true)
    }
    
    var isComplete: Bool {
        guard let fast = activeFast else { return false }
        return fast.isComplete
    }
    
    var endDate: Date? {
        activeFast?.endDate
    }
    
    var presetName: String {
        activeFast?.presetName ?? ""
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FastingEntry {
        let fast = ActiveFast(
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            presetName: "16:8",
            presetDuration: 16 * 60 * 60
        )
        return FastingEntry(date: Date(), activeFast: fast)
    }

    func getSnapshot(in context: Context, completion: @escaping (FastingEntry) -> Void) {
        let entry = loadCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FastingEntry>) -> Void) {
        let currentEntry = loadCurrentEntry()
        var entries: [FastingEntry] = [currentEntry]
        
        // If there's an active fast, add entries for the next hour at 1-minute intervals
        // This ensures the widget updates regularly while staying battery-efficient
        if let fast = currentEntry.activeFast, !fast.isComplete {
            let updateInterval: TimeInterval = 60 // Update every minute
            let maxTimelineDuration: TimeInterval = 60 * 60 // 1 hour ahead
            
            var nextDate = Date().addingTimeInterval(updateInterval)
            let endDate = fast.endDate
            
            while nextDate.timeIntervalSinceNow < maxTimelineDuration && nextDate < endDate {
                // Create a new fast with the same data but we'll recalculate at render time
                let entry = FastingEntry(date: nextDate, activeFast: fast)
                entries.append(entry)
                nextDate = nextDate.addingTimeInterval(updateInterval)
            }
            
            // Add final entry at completion time
            if endDate > Date() && !entries.contains(where: { $0.date >= endDate }) {
                let finalEntry = FastingEntry(date: endDate, activeFast: fast)
                entries.append(finalEntry)
            }
        }
        
        // Request next timeline update in 15 minutes or at fast completion
        let nextUpdateDate: Date
        if let fast = currentEntry.activeFast, !fast.isComplete {
            // Update sooner if fast completes within 15 minutes
            let fifteenMinutes = Date().addingTimeInterval(15 * 60)
            nextUpdateDate = min(fast.endDate, fifteenMinutes)
        } else {
            nextUpdateDate = Date().addingTimeInterval(15 * 60)
        }
        
        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    private func loadCurrentEntry() -> FastingEntry {
        let defaults = UserDefaults(suiteName: "group.com.lumen.honestfastingtimer")
        
        if let data = defaults?.data(forKey: "activeFast"),
           let fast = try? JSONDecoder().decode(ActiveFast.self, from: data) {
            return FastingEntry(date: Date(), activeFast: fast)
        }
        
        return FastingEntry(date: Date(), activeFast: nil)
    }
}

struct HonestFastingWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallWidgetView
            case .systemMedium:
                mediumWidgetView
            default:
                smallWidgetView
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private var smallWidgetView: some View {
        VStack(alignment: .center, spacing: 4) {
            if entry.isActive {
                Text(entry.presetName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                if entry.isComplete {
                    Text("Complete!")
                        .font(.headline)
                        .foregroundStyle(.green)
                } else if let endDate = entry.endDate {
                    // Use timerInterval for live countdown - battery efficient, no timeline reloads needed
                    Text(endDate, style: .timer)
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.8)
                }
            } else if entry.activeFast?.isComplete == true {
                VStack(spacing: 2) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    Text("Fast Complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack(spacing: 2) {
                    Image(systemName: "moon.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No Active Fast")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
    
    private var mediumWidgetView: some View {
        HStack(spacing: 16) {
            // Left side: Icon or status
            VStack {
                if entry.isActive {
                    if entry.isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.green)
                    } else {
                        ProgressRing(progress: entry.activeFast?.progress ?? 0)
                            .frame(width: 60, height: 60)
                    }
                } else if entry.activeFast?.isComplete == true {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 70)
            
            // Right side: Details
            VStack(alignment: .leading, spacing: 4) {
                if entry.isActive {
                    Text(entry.presetName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if entry.isComplete {
                        Text("Fast Complete!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    } else if let endDate = entry.endDate {
                        Text(endDate, style: .timer)
                            .font(.system(.title, design: .monospaced))
                            .fontWeight(.bold)
                    }
                    
                    if !entry.isComplete, let fast = entry.activeFast {
                        Text("\(Int(fast.progress * 100))% complete")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else if entry.activeFast?.isComplete == true {
                    Text("Fast Complete!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    Text("Great job!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No Active Fast")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text("Tap to start fasting")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [.accentColor, .green],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

@main
struct HonestFastingTimerWidget: Widget {
    let kind: String = "HonestFastingTimer"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HonestFastingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Fasting Timer")
        .description("Shows your current fasting timer and progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}