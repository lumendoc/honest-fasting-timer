import SwiftUI
import SwiftData

struct HistoryView: View {
    @StateObject private var purchaseService = PurchaseService.shared
    @Query(sort: \CompletedFast.startDate, order: .reverse) private var completedFasts: [CompletedFast]
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            Group {
                if purchaseService.isUnlocked {
                    HistoryContentView(completedFasts: completedFasts)
                } else {
                    LockedHistoryView {
                        showPaywall = true
                    }
                }
            }
            .navigationTitle("History")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(purchaseService)
            }
        }
        .environmentObject(purchaseService)
    }
}

// MARK: - History Content

struct HistoryContentView: View {
    let completedFasts: [CompletedFast]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats cards
                StatsRow(completedFasts: completedFasts)
                    .padding(.horizontal)
                
                // Recent fasts
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Fasts")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if completedFasts.isEmpty {
                        Text("No completed fasts yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    } else {
                        ForEach(completedFasts.prefix(20)) { fast in
                            FastHistoryRow(
                                date: fast.startDate,
                                duration: fast.actualDuration,
                                preset: fast.presetName
                            )
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Stats Row

struct StatsRow: View {
    let completedFasts: [CompletedFast]
    
    private var totalFasts: Int {
        completedFasts.count
    }
    
    private var currentStreak: Int {
        calculateCurrentStreak()
    }
    
    private var bestStreak: Int {
        calculateBestStreak()
    }
    
    private var averageDuration: TimeInterval {
        guard !completedFasts.isEmpty else { return 0 }
        let total = completedFasts.reduce(0) { $0 + $1.actualDuration }
        return total / Double(completedFasts.count)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Total Fasts",
                    value: "\(totalFasts)",
                    icon: "number.circle.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(currentStreak) days",
                    icon: "flame.fill",
                    color: currentStreak > 0 ? .orange : .gray
                )
            }
            
            HStack(spacing: 12) {
                StatCard(
                    title: "Best Streak",
                    value: "\(bestStreak) days",
                    icon: "trophy.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Avg Duration",
                    value: formattedDuration(averageDuration),
                    icon: "clock.fill",
                    color: .green
                )
            }
        }
        .padding(.horizontal)
    }
    
    private func calculateCurrentStreak() -> Int {
        guard !completedFasts.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedFasts = completedFasts.sorted { $0.endDate > $1.endDate }
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // Check if there's a fast completed today or yesterday to maintain streak
        let mostRecentFast = sortedFasts[0]
        let mostRecentFastDay = calendar.startOfDay(for: mostRecentFast.endDate)
        let daysSinceLastFast = calendar.dateComponents([.day], from: mostRecentFastDay, to: currentDate).day ?? 0
        
        // Streak breaks if more than 1 day since last fast
        guard daysSinceLastFast <= 1 else { return 0 }
        
        streak = 1
        var previousDate = mostRecentFastDay
        
        // Count consecutive days
        for fast in sortedFasts.dropFirst() {
            let fastDay = calendar.startOfDay(for: fast.endDate)
            let daysBetween = calendar.dateComponents([.day], from: fastDay, to: previousDate).day ?? 0
            
            if daysBetween == 1 {
                streak += 1
                previousDate = fastDay
            } else if daysBetween == 0 {
                // Same day, continue without incrementing
                continue
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateBestStreak() -> Int {
        guard !completedFasts.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedFasts = completedFasts.sorted { $0.endDate < $1.endDate }
        
        var bestStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedFasts.count {
            let previousDay = calendar.startOfDay(for: sortedFasts[i-1].endDate)
            let currentDay = calendar.startOfDay(for: sortedFasts[i].endDate)
            
            let daysBetween = calendar.dateComponents([.day], from: previousDay, to: currentDay).day ?? 0
            
            if daysBetween == 1 {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else if daysBetween > 1 {
                currentStreak = 1
            }
            // If same day, don't change streak
        }
        
        return bestStreak
    }
    
    private func formattedDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Fast History Row

struct FastHistoryRow: View {
    let date: Date
    let duration: TimeInterval
    let preset: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Duration
            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedDuration(duration))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(preset)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
    
    private func formattedDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Locked History View

struct LockedHistoryView: View {
    let onUnlock: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("History is a Premium Feature")
                .font(.title2.bold())
            
            Text("Track your fasting history, view statistics, and build streaks with a one-time purchase.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button {
                onUnlock()
            } label: {
                Label("Unlock for \(AppConfig.unlockPrice)", systemImage: "lock.open")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 48)
        }
    }
}
