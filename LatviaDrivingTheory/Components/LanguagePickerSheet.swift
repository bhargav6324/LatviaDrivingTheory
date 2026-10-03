import SwiftUI

public struct LanguagePickerSheet: View {
    @ObservedObject var localization = LocalizationManager.shared
    public var isDismissable: Bool
    public var onDismiss: (() -> Void)?

    public init(isDismissable: Bool = true, onDismiss: (() -> Void)? = nil) {
        self.isDismissable = isDismissable
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 44))
                    .foregroundColor(AppColors.latviaCarmine)
                    .padding(.top, 12)

                Text(localization.currentLanguage == .latvian ? "Izvēlieties valodu" : "Choose Language")
                    .font(.system(.title2, design: .rounded).bold())
                    .foregroundColor(AppColors.textPrimary)

                Text("Izvēlieties valodu • Choose language")
                    .font(.footnote)
                    .foregroundColor(AppColors.textSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 8)

            // Language Options
            VStack(spacing: 12) {
                ForEach(AppLanguage.allCases) { lang in
                    let isSelected = localization.currentLanguage == lang
                    Button {
                        localization.setLanguage(lang)
                        onDismiss?()
                    } label: {
                        HStack(spacing: 16) {
                            Text(lang.flag)
                                .font(.system(size: 32))

                            VStack(alignment: .leading, spacing: 2) {
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
                        .padding(16)
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
            .padding(.horizontal)

            Spacer()

            Button {
                localization.setLanguage(localization.currentLanguage)
                onDismiss?()
            } label: {
                Text(localization.currentLanguage == .latvian ? "Turpināt" : "Continue")
                    .primaryButton(backgroundColor: AppColors.latviaCarmine)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding()
        .background(AppColors.background.ignoresSafeArea())
    }
}
