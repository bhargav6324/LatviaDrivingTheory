import SwiftUI

@main
struct LatviaDrivingTheoryApp: App {
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var progressStore = ProgressStore.shared
    @StateObject private var questionRepo = QuestionRepository.shared
    @StateObject private var signRepo = RoadSignRepository.shared
    @StateObject private var premium = PremiumAccessManager.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var storeKit = StoreKitManager.shared
    @StateObject private var goalManager = DailyGoalManager.shared

    init() {
        #if DEBUG
        print("🚀 [APP STARTUP] Running Latvia Driving Theory: \(Bundle.main.bundleIdentifier ?? "UNKNOWN")")
        _ = MonetizationVerification.runAllTests()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(localization)
                .environmentObject(progressStore)
                .environmentObject(questionRepo)
                .environmentObject(signRepo)
                .environmentObject(premium)
                .environmentObject(purchaseManager)
                .environmentObject(storeKit)
                .environmentObject(goalManager)
                .task {
                    await purchaseManager.loadProducts()
                    await purchaseManager.refreshEntitlements()
                }
        }
    }
}
