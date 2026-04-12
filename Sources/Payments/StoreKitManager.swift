import SwiftUI
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isPremium = false
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                await self.handle(transactionResult: result)
            }
        }
    }
    
    func loadProducts() async {
        do {
            let productIDs = [AppConfig.weeklyProductId, AppConfig.monthlyProductId]
            products = try await Product.products(for: productIDs)
            await restorePurchases()
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            await handle(transactionResult: verification)
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }
    
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            await handle(transactionResult: result)
        }
    }
    
    private func handle(transactionResult: VerificationResult<Transaction>) async {
        switch transactionResult {
        case .verified(let transaction):
            purchasedProductIDs.insert(transaction.productID)
            isPremium = true
            await transaction.finish()
        case .unverified(_, let error):
            print("Unverified transaction: \(error)")
        }
    }
    
    var hasActiveTrial: Bool {
        return !isPremium
    }
}
