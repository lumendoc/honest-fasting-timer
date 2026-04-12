import SwiftUI

struct HistoryView: View {
    @StateObject private var purchaseService = PurchaseService()
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            Group {
                if purchaseService.isUnlocked {
                    HistoryContentView()
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
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats cards
                StatsRow()
                    .padding(.horizontal)
                
                // Recent fasts
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Fasts")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Placeholder - would show actual fasts from SwiftData
                    ForEach(0..<5) { i in
                        FastHistoryRow(
                            date: Date().addingTimeInterval(-Double(i) * 86400),
                            duration: 16 * 60 * 60,
                            preset: "16:8 Intermittent"
                        )
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Stats Row

struct StatsRow: View {
    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Fasts",
                value: "\(AppGroupDefaults.shared.totalCompletedFasts)",
                icon: "number.circle.fill"
            )
            
            StatCard(
                title: "Current Streak",
                value: "\(AppGroupDefaults.shared.currentStreak) days",
                icon: "flame.fill"
            )
            
            StatCard(
                title: "Best Streak",
                value: "\(AppGroupDefaults.shared.longestStreak) days",
                icon: "trophy.fill"
            )
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
            
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
