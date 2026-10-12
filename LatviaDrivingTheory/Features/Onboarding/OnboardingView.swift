import SwiftUI

public struct OnboardingView: View {
    @ObservedObject var localization = LocalizationManager.shared
    @Binding var isPresented: Bool
    @State private var currentPage: Int = 0
    @State private var selectedLanguage: AppLanguage

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._selectedLanguage = State(initialValue: LocalizationManager.shared.currentLanguage)
    }

    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Language Switcher / Header Bar
                HStack {
                    if currentPage > 0 {
                        Button {
                            withAnimation {
                                currentPage -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                                .frame(width: 36, height: 36)
                                .background(AppColors.cardBackground)
                                .clipShape(Circle())
                        }
                    }

                    Spacer()

                    if currentPage > 0 {
                        Button {
                            let nextLang: AppLanguage = localization.currentLanguage == .latvian ? .english : .latvian
                            localization.setLanguage(nextLang)
                            selectedLanguage = nextLang
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .frame(height: 52)

                Spacer()

                if currentPage == 0 {
                    // SCREEN 0: Language Selection Screen
                    languageSelectionScreen
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                } else {
                    // SCREENS 1-3: Paged Feature Slides
                    TabView(selection: $currentPage) {
                        onboardingSlide(
                            tag: 1,
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
                            tag: 2,
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
                            tag: 3,
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
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }

                Spacer()

                // Bottom Action Button Stack
                VStack(spacing: 12) {
                    if currentPage == 0 {
                        Button {
                            localization.setLanguage(selectedLanguage)
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentPage = 1
                            }
                        } label: {
                            Text(selectedLanguage == .latvian ? "Turpināt" : "Continue")
                                .primaryButton(backgroundColor: AppColors.latviaCarmine)
                        }
                    } else {
                        Button {
                            if currentPage < 3 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                completeOnboarding()
                            }
                        } label: {
                            Text(currentPage < 3
                                 ? (localization.currentLanguage == .latvian ? "Tālāk" : "Continue")
                                 : (localization.currentLanguage == .latvian ? "Sākt mācīties" : "Get Started"))
                                .primaryButton(backgroundColor: AppColors.latviaCarmine)
                        }

                        if currentPage < 3 {
                            Button {
                                completeOnboarding()
                            } label: {
                                Text(localization.currentLanguage == .latvian ? "Izlaist" : "Skip")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Language Selection Step
    private var languageSelectionScreen: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 56))
                    .foregroundColor(AppColors.latviaCarmine)
                    .padding(.bottom, 4)

                Text(selectedLanguage == .latvian ? "Izvēlieties valodu" : "Choose Language")
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundColor(AppColors.textPrimary)

                Text("Izvēlieties valodu • Choose language")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 12)

            VStack(spacing: 14) {
                ForEach(AppLanguage.allCases) { lang in
                    let isSelected = selectedLanguage == lang
                    Button {
                        selectedLanguage = lang
                    } label: {
                        HStack(spacing: 16) {
                            Text(lang.flag)
                                .font(.system(size: 34))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(lang.displayName)
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                Text(lang.subtitle)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(AppColors.latviaCarmine)
                            }
                        }
                        .padding(18)
                        .background(isSelected ? AppColors.latviaCarmine.opacity(0.1) : AppColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(isSelected ? AppColors.latviaCarmine : AppColors.cardBorder, lineWidth: isSelected ? 2 : 1)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 20)
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

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "latvia_has_completed_onboarding_v1")
        withAnimation {
            isPresented = false
        }
    }
}
