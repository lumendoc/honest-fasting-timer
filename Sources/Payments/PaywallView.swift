import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchaseService: PurchaseService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.accentColor)
                    
                    Text("Unlock Full App")
                        .font(.largeTitle.bold())

                    Text("One-time purchase. Never pay again.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "infinity", text: "All fasting presets")
                    FeatureRow(icon: "chart.bar", text: "Full history & stats")
                    FeatureRow(icon: "square.grid.2x2", text: "Home screen widget")
                    FeatureRow(icon: "bell", text: "Completion notifications")
                }
                .padding(.vertical)

                Spacer()

                if let product = purchaseService.product {
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                let success = try? await purchaseService.purchase()
                                if success == true {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack {
                                Text("Unlock — \(product.displayPrice)")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .disabled(purchaseService.isLoading)

                        Button("Restore Purchases") {
                            Task {
                                await purchaseService.restorePurchases()
                                if purchaseService.isUnlocked {
                                    dismiss()
                                }
                            }
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                } else if purchaseService.isLoading {
                    ProgressView("Loading...")
                } else {
                    Text("Unable to load product.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Dismiss") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}