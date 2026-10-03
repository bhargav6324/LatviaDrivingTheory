import SwiftUI
import StoreKit

/// Settings and preferences screen for Latvia Driving Theory ("CSDD Teorijas Eksāmens").
/// Provides access to language switching, Daily Goal settings, StoreKit Pro upgrade, restore purchases,
/// subscription management, support links, and legal disclaimers.
public struct SettingsView: View {
    @Environment(\.openURL) private var openURL

    @ObservedObject private var localization = LocalizationManager.shared
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var goalManager = DailyGoalManager.shared

    @State private var showPaywall = false
    @State private var showLanguagePicker = false
    @State private var showGoalSettings = false
    @State private var showResetAlert = false
    @State private var showRestoreAlert = false
    @State private var restoreAlertMessage = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Pro Status / Upgrade Banner
                    proStatusBanner

                    // Pro & Purchases Section
                    purchasesSection

                    // Study Preferences
                    studyPreferencesSection

                    // Data & Progress
                    dataSection

                    // About & Support
                    aboutSection

                    // Legal & Disclaimer
                    legalSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle(localization.t(.tabSettings))
            .sheet(isPresented: $showPaywall) {
                PremiumPaywallView()
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerSheet(isDismissable: true) {
                    showLanguagePicker = false
                }
            }
            .sheet(isPresented: $showGoalSettings) {
                DailyGoalSettingsView()
            }
            .alert(localization.t(.resetProgressTitle), isPresented: $showResetAlert) {
                Button(localization.t(.cancel), role: .cancel) {}
                Button(localization.t(.quitQuiz), role: .destructive) {
                    progressStore.resetAllProgress()
                }
            } message: {
                Text(localization.t(.resetProgressMessage))
            }
            .alert(localization.t(.restorePurchases), isPresented: $showRestoreAlert) {
                Button(localization.t(.ok), role: .cancel) {}
            } message: {
                Text(restoreAlertMessage)
            }
        }
    }

    // MARK: - Pro Banner

    private var proStatusBanner: some View {
        Group {
            if purchaseManager.isLifetimeOwned {
                // Lifetime Owned
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppColors.successGreen.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 26))
                            .foregroundColor(AppColors.successGreen)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(localization.t(.proLifetimeStatus))
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            Text(localization.t(.premiumActiveStatus).uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.successGreen)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        Text(localization.t(.lifetimeAccess))
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                }
                .padding(16)
                .appCard()
            } else if purchaseManager.isMonthlyActive {
                // Monthly Subscription Active
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.accentGold.opacity(0.15))
                                .frame(width: 50, height: 50)
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(AppColors.accentGold)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(localization.t(.proMonthlyStatus))
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                Text(localization.t(.premiumActiveStatus).uppercased())
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.accentGold)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            Text(localization.currentLanguage == .latvian
                                 ? "Abonements ir aktīvs"
                                 : "Monthly subscription active")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                    }

                    Button {
                        manageSubscriptionAction()
                    } label: {
                        HStack {
                            Image(systemName: "gearshape")
                            Text(localization.t(.manageSubscription))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(AppColors.cardBackgroundElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.cardBorder, lineWidth: 1)
                        )
                    }
                }
                .padding(16)
                .appCard()
            } else {
                // Free Plan (Not Pro)
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(localization.t(.proCardTitle))
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                Text(localization.t(.proInactiveStatus).uppercased())
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.textTertiary)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            Text(localization.t(.freePlanDescription))
                                .font(.footnote)
                                .foregroundColor(AppColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }

                    Button {
                        showPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text(localization.t(.upgradeToPro))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            LinearGradient(
                                colors: [AppColors.latviaCarmine, AppColors.latviaCarmineDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(16)
                .appCard()
            }
        }
    }

    // MARK: - Purchases Section
    private var purchasesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PRO")
                .font(.footnote.weight(.semibold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                // Current Plan Row
                HStack(spacing: 14) {
                    Image(systemName: purchaseManager.isPro ? "crown.fill" : "crown")
                        .font(.system(size: 18))
                        .foregroundColor(purchaseManager.isPro ? AppColors.accentGold : AppColors.textSecondary)
                        .frame(width: 28)

                    Text(localization.currentLanguage == .latvian ? "Pašreizējais plāns" : "Current Plan")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    let planText: String = {
                        if purchaseManager.isLifetimeOwned {
                            return localization.t(.proLifetimeStatus)
                        } else if purchaseManager.isMonthlyActive {
                            return localization.t(.proMonthlyStatus)
                        } else {
                            return localization.t(.proInactiveStatus)
                        }
                    }()

                    Text(planText)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(purchaseManager.isPro ? AppColors.latviaCarmine : AppColors.textSecondary)
                }
                .padding(14)

                Divider().padding(.leading, 42)

                // If not Pro, show "Iegūt PRO" / "Upgrade to Pro"
                if !purchaseManager.isPro {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.latviaCarmine)
                                .frame(width: 28)

                            Text(localization.currentLanguage == .latvian ? "Iegūt PRO" : "Get PRO")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .padding(14)
                    }

                    Divider().padding(.leading, 42)
                } else if purchaseManager.isMonthlyActive && !purchaseManager.isLifetimeOwned {
                    // If monthly, show "Pārvaldīt abonementu"
                    Button {
                        manageSubscriptionAction()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.latviaCarmine)
                                .frame(width: 28)

                            Text(localization.t(.manageSubscription))
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .padding(14)
                    }

                    Divider().padding(.leading, 42)
                }

                // Restore Purchases
                Button {
                    Task {
                        let restored = await purchaseManager.restorePurchases()
                        restoreAlertMessage = purchaseManager.restoreMessage
                            ?? (restored ? localization.t(.restorePurchasesSuccess) : localization.t(.restorePurchasesNotFound))
                        showRestoreAlert = true
                    }
                } label: {
                    HStack(spacing: 14) {
                        if purchaseManager.purchaseInProgress {
                            SwiftUI.ProgressView()
                                .frame(width: 28)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.latviaCarmine)
                                .frame(width: 28)
                        }

                        Text(localization.t(.restorePurchases))
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()
                    }
                    .padding(14)
                }
                .disabled(purchaseManager.purchaseInProgress)
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Study Preferences
    private var studyPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localization.t(.studyPreferences))
                .font(.footnote.weight(.semibold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                // Language
                Button {
                    showLanguagePicker = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "globe")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.latviaCarmine)
                            .frame(width: 28)

                        Text(localization.currentLanguage == .latvian ? "Valoda / Language" : "Language / Valoda")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        HStack(spacing: 6) {
                            Text(localization.currentLanguage.flag)
                            Text(localization.currentLanguage.displayName)
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                    .padding(14)
                }

                Divider().padding(.leading, 42)

                // Daily Goal & Reminder
                Button {
                    showGoalSettings = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "target")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.accentGold)
                            .frame(width: 28)

                        Text(localization.t(.dailyGoal))
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        HStack(spacing: 6) {
                            Text("\(goalManager.goal.targetQuestions) q/day")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                    .padding(14)
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Data Management
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localization.t(.progress))
                .font(.footnote.weight(.semibold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                Button {
                    showResetAlert = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.errorRed)
                            .frame(width: 28)

                        Text(localization.t(.resetProgressTitle))
                            .font(.subheadline)
                            .foregroundColor(AppColors.errorRed)

                        Spacer()
                    }
                    .padding(14)
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - About & Support
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localization.t(.about))
                .font(.footnote.weight(.semibold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                // App Name
                HStack(spacing: 14) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.latviaCarmine)
                        .frame(width: 28)

                    Text(localization.t(.appNameLabel))
                        .font(.subheadline)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Text(localization.currentLanguage == .latvian ? AppLinks.appNameLV : AppLinks.appNameEN)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(14)

                Divider().padding(.leading, 42)

                // Version
                HStack(spacing: 14) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 28)

                    Text(localization.t(.versionLabel))
                        .font(.subheadline)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
                    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                    Text("\(version) (\(build))")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(14)

                Divider().padding(.leading, 42)

                // Support Email
                if let emailURL = URL(string: AppLinks.supportEmailMailto) {
                    Link(destination: emailURL) {
                        HStack(spacing: 14) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.latviaCarmine)
                                .frame(width: 28)

                            Text(localization.t(.supportLabel))
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Text(AppLinks.supportEmail)
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)

                            Image(systemName: "arrow.up.right")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .padding(14)
                    }
                }

                Divider().padding(.leading, 42)

                // Support Website
                if let supportURL = URL(string: AppLinks.supportURL) {
                    Link(destination: supportURL) {
                        HStack(spacing: 14) {
                            Image(systemName: "safari.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.latviaCarmine)
                                .frame(width: 28)

                            Text(localization.t(.supportWebsiteLabel))
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .padding(14)
                    }
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Legal & Disclaimer
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localization.t(.legal))
                .font(.footnote.weight(.semibold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                // Privacy Policy
                if let privacyURL = URL(string: AppLinks.privacyURL) {
                    Link(destination: privacyURL) {
                        HStack(spacing: 14) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.textSecondary)
                                .frame(width: 28)

                            Text(localization.t(.privacyPolicyLabel))
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .padding(14)
                    }
                }

                Divider().padding(.leading, 42)

                // Terms of Use
                if let termsURL = URL(string: AppLinks.termsURL) {
                    Link(destination: termsURL) {
                        HStack(spacing: 14) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.textSecondary)
                                .frame(width: 28)

                            Text(localization.t(.termsOfUseLabel))
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .padding(14)
                    }
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )

            // Independent Study Tool Disclaimer Card
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .foregroundColor(AppColors.latviaCarmine)
                        .font(.subheadline)
                    Text(localization.t(.disclaimerLabel))
                        .font(.caption.weight(.bold))
                        .foregroundColor(AppColors.textPrimary)
                }

                Text(localization.t(.governmentDisclaimerText))
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            .padding(14)
            .background(AppColors.cardBackgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
            .padding(.top, 4)
        }
    }

    private func manageSubscriptionAction() {
        Task {
            #if os(iOS)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                do {
                    try await AppStore.showManageSubscriptions(in: windowScene)
                    return
                } catch {
                    #if DEBUG
                    print("showManageSubscriptions failed: \(error.localizedDescription)")
                    #endif
                }
            }
            #endif
            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                openURL(url)
            }
        }
    }
}
