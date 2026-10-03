import SwiftUI
import StoreKit

public enum PaywallTier {
    case lifetime
    case monthly
}

/// StoreKit 2 paywall for Latvia Driving Theory ("CSDD Teorijas Eksāmens") with dual-product support:
/// 1. PRO uz mūžu (Non-Consumable IAP)
/// 2. PRO mēnesim (Auto-Renewable Subscription)
public struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @ObservedObject private var localization = LocalizationManager.shared
    @ObservedObject private var purchaseManager = PurchaseManager.shared

    public var customBannerMessage: String?
    public var onPurchaseSuccess: (() -> Void)?

    @State private var selectedTier: PaywallTier = .lifetime
    @State private var showSuccessAlert = false
    @State private var successAlertMessage = ""
    @State private var showRestoreAlert = false
    @State private var restoreAlertMessage = ""
    @State private var showTermsSheet = false
    @State private var showPrivacySheet = false

    public init(customBannerMessage: String? = nil, onPurchaseSuccess: (() -> Void)? = nil) {
        self.customBannerMessage = customBannerMessage
        self.onPurchaseSuccess = onPurchaseSuccess
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Branding & Badge
                    headerSection

                    // Contextual Banner (if presented with a specific trigger reason)
                    if let banner = customBannerMessage {
                        contextualBanner(banner)
                    }

                    // Pro State or Purchase Cards
                    if purchaseManager.isLifetimeOwned {
                        alreadyLifetimeOwnedView
                    } else if purchaseManager.isMonthlyActive {
                        monthlyActiveView
                    } else {
                        // Standard paywall: Benefits List + 2 Purchase Cards
                        benefitsSection
                        purchaseCardsSection
                        actionButtonsSection
                    }

                    // Legal links and disclaimers
                    footerSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(AppColors.textSecondary)
                            .font(.title3)
                    }
                }
            }
            .task {
                if purchaseManager.lifetimeProduct == nil || purchaseManager.monthlyProduct == nil {
                    await purchaseManager.loadProducts()
                }
            }
            .alert(localization.currentLanguage == .latvian ? "PRO atbloķēts!" : "PRO Unlocked!", isPresented: $showSuccessAlert) {
                Button(localization.t(.ok)) {
                    dismiss()
                    onPurchaseSuccess?()
                }
            } message: {
                Text(successAlertMessage)
            }
            .alert(localization.t(.restorePurchases), isPresented: $showRestoreAlert) {
                Button(localization.t(.ok), role: .cancel) {}
            } message: {
                Text(restoreAlertMessage)
            }
            .sheet(isPresented: $showTermsSheet) {
                termsSheet
            }
            .sheet(isPresented: $showPrivacySheet) {
                privacySheet
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.latviaCarmine.opacity(0.18), AppColors.accentGold.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 82, height: 82)

                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.accentGold, AppColors.latviaCarmine],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 6) {
                Text(localization.currentLanguage == .latvian
                     ? "Sagatavojies eksāmenam pārliecinoši"
                     : "Prepare with confidence")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(localization.currentLanguage == .latvian
                     ? "Pilna piekļuve visiem jautājumiem, eksāmeniem un skaidrojumiem."
                     : "Full access to all questions, mock exams, and explanations.")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Contextual Banner
    private func contextualBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundColor(AppColors.latviaCarmine)
                .font(.headline)
            Text(message)
                .font(.footnote)
                .foregroundColor(AppColors.textPrimary)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(AppColors.latviaCarmine.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Benefits Section
    private var benefitsSection: some View {
        VStack(spacing: 10) {
            benefitRow(icon: "checkmark.circle.fill", text: localization.t(.paywallBenefit1))
            benefitRow(icon: "checkmark.circle.fill", text: localization.t(.paywallBenefit2))
            benefitRow(icon: "checkmark.circle.fill", text: localization.t(.paywallBenefit3))
            benefitRow(icon: "checkmark.circle.fill", text: localization.t(.paywallBenefit4))
            benefitRow(icon: "checkmark.circle.fill", text: localization.t(.paywallBenefit5))
            benefitRow(icon: "checkmark.circle.fill", text: localization.t(.paywallBenefit6))
            benefitRow(icon: "checkmark.circle.fill", text: localization.t(.paywallBenefit7))
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppColors.successGreen)

            Text(text)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)

            Spacer()
        }
    }

    // MARK: - Purchase Cards (Card 1: Lifetime, Card 2: Monthly)
    private var purchaseCardsSection: some View {
        Group {
            if !purchaseManager.hasLoadedProducts {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(AppColors.latviaCarmine)
                    Text(localization.currentLanguage == .latvian ? "Ielādē StoreKit produktus..." : "Loading StoreKit products...")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else if purchaseManager.lifetimeProduct == nil && purchaseManager.monthlyProduct == nil {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(AppColors.accentGold)
                    Text(localization.t(.purchasesUnavailable))
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 12) {
                    // CARD 1 — LIFETIME
                    if let lifetime = purchaseManager.lifetimeProduct {
                        Button {
                            selectedTier = .lifetime
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text(localization.t(.proLifetimeTitle))
                                            .font(.headline)
                                            .foregroundColor(AppColors.textPrimary)

                                        Text(localization.t(.proBestValueBadge))
                                            .font(.system(size: 10, weight: .bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(AppColors.accentGold)
                                            .foregroundColor(.white)
                                            .clipShape(Capsule())
                                    }

                                    Text(localization.t(.proLifetimeSubtitle))
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(lifetime.displayPrice)
                                        .font(.title3.bold())
                                        .foregroundColor(AppColors.textPrimary)
                                }

                                Image(systemName: selectedTier == .lifetime ? "largecircle.fill.circle" : "circle")
                                    .font(.title3)
                                    .foregroundColor(selectedTier == .lifetime ? AppColors.latviaCarmine : AppColors.textTertiary)
                            }
                            .padding(16)
                            .background(AppColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        selectedTier == .lifetime ? AppColors.latviaCarmine : AppColors.cardBorder,
                                        lineWidth: selectedTier == .lifetime ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // CARD 2 — MONTHLY
                    if let monthly = purchaseManager.monthlyProduct {
                        Button {
                            selectedTier = .monthly
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(localization.t(.proMonthlyTitle))
                                        .font(.headline)
                                        .foregroundColor(AppColors.textPrimary)

                                    Text(localization.currentLanguage == .latvian
                                         ? "Automātiska ikmēneša atjaunošana"
                                         : "Auto-renewing monthly subscription")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(monthly.displayPrice) \(localization.t(.proMonthlyPerMonth))")
                                        .font(.subheadline.bold())
                                        .foregroundColor(AppColors.textPrimary)
                                }

                                Image(systemName: selectedTier == .monthly ? "largecircle.fill.circle" : "circle")
                                    .font(.title3)
                                    .foregroundColor(selectedTier == .monthly ? AppColors.latviaCarmine : AppColors.textTertiary)
                            }
                            .padding(16)
                            .background(AppColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        selectedTier == .monthly ? AppColors.latviaCarmine : AppColors.cardBorder,
                                        lineWidth: selectedTier == .monthly ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var isPurchaseEnabled: Bool {
        if selectedTier == .lifetime {
            return purchaseManager.lifetimeProduct != nil
        } else {
            return purchaseManager.monthlyProduct != nil
        }
    }

    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Main Purchase CTA
            Button {
                handlePurchase()
            } label: {
                HStack(spacing: 8) {
                    if purchaseManager.purchaseInProgress {
                        ProgressView()
                            .tint(.white)
                    } else {
                        let cta = selectedTier == .lifetime
                            ? localization.t(.proLifetimeCTA)
                            : localization.t(.proMonthlyCTA)
                        Text(cta)
                            .font(.headline.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isPurchaseEnabled ? AppColors.latviaCarmine : AppColors.textTertiary.opacity(0.4))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: isPurchaseEnabled ? AppColors.latviaCarmine.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
            }
            .disabled(purchaseManager.purchaseInProgress || !isPurchaseEnabled)

            // Monthly Subscription Disclosure
            if selectedTier == .monthly && purchaseManager.monthlyProduct != nil {
                Text(localization.t(.proSubscriptionNotice))
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 8)
            }

            if let error = purchaseManager.purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(AppColors.errorRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Restore Purchases Action
            Button {
                handleRestore()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text(localization.t(.restorePurchases))
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(AppColors.latviaCarmine)
            }
            .disabled(purchaseManager.purchaseInProgress)
            .padding(.top, 4)
        }
    }

    // MARK: - Lifetime Already Owned View
    private var alreadyLifetimeOwnedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 54))
                .foregroundColor(AppColors.successGreen)

            VStack(spacing: 6) {
                Text(localization.t(.proLifetimeActiveStatus))
                    .font(.title3.bold())
                    .foregroundColor(AppColors.textPrimary)

                Text(localization.t(.proAlreadyLifetimeMessage))
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                dismiss()
            } label: {
                Text(localization.t(.done))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.latviaCarmine)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Monthly Active View (Allows Upgrade to Lifetime or Manage Subscription)
    private var monthlyActiveView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppColors.accentGold)

            VStack(spacing: 6) {
                Text(localization.t(.proActiveStatus))
                    .font(.title3.bold())
                    .foregroundColor(AppColors.textPrimary)

                Text(localization.t(.proMonthlyStatus))
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }

            // Manage Subscription button
            Button {
                manageSubscriptionAction()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape")
                    Text(localization.t(.manageSubscription))
                }
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppColors.cardBackgroundElevated)
                .foregroundColor(AppColors.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )
            }

            Divider().padding(.vertical, 4)

            // Option to upgrade permanently to Lifetime
            VStack(spacing: 8) {
                Text(localization.t(.upgradeToLifetimePrompt))
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                let priceStr = purchaseManager.lifetimeDisplayPrice.map { " (\($0))" } ?? ""
                Text(localization.currentLanguage == .latvian
                     ? "Pārejiet uz vienreizēju pirkumu un atceliet ikmēneša maksājumus\(priceStr)."
                     : "Switch to a permanent one-time purchase without monthly renewal\(priceStr).")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    Task {
                        let success = await purchaseManager.purchaseLifetime()
                        if success {
                            await MainActor.run {
                                successAlertMessage = localization.currentLanguage == .latvian
                                    ? "PRO uz mūžu ir veiksmīgi aktivizēts!"
                                    : "PRO Lifetime has been successfully unlocked!"
                                showSuccessAlert = true
                            }
                        }
                    }
                } label: {
                    Text(localization.t(.proLifetimeCTA))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.latviaCarmine)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(purchaseManager.purchaseInProgress)
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Footer & Legal Links
    private var footerSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                Button(localization.t(.termsOfService)) {
                    showTermsSheet = true
                }
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)

                Text("•")
                    .foregroundColor(AppColors.textTertiary)

                Button(localization.t(.privacyPolicy)) {
                    showPrivacySheet = true
                }
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
            }

            Text(localization.currentLanguage == .latvian
                 ? "Neatkarīgs mācību līdzeklis • Nav saistīts ar CSDD"
                 : "Independent study tool • Not affiliated with CSDD")
                .font(.system(size: 11))
                .foregroundColor(AppColors.textTertiary)
                .padding(.top, 4)
        }
        .padding(.top, 8)
    }

    // MARK: - Purchase Logic
    private func handlePurchase() {
        Task {
            let success: Bool
            if selectedTier == .lifetime {
                success = await purchaseManager.purchaseLifetime()
            } else {
                success = await purchaseManager.purchaseMonthly()
            }

            if success || purchaseManager.isPro {
                await MainActor.run {
                    successAlertMessage = localization.currentLanguage == .latvian
                        ? "Paldies! Pilna piekļuve visiem jautājumiem, testiem un materiāliem ir aktivizēta."
                        : "Thank you! Full access to all questions, mock exams, and tools is now active."
                    showSuccessAlert = true
                }
            }
        }
    }

    private func handleRestore() {
        Task {
            let restored = await purchaseManager.restorePurchases()
            await MainActor.run {
                restoreAlertMessage = purchaseManager.restoreMessage
                    ?? (restored ? localization.t(.restorePurchasesSuccess) : localization.t(.restorePurchasesNotFound))
                showRestoreAlert = true
            }
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

    // MARK: - Legal Sheets
    private var privacySheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(localization.t(.privacyPolicy))
                        .font(.title2.bold())
                        .foregroundColor(AppColors.textPrimary)

                    Text("Šī lietotne saglabā visus mācību datus lokāli jūsu ierīcē. Pirkumi tiek apstrādāti droši caur Apple StoreKit 2 platformu, izmantojot jūsu Apple ID. Mēs neuzglabājam nekādus lietotāju kontus un neuzturam ārējus serverus.")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(4)
                }
                .padding(24)
            }
            .background(AppColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.t(.done)) { showPrivacySheet = false }
                }
            }
        }
    }

    private var termsSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(localization.t(.termsOfService))
                        .font(.title2.bold())
                        .foregroundColor(AppColors.textPrimary)

                    Text("Visi mācību jautājumi, ceļa zīmju skaidrojumi un testa materiāli ir oriģināls izglītojošs saturs Latvijas B kategorijas teorijas apguvei. Maksājumi tiek veikti caur Apple ID. Auto-atjaunojamo ikmēneša abonementu var pārvaldīt vai atcelt jebkurā laikā Apple konta iestatījumos.")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(4)
                }
                .padding(24)
            }
            .background(AppColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.t(.done)) { showTermsSheet = false }
                }
            }
        }
    }
}
