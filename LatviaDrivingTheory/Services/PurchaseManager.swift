import Foundation
import StoreKit
import SwiftUI

public enum SubscriptionType: String, Codable {
    case monthly
    case lifetime
}

/// Central manager for StoreKit 2 in-app purchases and Latvia Driving Theory Pro entitlement verification with dual-product support:
/// 1. PRO uz mūžu (Non-Consumable IAP)
/// 2. PRO mēnesim (Auto-Renewable Subscription)
@MainActor
public final class PurchaseManager: ObservableObject {
    public static let shared = PurchaseManager()

    // Canonical Product Identifiers
    public static let lifetimeProductID = StoreProducts.lifetime
    public static let monthlyProductID = StoreProducts.monthly
    public static let productIDs: Set<String> = StoreProducts.all

    // UserDefaults Keys (for offline continuity before StoreKit verification)
    private let cachedProKey = "latvia_driving_pro_unlocked_cached"
    private let cachedSubscriptionTypeKey = "latvia_driving_subscription_type_cached"

    // Published Entitlement State
    @Published public private(set) var isPro: Bool = false
    @Published public private(set) var ownsLifetime: Bool = false
    @Published public private(set) var hasActiveMonthlySubscription: Bool = false
    @Published public private(set) var subscriptionType: SubscriptionType? = nil

    // Backward-compatibility aliases
    public var isLifetimeOwned: Bool { ownsLifetime }
    public var isMonthlyActive: Bool { hasActiveMonthlySubscription }

    // StoreKit 2 Products
    @Published public private(set) var products: [Product] = []
    @Published public private(set) var lifetimeProduct: Product? = nil
    @Published public private(set) var monthlyProduct: Product? = nil

    // Backward-compatibility alias
    public var proProduct: Product? { lifetimeProduct ?? products.first }

    @Published public var purchaseInProgress: Bool = false
    @Published public var purchaseError: String? = nil
    @Published public var restoreMessage: String? = nil
    @Published public var hasLoadedProducts: Bool = false

    private var transactionListenerTask: Task<Void, Never>?
    private var storefrontListenerTask: Task<Void, Never>?

    // MARK: - Localized Dynamic Display Pricing from StoreKit 2

    /// Localized display price for lifetime full access (from StoreKit Product.displayPrice).
    public var lifetimeDisplayPrice: String? {
        lifetimeProduct?.displayPrice
    }

    /// Localized display price for monthly subscription (from StoreKit Product.displayPrice).
    public var monthlyDisplayPrice: String? {
        monthlyProduct?.displayPrice
    }

    // MARK: - Initialization

    public init() {
        // Step 1: Immediately read cached Pro status for UI continuity when offline
        self.isPro = UserDefaults.standard.bool(forKey: cachedProKey)
        if let typeStr = UserDefaults.standard.string(forKey: cachedSubscriptionTypeKey),
           let type = SubscriptionType(rawValue: typeStr) {
            self.subscriptionType = type
            self.ownsLifetime = (type == .lifetime)
            self.hasActiveMonthlySubscription = (type == .monthly)
        }

        // Step 2: Start background transaction updates & storefront listeners
        startTransactionListener()
        startStorefrontListener()

        // Step 3: Trigger async load of products and entitlement reconciliation
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        transactionListenerTask?.cancel()
        storefrontListenerTask?.cancel()
    }

    // MARK: - Transaction & Storefront Listeners

    private func startTransactionListener() {
        transactionListenerTask = Task.detached { [weak self] in
            for await result in StoreKit.Transaction.updates {
                await self?.handleTransactionResult(result)
            }
        }
    }

    private func startStorefrontListener() {
        storefrontListenerTask = Task.detached { [weak self] in
            for await updatedStorefront in Storefront.updates {
                #if DEBUG
                print("[StoreKit] Storefront updated to country code: \(updatedStorefront.countryCode)")
                #endif
                await self?.loadProducts()
            }
        }
    }

