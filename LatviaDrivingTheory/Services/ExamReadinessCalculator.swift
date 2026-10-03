import Foundation

/// Centralized, weight-based exam readiness calculator for Latvia Driving Theory.
public enum ExamReadinessCalculator {

    // MARK: - Weight Configuration
    /// Recent mock exam performance weight (0.0–1.0)
    static let mockWeight: Double = 0.35
    /// Practice session accuracy weight
    static let practiceWeight: Double = 0.30
    /// Topic coverage (breadth) weight
    static let topicWeight: Double = 0.20
    /// Mastery / mistake-clearing weight
    static let masteryWeight: Double = 0.15

    /// Minimum number of total question attempts before calculating readiness percentage.
    static let minimumAttemptsRequired: Int = 10

    // MARK: - Public API

    public static func calculate(progressStore store: ProgressStore, totalQuestionBankCount: Int) -> ReadinessResult {
        let totalAttempts = store.questionProgressMap.values.reduce(0) { $0 + $1.attempts }

        guard totalAttempts >= minimumAttemptsRequired else {
            return .notEnoughData
        }

        // 1. Practice accuracy (30%)
        let totalAtt = store.questionProgressMap.values.reduce(0) { $0 + $1.attempts }
        let correctAtt = store.questionProgressMap.values.reduce(0) { $0 + $1.correctAttempts }
        let practiceAccuracy = totalAtt > 0 ? Double(correctAtt) / Double(totalAtt) : 0.0
        let practiceScore = practiceAccuracy * practiceWeight * 100.0

        // 2. Recent mock exam scores (35%)
        let recentMocks = Array(store.mockExamHistory.prefix(5))
        let mockScore: Double
        if recentMocks.isEmpty {
            mockScore = 0
        } else {
            let avgMockPct = recentMocks.reduce(0.0) { acc, exam in
                acc + (Double(exam.score) / Double(max(1, exam.totalQuestions)))
            } / Double(recentMocks.count)
            mockScore = avgMockPct * mockWeight * 100.0
        }

        // 3. Topic coverage (20%)
        let allTopics = TopicCategory.allCases
        let topicsAttempted = allTopics.filter { topic in
            QuestionRepository.shared.questions(for: topic).contains { q in
                (store.questionProgressMap[q.id]?.attempts ?? 0) > 0
            }
        }.count
        let topicCoverage = allTopics.isEmpty ? 0.0 : Double(topicsAttempted) / Double(allTopics.count)
        let topicScore = topicCoverage * topicWeight * 100.0

        // 4. Mastery & mistake-clearing (15%)
        let totalQuestions = max(1, totalQuestionBankCount)
        let mastered = store.questionsMasteredCount
        let activeMistakes = store.activeMistakeCount()

        let masteryFraction = Double(mastered) / Double(totalQuestions)
        let mistakePenalty = min(0.3, Double(activeMistakes) / Double(totalQuestions) * 3.0)
        let masteryScore = max(0.0, (masteryFraction - mistakePenalty)) * masteryWeight * 100.0

        // Sum and clamp 0-100
        let total = practiceScore + mockScore + topicScore + masteryScore
        let clamped = Int(min(100.0, max(0.0, total)))

        return ReadinessResult(
            percentage: clamped,
            mockWeight: mockScore,
            practiceWeight: practiceScore,
            topicWeight: topicScore,
            masteryWeight: masteryScore
        )
    }
}
