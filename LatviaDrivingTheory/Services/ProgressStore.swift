import Foundation
import Combine

public final class ProgressStore: ObservableObject {
    public static let shared = ProgressStore()

    private let questionProgressKey = "latvia_driving_question_progress_v1"
    private let mistakesKey = "latvia_driving_mistakes_v1"
    private let mockExamsKey = "latvia_driving_mock_exams_v1"
    private let recentTopicKey = "latvia_driving_recent_topic"

    @Published public private(set) var questionProgressMap: [String: QuestionProgress] = [:]
    @Published public private(set) var mistakesMap: [String: MistakeRecord] = [:]
    @Published public private(set) var mockExamHistory: [ExamResult] = []
    @Published public var recentTopic: TopicCategory?

    private init() {
        loadData()
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: questionProgressKey),
           let decoded = try? JSONDecoder().decode([String: QuestionProgress].self, from: data) {
            self.questionProgressMap = decoded
        }

        if let data = UserDefaults.standard.data(forKey: mistakesKey),
           let decoded = try? JSONDecoder().decode([String: MistakeRecord].self, from: data) {
            self.mistakesMap = decoded
        }

        if let data = UserDefaults.standard.data(forKey: mockExamsKey),
           let decoded = try? JSONDecoder().decode([ExamResult].self, from: data) {
            self.mockExamHistory = decoded
        }

