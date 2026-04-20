import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var purchaseService: PurchaseService
    @Environment(\.dismiss) private var dismiss
    @State private var showRestoreAlert = false
    @State private var restoreSuccess = false
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Purchase")
                            .font(.title2.bold())
                        Text("See your current access, restore past purchases, and review what the full unlock includes.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    PurchaseStatusCard(
                        isUnlocked: purchaseService.isUnlocked,
                        actionTitle: purchaseService.isUnlocked ? "Restore Purchases" : "View Full Unlock"
                    ) {
                        if purchaseService.isUnlocked {
                            Task {
                                await purchaseService.restorePurchases()
                                restoreSuccess = purchaseService.isUnlocked
                                showRestoreAlert = true
                            }
                        } else {
                            showPaywall = true
                        }
                    }

                    if purchaseService.isLoading {
                        HStack(spacing: 10) {
                            ProgressView()
                                .scaleEffect(0.9)
                            Text("Checking App Store purchases…")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    MonetizationCard(accent: purchaseService.isUnlocked ? .green : .accentColor) {
                        Text(purchaseService.isUnlocked ? "Included with your unlock" : "Included with full unlock")
                            .font(.headline)

                        PurchaseFeatureList(items: [
                            ("infinity", "All fasting presets", "Use 16:8, 18:6, OMAD, and any additional presets added later."),
                            ("clock.badge.checkmark", "Saved progress", "Keep a record of completed fasts with simple streak and duration stats."),
                            ("apps.iphone", "Widget access", "Bring your current fast to the home screen."),
                            ("bell.badge", "Completion reminders", "Get notified when the target time is reached.")
                        ])
                    }

                    MonetizationCard {
                        Text("Purchase management")
                            .font(.headline)

                        Text("This app currently uses a one-time lifetime unlock, not a renewable subscription. There is nothing to cancel or downgrade. If you reinstall or switch devices, use Restore Purchases with the same Apple ID.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button {
                            Task {
                                await purchaseService.restorePurchases()
                                restoreSuccess = purchaseService.isUnlocked
                                showRestoreAlert = true
                            }
                        } label: {
                            HStack {
                                Text("Restore Purchases")
                                Spacer()
                                Image(systemName: "arrow.clockwise")
                            }
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.12))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(purchaseService.isLoading)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Legal")
                            .font(.headline)

                        Link(destination: AppConfig.privacyPolicyURL) {
                            settingsLinkRow(icon: "shield.checkerboard", title: "Privacy Policy")
                        }

                        Link(destination: AppConfig.termsOfServiceURL) {
                            settingsLinkRow(icon: "doc.text", title: "Terms of Use")
                        }

                        Link(destination: AppConfig.supportURL) {
                            settingsLinkRow(icon: "envelope", title: "Support")
                        }
                    }

                    MonetizationCard(accent: .gray) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        HStack {
                            Text("Made by")
                            Spacer()
                            Text("Lumen")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(restoreSuccess 
                     ? "Your purchases have been restored successfully."
                     : "No previous purchases found. If you believe this is an error, please try again.")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: .settings)
                    .environmentObject(purchaseService)
            }
        }
    }

    private func settingsLinkRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
            Text(title)
            Spacer()
            Image(systemName: "arrow.up.right.square")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 2)
    }
}

#Preview {
    SettingsView()
        .environmentObject(PurchaseService.shared)
}
