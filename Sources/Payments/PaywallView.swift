import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var store: StoreKitManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Unlock Premium")
                    .font(.largeTitle.bold())
                
                Text("Start your \(AppConfig.trialDays)-day free trial. Cancel anytime.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    ForEach(store.products) { product in
                        Button {
                            Task {
                                _ = try? await store.purchase(product)
                            }
                        } label: {
                            HStack {
                                Text(product.displayName)
                                Spacer()
                                Text(product.displayPrice)
                            }
                            .padding()
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Button("Restore Purchases") {
                    Task {
                        await store.restorePurchases()
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                
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
