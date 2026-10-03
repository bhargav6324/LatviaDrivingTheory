import Foundation
import StoreKit

/// Facade for backwards compatibility with any views or tests expecting StoreKitManager.
/// All monetization, StoreKit 2 loading, and entitlement verification is powered by PurchaseManager and PremiumAccessManager.
@MainActor
public final class StoreKitManager: ObservableObject {
    public static let shared = StoreKitManager()

    private var purchaseManager: PurchaseManager {
        PurchaseManager.shared
    }

    private var premium: PremiumAccessManager {
        PremiumAccessManager.shared
    }

    public static let lifetimeID = "lv.drivingtheory.pro.lifetime"
    public static let monthlyID = "lv.drivingtheory.pro.monthly"

    public static var lifetimeProductID: String {
        lifetimeID
    }
    public static var monthlyProductID: String {
        monthlyID
    }

    public var isPremiumUnlocked: Bool { purchaseManager.isPro }
    public var product: Product? { purchaseManager.proProduct }
    public var lifetimeProduct: Product? { purchaseManager.proProduct }
    public var isLoading: Bool { purchaseManager.purchaseInProgress }
    public var errorMessage: String? { purchaseManager.purchaseError }
    public var restoreMessage: String? { purchaseManager.restoreMessage }
    public var hasLoadedProducts: Bool { purchaseManager.hasLoadedProducts }

    public init() {}

    public func loadProducts() async {
        await purchaseManager.loadProducts()
    }

    public func purchase() async -> Bool {
        await purchaseManager.purchasePro()
    }

    public func restorePurchases() async {
        await purchaseManager.restorePurchases()
    }

    public func refreshEntitlements() async {
        await purchaseManager.refreshEntitlements()
    }

    public func setPremiumUnlocked(_ unlocked: Bool) {
        premium.setPremiumState(unlocked: unlocked)
    }

    public var lifetimeDisplayPrice: String? {
        premium.lifetimeDisplayPrice
    }
}
