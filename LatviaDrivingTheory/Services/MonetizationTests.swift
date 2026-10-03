import Foundation
import StoreKit

@MainActor
public struct MonetizationVerification {
    public static func runAllTests() -> [String: Bool] {
        var results: [String: Bool] = [:]
        let manager = PremiumAccessManager.shared
        let purchaseManager = PurchaseManager.shared

        let initialPremium = manager.isPremium
        let initialHasCompletedFreeMock = manager.hasCompletedFreeMock
        let initialType = purchaseManager.subscriptionType

        // Test A: Free user state by default
        manager.setPremiumState(unlocked: false, type: nil)
        manager.setHasCompletedFreeMockForTesting(false)
        results["A_isFreeByDefault"] = !manager.isPro
        results["A_subscriptionTypeIsNil"] = (purchaseManager.subscriptionType == nil)
        results["A_canViewAdvancedProgressIsFalse"] = !manager.canViewAdvancedProgress()

        // Test B: Free mock exam access
        let canTakeFirstMock = manager.canStartMockExam()
        results["B_canTakeFirstFreeMock"] = canTakeFirstMock

        // Mark completed free mock
        manager.markFreeMockCompleted()
        results["C_hasCompletedFreeMock"] = manager.hasCompletedFreeMock
        let canTakeSecondMock = manager.canStartMockExam()
        results["C_secondMockIsBlockedWithoutPro"] = (!canTakeSecondMock)

        // Test D: Pro features gated for free user
        results["D_fullPracticeLockedForFree"] = !manager.canAccess(feature: .fullPractice)
        results["D_roadSignTestLockedForFree"] = !manager.canAccess(feature: .roadSignTest)
        results["D_fullMistakesLockedForFree"] = !manager.canAccess(feature: .fullMistakes)

        // Test E: Monthly Subscription Entitlement
        purchaseManager.setProForTesting(true, type: .monthly)
        results["E_hasActiveMonthlySubscription"] = purchaseManager.hasActiveMonthlySubscription
        results["E_monthlyActive"] = purchaseManager.isMonthlyActive
        results["E_proActiveWithMonthly"] = purchaseManager.isPro
        results["E_subscriptionTypeIsMonthly"] = (purchaseManager.subscriptionType == .monthly)
        results["E_unlockedMocksWithMonthly"] = manager.canStartMockExam()

        // Test F: Lifetime Purchase Entitlement supersedes Monthly
        purchaseManager.setProForTesting(true, type: .lifetime)
        results["F_ownsLifetime"] = purchaseManager.ownsLifetime
        results["F_lifetimeOwned"] = purchaseManager.isLifetimeOwned
        results["F_proActiveWithLifetime"] = purchaseManager.isPro
        results["F_subscriptionTypeIsLifetime"] = (purchaseManager.subscriptionType == .lifetime)
        results["F_unlockedAllQuestions"] = (manager.accessibleQuestions().count == QuestionRepository.shared.questions.count)
        results["F_canViewAdvancedProgressWithPro"] = manager.canViewAdvancedProgress()

        // Restore initial state
        purchaseManager.setProForTesting(initialPremium, type: initialType)
        manager.setHasCompletedFreeMockForTesting(initialHasCompletedFreeMock)

        #if DEBUG
        print("📊 [MonetizationVerification] Results: \(results)")
        #endif

        return results
    }
}
