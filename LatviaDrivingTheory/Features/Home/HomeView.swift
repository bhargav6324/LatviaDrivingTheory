import SwiftUI

public enum HomeRoute: Hashable {
    case topic(TopicCategory)
    case mockExam
    case myMistakes
    case roadSigns
    case allTopics
}

public struct HomeView: View {
    @ObservedObject private var localization = LocalizationManager.shared
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var premium = PremiumAccessManager.shared
    @State private var navigationPath = NavigationPath()
    @State private var showLanguagePicker = false

    public init() {}

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Branding & Language Switcher
                    headerView

                    // 1. Exam Readiness Card
                    examReadinessCard

                    // 2. Continue Learning Card
                    continueLearningCard

                    // 3. Main Action Grid
                    mainActionsGrid

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .topic(let category):
                    TopicDetailView(topic: category)
                case .mockExam:
                    MockExamIntroView()
                case .myMistakes:
                    MyMistakesView()
                case .roadSigns:
                    RoadSignsView()
                case .allTopics:
                    PracticeView()
                }
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerSheet()
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            AppLogoView(size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(localization.currentLanguage == .latvian ? AppLinks.appNameLV : AppLinks.appNameEN)
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                Text(localization.t(.categoryB))
                    .font(.subheadline)
                    .foregroundColor(AppColors.latviaCarmine)
                    .fontWeight(.medium)
            }

            Spacer()

            // Language Selector Button
            Button {
                showLanguagePicker = true
            } label: {
                HStack(spacing: 6) {
                    Text(localization.currentLanguage.flag)
                        .font(.headline)
                    Text(localization.currentLanguage.displayName)
                        .font(.system(.caption, design: .rounded).bold())
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColors.cardBackground)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
            }
        }
        .padding(.top, 8)
    }

    // MARK: - 1. Exam Readiness Card
    private var examReadinessCard: some View {
        let readiness = progressStore.examReadiness

        return VStack(spacing: 16) {
            HStack(spacing: 18) {
                CircularProgressView(
                    progress: Double(readiness.percentage ?? 0) / 100.0,
                    lineWidth: 10,
                    tintColor: AppColors.latviaCarmine,
                    labelText: readiness.hasEnoughData ? "\(readiness.percentage!)%" : "—"
                )
                .frame(width: 82, height: 82)

                VStack(alignment: .leading, spacing: 4) {
                    Text(localization.t(.examReadiness))
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundColor(AppColors.textPrimary)

                    Text(readiness.hasEnoughData
                         ? localization.t(.examReadinessExplanation)
                         : localization.t(.examReadinessNotEnoughData))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
            }

            Divider()

            // Compact goal + streak + mastered strip
            HomeProgressSummaryView()
        }
        .appCard(padding: 18)
    }

    // MARK: - 2. Continue Learning Card
    private var continueLearningCard: some View {
        let accessibleTopics = TopicCategory.allCases.filter { premium.hasAccessibleQuestions(for: $0) }
        let resumeTopic = progressStore.recentTopic.flatMap { accessibleTopics.contains($0) ? $0 : nil } ?? accessibleTopics.first ?? .rightOfWay

        return NavigationLink(value: HomeRoute.topic(resumeTopic)) {
            HStack(spacing: 16) {
                TopicIconView(topic: resumeTopic, size: 24, color: .white)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(localization.t(.continuePractice))
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(resumeTopic.title(for: localization.currentLanguage))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [AppColors.latviaCarmine, AppColors.latviaCarmineDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: AppColors.latviaCarmine.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - 3. Main Action Grid
    private var mainActionsGrid: some View {
        VStack(spacing: 14) {
            // Mock Exam
            NavigationLink(value: HomeRoute.mockExam) {
                let subtitle: String = {
                    if premium.isPremium {
                        return localization.t(.mockExamSubtitle)
                    } else if premium.hasCompletedFreeMock {
                        return localization.currentLanguage == .latvian ? "Bezmaksas eksāmens pabeigts • Atbloķēt Pro" : "Free mock completed • Tap to unlock"
                    } else {
                        return localization.currentLanguage == .latvian ? "1 bezmaksas testa eksāmens pieejams" : "1 Free Mock Exam Available"
                    }
                }()

                return mainActionRow(
                    icon: "doc.text.fill",
                    iconColor: AppColors.latviaCarmine,
                    title: localization.t(.mockExamTitle),
                    subtitle: subtitle
                )
            }

            // My Mistakes
            NavigationLink(value: HomeRoute.myMistakes) {
                let mistakeCount = progressStore.activeMistakeCount(filteredBy: premium.isPremium ? nil : Set(premium.freeQuestionIDs))

                return HStack(spacing: 14) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundColor(AppColors.errorRed)
                        .frame(width: 42, height: 42)
                        .background(AppColors.errorRed.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(localization.t(.myMistakesTitle))
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text(localization.t(.myMistakesSubtitle))
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    if mistakeCount > 0 {
                        Text("\(mistakeCount)")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppColors.errorRed)
                            .clipShape(Capsule())
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundColor(AppColors.textTertiary)
                }
                .appCard(padding: 16)
            }

            // Road Signs
            NavigationLink(value: HomeRoute.roadSigns) {
                mainActionRow(
                    icon: "shield.fill",
                    iconColor: AppColors.warningAmber,
                    title: localization.t(.roadSignsTitle),
                    subtitle: localization.t(.roadSignsSubtitle)
                )
            }

            // Topic Practice
            NavigationLink(value: HomeRoute.allTopics) {
                mainActionRow(
                    icon: "square.grid.2x2.fill",
                    iconColor: AppColors.safetyPurple,
                    title: localization.t(.practiceQuestionsTitle),
                    subtitle: localization.t(.practiceQuestionsSubtitle)
                )
            }
        }
    }

    private func mainActionRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 42, height: 42)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(AppColors.textTertiary)
        }
        .appCard(padding: 16)
    }
}