        if let topicRaw = UserDefaults.standard.string(forKey: recentTopicKey),
           let topic = TopicCategory(rawValue: topicRaw) {
            self.recentTopic = topic
        }
    }

    private func saveData() {
        if let data = try? JSONEncoder().encode(questionProgressMap) {
            UserDefaults.standard.set(data, forKey: questionProgressKey)
        }
        if let data = try? JSONEncoder().encode(mistakesMap) {
            UserDefaults.standard.set(data, forKey: mistakesKey)
        }
        if let data = try? JSONEncoder().encode(mockExamHistory) {
            UserDefaults.standard.set(data, forKey: mockExamsKey)
        }
        if let recent = recentTopic {
            UserDefaults.standard.set(recent.rawValue, forKey: recentTopicKey)
        }
    }

    // MARK: - Answer Recording

    public func recordAnswer(question: Question, isCorrect: Bool) {
        var progress = questionProgressMap[question.id] ?? QuestionProgress(questionId: question.id)
        progress.recordAnswer(isCorrect: isCorrect)
        questionProgressMap[question.id] = progress

        recentTopic = question.topic

        if !isCorrect {
            var mistake = mistakesMap[question.id] ?? MistakeRecord(questionId: question.id, topic: question.topic)
            mistake.mistakeCount += 1
            mistake.lastMistakeDate = Date()
            mistake.isResolved = false
            mistakesMap[question.id] = mistake
        } else {
            if var mistake = mistakesMap[question.id] {
                mistake.resolvedCount += 1
                if mistake.resolvedCount >= 2 || progress.isMastered {
                    mistake.isResolved = true
                }
                mistakesMap[question.id] = mistake
            }
        }

        saveData()

        DailyGoalManager.shared.recordQuestionAnswered(isCorrect: isCorrect)
    }

    public func recordMockExam(_ result: ExamResult) {
        mockExamHistory.insert(result, at: 0)
        saveData()

        DailyGoalManager.shared.recordMockExamCompleted()
    }

    // MARK: - Mistakes Management

    public var activeMistakeRecords: [MistakeRecord] {
        mistakesMap.values
            .filter { !$0.isResolved }
            .sorted { $0.lastMistakeDate > $1.lastMistakeDate }
    }

    public func activeMistakes(filteredBy allowedIds: Set<String>? = nil) -> [Question] {
        let repo = QuestionRepository.shared
        return mistakesMap.values
            .filter { !$0.isResolved }
            .filter { allowedIds == nil || allowedIds!.contains($0.questionId) }
            .sorted { $0.lastMistakeDate > $1.lastMistakeDate }
            .compactMap { repo.question(with: $0.questionId) }
    }

    public func activeMistakeCount(filteredBy allowedIds: Set<String>? = nil) -> Int {
        activeMistakes(filteredBy: allowedIds).count
    }

    public func clearMistake(questionId: String) {
        if var mistake = mistakesMap[questionId] {
            mistake.isResolved = true
            mistakesMap[questionId] = mistake
            saveData()
        }
    }

    public func clearAllMasteredMistakes() {
        for (id, var mistake) in mistakesMap {
            if let p = questionProgressMap[id], p.isMastered {
                mistake.isResolved = true
                mistakesMap[id] = mistake
            }
        }
        saveData()
    }

    // MARK: - Statistics & Metrics

    public var totalQuestionsAnswered: Int {
        questionProgressMap.values.reduce(0) { $0 + $1.attempts }
    }

    public var totalQuestionsAttempted: Int {
        totalQuestionsAnswered
    }

    public var totalCorrectAnswers: Int {
        questionProgressMap.values.reduce(0) { $0 + $1.correctAttempts }
    }

    public var overallAccuracyPercentage: Int {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Int(Double(totalCorrectAnswers) / Double(totalQuestionsAnswered) * 100)
    }

    public var questionsMasteredCount: Int {
        questionProgressMap.values.filter { $0.isMastered }.count
    }

    public var totalQuestionsMastered: Int {
        questionsMasteredCount
    }

    public var activeMistakeCount: Int {
        activeMistakeCount()
    }

    public var bestMockScore: Int? {
        mockExamHistory.map { $0.score }.max()
    }

    public var latestMockScore: Int? {
        mockExamHistory.first?.score
    }

    public var mockExamsPassedCount: Int {
        mockExamHistory.filter { $0.passed }.count
    }

    public func accuracy(for topic: TopicCategory) -> Int {
        let repo = QuestionRepository.shared
        let topicQuestionIds = Set(repo.questions(for: topic).map { $0.id })
        let relevant = questionProgressMap.values.filter { topicQuestionIds.contains($0.questionId) }

        let attempts = relevant.reduce(0) { $0 + $1.attempts }
        let correct = relevant.reduce(0) { $0 + $1.correctAttempts }

        guard attempts > 0 else { return 0 }
        return Int(Double(correct) / Double(attempts) * 100)
    }

    public func mastery(for topic: TopicCategory) -> Int {
        let repo = QuestionRepository.shared
        let topicQuestions = repo.questions(for: topic)
        guard !topicQuestions.isEmpty else { return 0 }

        let mastered = topicQuestions.filter { q in
            questionProgressMap[q.id]?.isMastered == true
        }.count

        return Int(Double(mastered) / Double(topicQuestions.count) * 100)
    }

    public func attemptsCount(for topic: TopicCategory) -> Int {
        let repo = QuestionRepository.shared
        let topicQuestionIds = Set(repo.questions(for: topic).map { $0.id })
        return questionProgressMap.values
            .filter { topicQuestionIds.contains($0.questionId) }
            .reduce(0) { $0 + $1.attempts }
    }

    public var examReadiness: ReadinessResult {
        ExamReadinessCalculator.calculate(
            progressStore: self,
            totalQuestionBankCount: QuestionRepository.shared.questions.count
        )
    }

    public func topicStats(for topic: TopicCategory) -> (total: Int, attempted: Int, mastered: Int, accuracy: Int, mistakes: Int) {
        let topicQuestions = QuestionRepository.shared.questions(for: topic)
        let total = topicQuestions.count
        var attempted = 0
        var mastered = 0
        var totalAttempts = 0
        var correctAttempts = 0

        for q in topicQuestions {
            if let p = questionProgressMap[q.id], p.attempts > 0 {
                attempted += 1
                if p.isMastered { mastered += 1 }
                totalAttempts += p.attempts
                correctAttempts += p.correctAttempts
            }
        }

        let accuracy = totalAttempts > 0 ? Int(Double(correctAttempts) / Double(totalAttempts) * 100) : 0
        let mistakes = mistakesMap.values.filter { $0.topic == topic && !$0.isResolved }.count

        return (total, attempted, mastered, accuracy, mistakes)
    }

    public var weakTopics: [TopicCategory] {
        TopicCategory.allCases.filter { topic in
            let stats = topicStats(for: topic)
            return (stats.attempted > 0 && stats.accuracy < 75) || stats.mistakes > 0
        }
    }

    public func resetAllProgress() {
        questionProgressMap.removeAll()
        mistakesMap.removeAll()
        mockExamHistory.removeAll()
        recentTopic = nil

        UserDefaults.standard.removeObject(forKey: questionProgressKey)
        UserDefaults.standard.removeObject(forKey: mistakesKey)
        UserDefaults.standard.removeObject(forKey: mockExamsKey)
        UserDefaults.standard.removeObject(forKey: recentTopicKey)

        DailyGoalManager.shared.resetAllDailyData()
    }
}
