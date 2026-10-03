import SwiftUI

/// Main 4-tab container for the Latvia Driving Theory application.
/// Provides access to Home, Practice, Progress, and Settings screens,
/// with seamless first-launch onboarding flow.
public struct RootView: View {
    @ObservedObject private var localization = LocalizationManager.shared
    @AppStorage("latvia_has_completed_onboarding_v1") private var hasCompletedOnboarding: Bool = false
    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView(isPresented: Binding(
                get: { !hasCompletedOnboarding },
                set: { hasCompletedOnboarding = !$0 }
            ))
            .transition(.opacity)
        } else {
            mainTabView
                .transition(.opacity)
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(localization.t(.tabHome), systemImage: "house.fill")
                }
                .tag(0)

            PracticeView()
                .tabItem {
                    Label(localization.t(.tabPractice), systemImage: "square.grid.2x2.fill")
                }
                .tag(1)

            ProgressView()
                .tabItem {
                    Label(localization.t(.tabProgress), systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label(localization.t(.tabSettings), systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(AppColors.latviaCarmine)
        .accentColor(AppColors.latviaCarmine)
    }
}
