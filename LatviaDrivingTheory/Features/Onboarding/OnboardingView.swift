import SwiftUI

public struct OnboardingView: View {
    @ObservedObject var localization = LocalizationManager.shared
    @Binding var isPresented: Bool
    @State private var currentPage: Int = 0

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Language Switcher
                HStack {
                    Spacer()
                    Button {
                        let nextLang: AppLanguage = localization.currentLanguage == .latvian ? .english : .latvian
                        localization.setLanguage(nextLang)
                    } label: {
                        HStack(spacing: 6) {
                            Text(localization.currentLanguage.flag)
                            Text(localization.currentLanguage.displayName)
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.cardBackground)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // Paged Content
                TabView(selection: $currentPage) {
                    onboardingSlide(
                        tag: 0,
                        iconName: "car.side.fill",
                        isCustomLogo: true,
                        title: localization.currentLanguage == .latvian
                            ? "CSDD B kategorijas teorijas eksāmens"
                            : "CSDD Category B Theory Exam",
                        subtitle: localization.currentLanguage == .latvian
                            ? "Mērķtiecīga un moderna sagatavošanās Latvijas autovadītāja teorijas eksāmenam."
                            : "Focused, modern preparation for the Latvian driver's license theory examination."
                    )

                    onboardingSlide(
                        tag: 1,
                        iconName: "lightbulb.fill",
                        isCustomLogo: false,
                        title: localization.currentLanguage == .latvian
                            ? "Izproti noteikumu, ne tikai atbildi"
                            : "Understand the rule, not just the answer",
                        subtitle: localization.currentLanguage == .latvian
                            ? "Katram jautājumam ir skaidrojums un atsauce uz Ceļu satiksmes noteikumiem (CSN)."
                            : "Every practice question includes in-depth rule explanations and legal references."
                    )

                    onboardingSlide(
                        tag: 2,
                        iconName: "checkmark.seal.fill",
                        isCustomLogo: false,
                        title: localization.currentLanguage == .latvian
                            ? "Reāls testa eksāmens un kļūdu labošana"
                            : "Real exam simulation & mistake review",
                        subtitle: localization.currentLanguage == .latvian
                            ? "30 jautājumi, 30 minūtes un personīgā sadaļa 'Manas kļūdas' vājo vietu nostiprināšanai."
                            : "30 questions, 30 minutes, and dedicated 'My Mistakes' review to conquer weak areas."
                    )
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 420)

                Spacer()

                // Bottom Action
                VStack(spacing: 12) {
                    Button {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            UserDefaults.standard.set(true, forKey: "latvia_has_completed_onboarding_v1")
                            withAnimation {
                                isPresented = false
                            }
                        }
                    } label: {
                        Text(currentPage < 2
                             ? (localization.currentLanguage == .latvian ? "Tālāk" : "Continue")
                             : (localization.currentLanguage == .latvian ? "Sākt mācīties" : "Get Started"))
                            .primaryButton(backgroundColor: AppColors.latviaCarmine)
                    }

                    if currentPage < 2 {
                        Button {
                            UserDefaults.standard.set(true, forKey: "latvia_has_completed_onboarding_v1")
                            withAnimation {
                                isPresented = false
                            }
                        } label: {
                            Text(localization.currentLanguage == .latvian ? "Izlaist" : "Skip")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private func onboardingSlide(tag: Int, iconName: String, isCustomLogo: Bool, title: String, subtitle: String) -> some View {
        VStack(spacing: 24) {
            if isCustomLogo {
                AppLogoView(size: 96)
                    .padding(.bottom, 8)
            } else {
                ZStack {
                    Circle()
                        .fill(AppColors.latviaCarmine.opacity(0.12))
                        .frame(width: 96, height: 96)
                    Image(systemName: iconName)
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundColor(AppColors.latviaCarmine)
                }
                .padding(.bottom, 8)
            }

            VStack(spacing: 12) {
                Text(title)
                    .font(.system(.title2, design: .rounded).bold())
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text(subtitle)
                    .font(.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(3)
            }
        }
        .tag(tag)
    }
}