    private func handleTransactionResult(_ result: VerificationResult<StoreKit.Transaction>) async {
        switch result {
        case .verified(let transaction):
            #if DEBUG
            print("[StoreKit] Transaction update received: \(transaction.productID)")
            #endif
            await refreshEntitlements()
            await transaction.finish()
        case .unverified(_, let error):
            #if DEBUG
            print("[StoreKit] Unverified transaction ignored: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Loading Products

    /// Loads both Lifetime and Monthly StoreKit 2 products.
    public func loadProducts() async {
        let ids = Self.productIDs

        #if DEBUG
        print("=== LATVIA STOREKIT DEBUG ===")
        print("Bundle:", Bundle.main.bundleIdentifier ?? "nil")
        print("Requested IDs:", ids)
        #endif

        do {
            let products = try await Product.products(for: ids)
            self.products = products

            // Map returned products by product.id
            self.lifetimeProduct = products.first { $0.id == Self.lifetimeProductID }
            self.monthlyProduct = products.first { $0.id == Self.monthlyProductID }

            #if DEBUG
            print("Returned count:", products.count)
            for product in products {
                print("Returned product:")
                print("ID:", product.id)
                print("Name:", product.displayName)
                print("Price:", product.displayPrice)
                print("Type:", product.type)
            }
            #endif
            self.hasLoadedProducts = true
        } catch {
            #if DEBUG
            print("STOREKIT PRODUCT LOAD ERROR:")
            print(error)
            #endif
            self.products = []
            self.lifetimeProduct = nil
            self.monthlyProduct = nil
            self.hasLoadedProducts = true
        }
    }

    // MARK: - Entitlement Verification

    /// Checks current verified entitlements via StoreKit 2 and reconciles local state.
    /// Unified Pro logic: isPro = ownsLifetime || hasActiveMonthlySubscription
    public func refreshEntitlements() async {
        var foundLifetime = false
        var foundMonthly = false

        for await result in StoreKit.Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                // Skip revoked transactions
                guard transaction.revocationDate == nil else {
                    #if DEBUG
                    print("[StoreKit] Revoked transaction skipped: \(transaction.productID)")
                    #endif
                    continue
                }

                // Check Lifetime Non-Consumable
                if transaction.productID == Self.lifetimeProductID {
                    foundLifetime = true
                    await transaction.finish()
                    #if DEBUG
                    print("[StoreKit] Lifetime entitlement verified.")
                    #endif
                }
                // Check Monthly Auto-Renewable Subscription
                else if transaction.productID == Self.monthlyProductID {
                    if let exp = transaction.expirationDate {
                        if exp > Date() {
                            foundMonthly = true
                            await transaction.finish()
                            #if DEBUG
                            print("[StoreKit] Monthly subscription verified until \(exp).")
                            #endif
                        } else {
                            #if DEBUG
                            print("[StoreKit] Monthly subscription expired on \(exp).")
                            #endif
                        }
                    } else {
                        // Non-expiring subscription (e.g. sandbox simulation)
                        foundMonthly = true
                        await transaction.finish()
                    }
                }

            case .unverified(_, let error):
                #if DEBUG
                print("[StoreKit] Unverified entitlement found: \(error.localizedDescription)")
                #endif
            }
        }

        // Entitlement calculation
        let activePro = foundLifetime || foundMonthly
        let resolvedType: SubscriptionType? = foundLifetime ? .lifetime : (foundMonthly ? .monthly : nil)

        await updateEntitlementState(
            pro: activePro,
            lifetime: foundLifetime,
            monthly: foundMonthly,
            type: resolvedType
        )
    }

    private func updateEntitlementState(pro: Bool, lifetime: Bool, monthly: Bool, type: SubscriptionType?) async {
        self.ownsLifetime = lifetime
        self.hasActiveMonthlySubscription = monthly
        self.isPro = lifetime || monthly
        self.subscriptionType = type

        UserDefaults.standard.set(self.isPro, forKey: cachedProKey)
        if let type = type {
            UserDefaults.standard.set(type.rawValue, forKey: cachedSubscriptionTypeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: cachedSubscriptionTypeKey)
        }
    }

    // MARK: - Purchase Flow

    /// Purchases Lifetime Pro.
    @discardableResult
    public func purchaseLifetime() async -> Bool {
        if let product = lifetimeProduct ?? products.first(where: { $0.id == Self.lifetimeProductID }) {
            return await executePurchase(for: product)
        }
        await loadProducts()
        if let product = lifetimeProduct ?? products.first(where: { $0.id == Self.lifetimeProductID }) {
            return await executePurchase(for: product)
        }
        purchaseError = LocalizationManager.shared.t(.purchasesUnavailable)
        return false
    }

    /// Purchases Monthly Pro subscription.
    @discardableResult
    public func purchaseMonthly() async -> Bool {
        if let product = monthlyProduct ?? products.first(where: { $0.id == Self.monthlyProductID }) {
            return await executePurchase(for: product)
        }
        await loadProducts()
        if let product = monthlyProduct ?? products.first(where: { $0.id == Self.monthlyProductID }) {
            return await executePurchase(for: product)
        }
        purchaseError = LocalizationManager.shared.t(.purchasesUnavailable)
        return false
    }

    /// Generic purchase method for Product.
    @discardableResult
    public func purchase(_ product: Product) async -> Bool {
        return await executePurchase(for: product)
    }

    /// Backwards compatibility single-purchase method.
    @discardableResult
    public func purchasePro() async -> Bool {
        return await purchaseLifetime()
    }

    private func executePurchase(for product: Product) async -> Bool {
        // If already lifetime owned, skip unnecessary purchase
        if isLifetimeOwned {
            #if DEBUG
            print("[StoreKit] Lifetime already owned. Skipping purchase.")
            #endif
            return true
        }

        purchaseInProgress = true
        purchaseError = nil
        defer { purchaseInProgress = false }

        do {
            let purchaseResult = try await product.purchase()

            switch purchaseResult {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await refreshEntitlements()
                    return true

                case .unverified(_, let error):
                    purchaseError = "Pirkumu neizdevās verificēt ar Apple: \(error.localizedDescription)"
                    return false
                }

            case .userCancelled:
                // User cancelled - clear error, do NOT show error alert
                purchaseError = nil
                return false

            case .pending:
                purchaseError = "Pirkums gaida apstiprinājumu (Ask to Buy). Piekļuve tiks aktivizēta pēc apstiprināšanas."
                return false

            @unknown default:
                purchaseError = "Radās neparedzēta kļūda. Lūdzu, mēģiniet vēlreiz."
                return false
            }
        } catch {
            purchaseError = "Pirkumu neizdevās pabeigt. Lūdzu, pārbaudiet interneta savienojumu."
            #if DEBUG
            print("[StoreKit] Purchase error: \(error.localizedDescription)")
            #endif
            return false
        }
    }

