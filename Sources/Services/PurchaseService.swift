import Foundation
import StoreKit

@MainActor
class PurchaseService: ObservableObject {
    @Published var isUnlocked = false
    @Published var product: Product?
    @Published var isLoading = false
    
    private let productID = AppConfig.unlockProductId
    
    init() {
        Task {
            await loadProducts()
            await checkPurchaseStatus()
        }
    }
    
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productID])
            self.product = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productID {
                isUnlocked = true
                return
            }
        }
        isUnlocked = false
    }
    
    func purchase() async throws -> Bool {
        guard let product = product else {
            print("Product not loaded")
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                isUnlocked = true
                return true
            }
            return false
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        await checkPurchaseStatus()
    }
}
