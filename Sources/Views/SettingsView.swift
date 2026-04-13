import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var purchaseService: PurchaseService
    @Environment(\.dismiss) private var dismiss
    @State private var showRestoreAlert = false
    @State private var restoreSuccess = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Purchases Section
                Section("Purchases") {
                    Button {
                        Task {
                            await purchaseService.restorePurchases()
                            restoreSuccess = purchaseService.isUnlocked
                            showRestoreAlert = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(Color.accentColor)
                            Text("Restore Purchases")
                            Spacer()
                            if purchaseService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(purchaseService.isLoading)
                    
                    if purchaseService.isUnlocked {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                            Text("Premium Unlocked")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("Active")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    } else {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.orange)
                            Text("Free Version")
                                .foregroundStyle(.secondary)
                            Spacer()
                            NavigationLink {
                                PaywallView()
                            } label: {
                                Text("Upgrade")
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
                
                // MARK: - Legal Section
                Section("Legal") {
                    Link(destination: AppConfig.privacyPolicyURL) {
                        HStack {
                            Image(systemName: "shield.checkerboard")
                                .foregroundStyle(Color.accentColor)
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Link(destination: AppConfig.termsOfServiceURL) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundStyle(Color.accentColor)
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // MARK: - About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Made by")
                        Spacer()
                        Text("Lumen")
                            .foregroundStyle(.secondary)
                    }
                }
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
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(PurchaseService.shared)
}
