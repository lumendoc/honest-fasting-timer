import WidgetKit
import SwiftUI

struct FastingEntry: TimelineEntry {
    let date: Date
    let endDate: Date?
    let isActive: Bool

    var isComplete: Bool {
        guard let endDate = endDate else { return false }
        return date >= endDate
    }

    var timeRemaining: TimeInterval {
        guard let endDate = endDate else { return 0 }
        return max(0, endDate.timeIntervalSince(date))
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FastingEntry {
        FastingEntry(date: Date(), endDate: Date().addingTimeInterval(3600), isActive: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (FastingEntry) -> Void) {
        let entry = FastingEntry(date: Date(), endDate: Date().addingTimeInterval(3600), isActive: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FastingEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.lumen.honestfastingtimer")
        var endDate: Date? = nil
        var isActive = false

        if let data = defaults?.data(forKey: "activeFast"),
           let fast = try? JSONDecoder().decode(ActiveFastData.self, from: data) {
            endDate = fast.endDate
            isActive = true
        }

        let entry = FastingEntry(date: Date(), endDate: endDate, isActive: isActive)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
        completion(timeline)
    }
}

private struct ActiveFastData: Codable {
    let endDate: Date
}

struct HonestFastingWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if entry.isActive {
                Text("Fast in progress")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if entry.isComplete {
                    Text("Complete!")
                        .font(.headline)
                        .foregroundStyle(.green)
                } else {
                    Text(timerString(from: entry.timeRemaining))
                        .font(.system(.title2, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
            } else {
                Text("No active fast")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func timerString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

@main
struct HonestFastingTimerWidget: Widget {
    let kind: String = "HonestFastingTimer"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HonestFastingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Honest Fasting")
        .description("Shows your current fasting timer.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}