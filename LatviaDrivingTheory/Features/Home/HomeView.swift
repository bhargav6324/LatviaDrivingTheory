import SwiftUI

public enum HomeRoute: Hashable {
    case topic(TopicCategory)
    case mockExam
    case myMistakes
    case roadSigns
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

                    // 2. Continue Learning Card (ONLY shown if unfinished practice session exists)
                    if let resumeTopic = progressStore.incompletePracticeTopic {
                        continueLearningCard(for: resumeTopic)
                    }

                    // 3. Main Action Cards (Mock Exam, My Mistakes, Road Signs)
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
                }
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerSheet(isDismissable: true) {
                    showLanguagePicker = false
                }
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            AppLogoView(size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(localization.currentLanguage == .latvian ? AppLinks.appNameLV : "Latvia Driving Theory")
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

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
    private func continueLearningCard(for topic: TopicCategory) -> some View {
        let accessibleTopics = TopicCategory.allCases.filter { premium.hasAccessibleQuestions(for: $0) }
        let resumeTopic = accessibleTopics.contains(topic) ? topic : (accessibleTopics.first ?? topic)

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

                homeActionCard(
                    icon: "doc.text.fill",
                    iconColor: AppColors.latviaCarmine,
                    title: localization.t(.mockExamTitle),
                    subtitle: subtitle
                )
            }
            .buttonStyle(PlainButtonStyle())

            // My Mistakes
            NavigationLink(value: HomeRoute.myMistakes) {
                let mistakeCount = progressStore.activeMistakeCount(filteredBy: premium.isPremium ? nil : Set(premium.freeQuestionIDs))

                homeActionCard(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: AppColors.errorRed,
                    title: localization.t(.myMistakesTitle),
                    subtitle: localization.t(.myMistakesSubtitle),
                    badgeCount: mistakeCount > 0 ? mistakeCount : nil,
                    badgeColor: AppColors.errorRed
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Road Signs
            NavigationLink(value: HomeRoute.roadSigns) {
                homeActionCard(
                    icon: "shield.fill",
                    iconColor: AppColors.warningAmber,
                    title: localization.t(.roadSignsTitle),
                    subtitle: localization.t(.roadSignsSubtitle)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // Standardized Reusable Home Action Card Component
    private func homeActionCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        badgeCount: Int? = nil,
        badgeColor: Color = AppColors.errorRed
    ) -> some View {
        HStack(spacing: 14) {
            // Unified Icon Container (44x44, 12pt corner radius)
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            .frame(width: 44, height: 44)

            // Leading-Aligned Text Stack
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Trailing Content: optional badge + vertically centered chevron
            HStack(spacing: 8) {
                if let count = badgeCount, count > 0 {
                    Text("\(count)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(badgeColor)
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}
