import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchaseService: PurchaseService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Unlock Full App")
                    .font(.largeTitle.bold())

                Text("One-time purchase. Never pay again.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if let product = purchaseService.product {
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                _ = try? await purchaseService.purchase()
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

                Spacer()
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