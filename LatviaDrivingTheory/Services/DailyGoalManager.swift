import Foundation
import Combine
import UserNotifications

/// Manages the daily study goal, activity calendar, streaks, and optional daily reminder for Latvia Driving Theory.
/// All data is stored locally in UserDefaults — no account or backend needed.
public final class DailyGoalManager: ObservableObject {
    public static let shared = DailyGoalManager()

    // MARK: - UserDefaults Keys
    private let dailyGoalKey      = "latvia_daily_goal_v1"
    private let dailyActivityKey  = "latvia_daily_activity_v1"
    private let notificationID    = "latvia_daily_study_reminder"

    // MARK: - Published State
    @Published public private(set) var goal: DailyGoal = .default
    @Published public private(set) var activityMap: [String: DailyActivity] = [:]

    // MARK: - Init
    private init() {
        loadGoal()
        loadActivity()
    }

    // MARK: - Persistence

    private func loadGoal() {
        if let data = UserDefaults.standard.data(forKey: dailyGoalKey),
           let decoded = try? JSONDecoder().decode(DailyGoal.self, from: data) {
            self.goal = decoded
        }
    }

    private func saveGoal() {
        if let data = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(data, forKey: dailyGoalKey)
        }
    }

    private func loadActivity() {
        if let data = UserDefaults.standard.data(forKey: dailyActivityKey),
           let decoded = try? JSONDecoder().decode([String: DailyActivity].self, from: data) {
            self.activityMap = decoded
        }
    }

    private func saveActivity() {
        if let data = try? JSONEncoder().encode(activityMap) {
            UserDefaults.standard.set(data, forKey: dailyActivityKey)
        }
    }

    // MARK: - Date Helpers

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    public static func dateKey(for date: Date = Date()) -> String {
        dateFormatter.string(from: date)
    }

    public static func date(from key: String) -> Date? {
        dateFormatter.date(from: key)
    }

    // MARK: - Recording Activity

    public func recordQuestionAnswered(isCorrect: Bool) {
        let key = DailyGoalManager.dateKey()
        var activity = activityMap[key] ?? DailyActivity(dateKey: key)
        activity.questionsAnswered += 1
        if isCorrect { activity.correctAnswers += 1 }
        activityMap[key] = activity
        saveActivity()
    }

    public func recordMockExamCompleted() {
        let key = DailyGoalManager.dateKey()
        var activity = activityMap[key] ?? DailyActivity(dateKey: key)
        activity.mockExamsCompleted += 1
        activityMap[key] = activity
        saveActivity()
    }

    // MARK: - Today's Goal Progress

    public var todayActivity: DailyActivity {
        activityMap[DailyGoalManager.dateKey()] ?? DailyActivity(dateKey: DailyGoalManager.dateKey())
    }

    public var todayQuestionsAnswered: Int {
        todayActivity.questionsAnswered
    }

    public var todayGoalReached: Bool {
        todayQuestionsAnswered >= goal.targetQuestions
    }

    public var todayProgressFraction: Double {
        guard goal.targetQuestions > 0 else { return 0 }
        return min(1.0, Double(todayQuestionsAnswered) / Double(goal.targetQuestions))
    }

    // MARK: - Study Streak

    public var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        let todayKey = DailyGoalManager.dateKey(for: checkDate)
        if let todayActivity = activityMap[todayKey], todayActivity.questionsAnswered >= goal.targetQuestions {
            streak = 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        } else {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        for _ in 0..<365 {
            let key = DailyGoalManager.dateKey(for: checkDate)
            guard let activity = activityMap[key], activity.questionsAnswered >= goal.targetQuestions else {
                break
            }
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        return streak
    }

    public func recentActivity(days: Int = 35) -> [DailyActivity] {
        let calendar = Calendar.current
        return (0..<days).reversed().compactMap { offset -> DailyActivity in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let key = DailyGoalManager.dateKey(for: date)
            return activityMap[key] ?? DailyActivity(dateKey: key)
        }
    }

    // MARK: - Goal Configuration

    public func updateGoal(targetQuestions: Int) {
        goal = DailyGoal(
            targetQuestions: targetQuestions,
            reminderEnabled: goal.reminderEnabled,
            reminderHour: goal.reminderHour,
            reminderMinute: goal.reminderMinute
        )
        saveGoal()
    }

    public func updateReminderTime(hour: Int, minute: Int) {
        goal = DailyGoal(
            targetQuestions: goal.targetQuestions,
            reminderEnabled: goal.reminderEnabled,
            reminderHour: hour,
            reminderMinute: minute
        )
        saveGoal()
        if goal.reminderEnabled {
            scheduleReminder()
        }
    }

    // MARK: - Reminder Management

    public func setReminderEnabled(_ enabled: Bool, completion: @escaping (Bool) -> Void) {
        if enabled {
            requestPermissionThenSchedule(completion: completion)
        } else {
            cancelReminder()
            goal = DailyGoal(
                targetQuestions: goal.targetQuestions,
                reminderEnabled: false,
                reminderHour: goal.reminderHour,
                reminderMinute: goal.reminderMinute
            )
            saveGoal()
            completion(true)
        }
    }

    private func requestPermissionThenSchedule(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted {
                    self.goal = DailyGoal(
                        targetQuestions: self.goal.targetQuestions,
                        reminderEnabled: true,
                        reminderHour: self.goal.reminderHour,
                        reminderMinute: self.goal.reminderMinute
                    )
                    self.saveGoal()
                    self.scheduleReminder()
                }
                completion(granted)
            }
        }
    }

    private func scheduleReminder() {
        cancelReminder()
        let content = UNMutableNotificationContent()
        content.title = LocalizationManager.shared.currentLanguage == .latvian ? AppLinks.appNameLV : AppLinks.appNameEN
        content.body = reminderBody()
        content.sound = .default

        var trigger = DateComponents()
        trigger.hour = goal.reminderHour
        trigger.minute = goal.reminderMinute

        let request = UNNotificationRequest(
            identifier: notificationID,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }

    private func reminderBody() -> String {
        switch LocalizationManager.shared.currentLanguage {
        case .latvian:
            return "Laiks šodienas CSDD teorijas treniņam! Sagatavojies eksāmenam pārliecinoši."
        case .english:
            return "Time for today's driving theory practice! Prepare with confidence."
        }
    }

    public func resetAllDailyData() {
        activityMap.removeAll()
        UserDefaults.standard.removeObject(forKey: dailyActivityKey)
    }
}
