import Foundation
import StoreKit
import SwiftUI

public enum PremiumFeature {
    case unlimitedMockExams
    case fullPractice
    case roadSignFlashcards
    case roadSignTest
    case fullMistakes
    case weakTopicPractice
    case advancedProgress
}

/// Central service and entitlement/access policy for Free vs Pro gating in Latvia Driving Theory.
/// Views should check `FeatureAccessService.shared` or `PremiumAccessManager.shared`.
@MainActor
public final class PremiumAccessManager: ObservableObject {
    public static let shared = PremiumAccessManager()

    private var purchaseManager: PurchaseManager {
        PurchaseManager.shared
    }

    // UserDefaults Keys
    private let hasCompletedFreeMockKey = "latvia_has_completed_free_mock_v1"
    private let freeQuestionIDsKey = "latvia_free_question_ids_v1"

    @Published public private(set) var hasCompletedFreeMock: Bool = false
    @Published public private(set) var freeQuestionIDs: [String] = []

    // Unified Pro Status
    public var isPro: Bool {
        purchaseManager.isPro
    }

    public var isPremium: Bool {
        purchaseManager.isPro
    }

    public var subscriptionType: SubscriptionType? {
        purchaseManager.subscriptionType
    }

    public var lifetimeProduct: Product? {
        purchaseManager.lifetimeProduct
    }

    public var monthlyProduct: Product? {
        purchaseManager.monthlyProduct
    }

    public var isLoading: Bool {
        purchaseManager.purchaseInProgress
    }

    public var errorMessage: String? {
        purchaseManager.purchaseError
    }

    public var restoreMessage: String? {
        purchaseManager.restoreMessage
    }

    public var hasLoadedProducts: Bool {
        purchaseManager.hasLoadedProducts
    }

    public var lifetimeDisplayPrice: String? {
        purchaseManager.lifetimeDisplayPrice
    }

    public var monthlyDisplayPrice: String? {
        purchaseManager.monthlyDisplayPrice
    }

    private init() {
        self.hasCompletedFreeMock = UserDefaults.standard.bool(forKey: hasCompletedFreeMockKey)
        if let stored = UserDefaults.standard.stringArray(forKey: freeQuestionIDsKey), !stored.isEmpty {
            self.freeQuestionIDs = stored
        }

        initializeFreeQuestionPoolIfNeeded()
    }

    // MARK: - Free Question Pool Management

    public func initializeFreeQuestionPoolIfNeeded() {
        if !freeQuestionIDs.isEmpty { return }

        let allQuestions = QuestionRepository.shared.questions
        guard !allQuestions.isEmpty else {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 200_000_000)
                if self.freeQuestionIDs.isEmpty {
                    self.initializeFreeQuestionPoolIfNeeded()
                }
            }
            return
        }

        // Generate a balanced 30-question Category B exam set for Latvia free pool
        let freeExamSet = QuestionRepository.shared.randomExamQuestions(config: .latvianCategoryB)
        let ids = freeExamSet.map { $0.id }
        self.freeQuestionIDs = ids
        UserDefaults.standard.set(ids, forKey: freeQuestionIDsKey)
        #if DEBUG
        print("[FeatureAccess] Initialized \(ids.count) free question IDs pool for Latvia.")
        #endif
    }

    public func markFreeMockCompleted() {
        self.hasCompletedFreeMock = true
        UserDefaults.standard.set(true, forKey: hasCompletedFreeMockKey)
    }

    public func setHasCompletedFreeMockForTesting(_ completed: Bool) {
        self.hasCompletedFreeMock = completed
        UserDefaults.standard.set(completed, forKey: hasCompletedFreeMockKey)
    }

    public func setPremiumState(unlocked: Bool, type: SubscriptionType? = .lifetime) {
        purchaseManager.setProForTesting(unlocked, type: type)
    }

    // MARK: - Centralized Access Policies

    /// Whether the user can start a mock exam (Free users get 1 sample mock exam).
    public func canStartMockExam() -> Bool {
        if isPro { return true }
        return !hasCompletedFreeMock
    }

    /// Whether the user can access this specific question.
    public func canAccessQuestion(_ question: Question) -> Bool {
        if isPro { return true }
        if !question.isPremium { return true }
        let pool = Set(freeQuestionIDs)
        return pool.contains(question.id)
    }

    /// Whether the user can practice topics beyond the free sample questions.
    public func canAccessTopic(_ topic: TopicCategory) -> Bool {
        if isPro { return true }
        // Free users can always access their free questions within any topic
        return hasAccessibleQuestions(for: topic)
    }

    /// Whether mistake practice is fully unlocked.
    public func canUseMistakePractice() -> Bool {
        // Free users can see mistake count and review mistakes on their free questions;
        // unlimited mistake drills are unlocked with Pro.
        return true
    }

    /// Whether advanced readiness and detailed statistical breakdowns are accessible.
    public func canViewAdvancedProgress() -> Bool {
        return isPro
    }

    /// Feature gating helper
    public func canAccess(feature: PremiumFeature) -> Bool {
        if isPro { return true }

        switch feature {
        case .unlimitedMockExams:
            return !hasCompletedFreeMock
        case .fullPractice,
             .roadSignFlashcards,
             .roadSignTest,
             .fullMistakes,
             .weakTopicPractice,
             .advancedProgress:
            return false
        }
    }

    // Accessible Questions (free questions pool or full bank)
    public func accessibleQuestions() -> [Question] {
        if isPro {
            return QuestionRepository.shared.questions
        }
        let pool = Set(freeQuestionIDs)
        let filtered = QuestionRepository.shared.questions.filter { !$0.isPremium || pool.contains($0.id) }
        return filtered.isEmpty ? Array(QuestionRepository.shared.questions.prefix(30)) : filtered
    }

    public func accessibleQuestions(for topic: TopicCategory) -> [Question] {
        if isPro {
            return QuestionRepository.shared.questions(for: topic)
        }
        let pool = Set(freeQuestionIDs)
        let matched = QuestionRepository.shared.questions(for: topic).filter { !$0.isPremium || pool.contains($0.id) }
        if matched.isEmpty {
            // Provide at least 1-2 free preview questions per topic
            return Array(QuestionRepository.shared.questions(for: topic).prefix(2))
        }
        return matched
    }

    public func hasAccessibleQuestions(for topic: TopicCategory) -> Bool {
        return !accessibleQuestions(for: topic).isEmpty
    }

    public func freeQuestionsCount(for topic: TopicCategory) -> Int {
        return accessibleQuestions(for: topic).count
    }

    public func totalFullQuestionsCount(for topic: TopicCategory) -> Int {
        return QuestionRepository.shared.questions(for: topic).count
    }

    public func freeMockQuestions() -> [Question] {
        let pool = Set(freeQuestionIDs)
        let matched = QuestionRepository.shared.questions.filter { pool.contains($0.id) }
        if matched.count == 30 {
            return matched
        }
        return QuestionRepository.shared.randomExamQuestions(config: .latvianCategoryB)
    }

    // MARK: - Purchase Actions

    public func purchaseLifetime() async -> Bool {
        return await purchaseManager.purchaseLifetime()
    }

    public func purchaseMonthly() async -> Bool {
        return await purchaseManager.purchaseMonthly()
    }

    public func restorePurchases() async -> Bool {
        return await purchaseManager.restorePurchases()
    }
}

/// Typealias providing the exact name requested by design specifications.
public typealias FeatureAccessService = PremiumAccessManager
