import Foundation
import StoreKit

@MainActor
class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    @Published var isUnlocked = false
    @Published var product: Product?
    @Published var isLoading = false
    
    private let productID = AppConfig.unlockProductId
    private var transactionTask: Task<Void, Never>?
    
    init() {
        // Start listening for transactions
        transactionTask = Task { [weak self] in
            await self?.listenForTransactions()
        }
        
        Task {
            await loadProducts()
            await checkPurchaseStatus()
        }
    }
    
    deinit {
        transactionTask?.cancel()
    }
    
    /// Continuously listen for new transactions (purchases from other tabs, restores, etc.)
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.productID == productID {
                await MainActor.run {
                    self.isUnlocked = true
                }
            }
            
            await transaction.finish()
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
        
        // Sync with App Store first (required for fresh device restore)
        try? await AppStore.sync()
        
        // Then check entitlements
        await checkPurchaseStatus()
    }
}