    // MARK: - Restore Purchases

    /// Restores previous purchases via AppStore.sync() and reconciles verified entitlements.
    @discardableResult
    public func restorePurchases() async -> Bool {
        purchaseInProgress = true
        purchaseError = nil
        restoreMessage = nil
        defer { purchaseInProgress = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()

            if isPro {
                restoreMessage = LocalizationManager.shared.t(.restorePurchasesSuccess)
                return true
            } else {
                restoreMessage = LocalizationManager.shared.t(.restorePurchasesNotFound)
                return false
            }
        } catch {
            #if DEBUG
            print("[StoreKit] Restore failed: \(error.localizedDescription)")
            #endif
            restoreMessage = "Neizdevās atjaunot pirkumus. Lūdzu, pārbaudiet tīkla savienojumu."
            return false
        }
    }

    // MARK: - Testing Utilities

    public func setProForTesting(_ active: Bool, type: SubscriptionType? = .lifetime) {
        self.ownsLifetime = active && (type == .lifetime)
        self.hasActiveMonthlySubscription = active && (type == .monthly)
        self.isPro = active
        self.subscriptionType = active ? type : nil
        UserDefaults.standard.set(active, forKey: cachedProKey)
        if let type = type, active {
            UserDefaults.standard.set(type.rawValue, forKey: cachedSubscriptionTypeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: cachedSubscriptionTypeKey)
        }
    }
}
