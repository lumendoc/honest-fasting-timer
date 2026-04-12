import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchaseService: PurchaseService
    @Environment(\.
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.accent)
                
                Text("Unlock Premium")
                    .font(.title.bold())
                
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "timer", text: "All fasting presets (18:6, 20:4, OMAD)")
                    FeatureRow(icon: "chart.bar", text: "Fasting history & statistics")
                    FeatureRow(icon: "flame", text: "Streak tracking")
                    FeatureRow(icon: "bell", text: "Custom notifications")
                    FeatureRow(icon: "square.grid.2x2", text: "Home screen widget")
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                VStack(spacing: 12) {
                    if let product = purchaseService.product {
                        Text("One-time purchase of \(product.displayPrice)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button {
                        Task {
                            do {
                                let success = try await purchaseService.purchase()
                                if success {
                                    dismiss()
                                }
                            } catch {
                                showError = true
                            }
                        }
                    } label: {
                        HStack {
                            if purchaseService.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Unlock Now")
                            }
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(purchaseService.isLoading)
                    
                    Button {
                        Task {
                            await purchaseService.restorePurchases()
                            if purchaseService.isUnlocked {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .disabled(purchaseService.isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
            .alert("Purchase Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Unable to complete purchase. Please try again.")
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
                .foregroundStyle(.accent)
                .frame(width: 24)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}
