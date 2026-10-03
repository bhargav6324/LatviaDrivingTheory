import SwiftUI

public enum AppColors {
    // Official Latvian Carmine Red & Modern UI Accents
    // National carmine red: #9E1B32 (RGB: 158, 27, 50)
    public static let latviaCarmine = Color(red: 0.620, green: 0.106, blue: 0.196) // #9E1B32
    public static let latviaCarmineDark = Color(red: 0.478, green: 0.078, blue: 0.141) // #7A1424
    public static let latviaCarmineLight = Color(red: 0.769, green: 0.169, blue: 0.271) // #C42B45
    public static let latviaCrimsonTint = Color(red: 0.620, green: 0.106, blue: 0.196).opacity(0.12)

    // Semantic Status Colors
    public static let successGreen = Color(red: 0.10, green: 0.72, blue: 0.45)
    public static let errorRed = Color(red: 0.93, green: 0.28, blue: 0.28)
    public static let warningAmber = Color(red: 0.96, green: 0.62, blue: 0.12)
    public static let accentGold = Color(red: 0.96, green: 0.72, blue: 0.15)
    public static let safetyPurple = Color(red: 0.55, green: 0.35, blue: 0.95)

    // Adaptive Backgrounds
    public static let background = Color(UIColor.systemGroupedBackground)
    public static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    public static let cardBackgroundElevated = Color(UIColor.tertiarySystemGroupedBackground)

    // Subtle Borders & Shadows
    public static let cardBorder = Color(UIColor.separator).opacity(0.4)
    public static let activeBorder = latviaCarmine.opacity(0.6)

    // Text & Subtitles
    public static let textPrimary = Color(UIColor.label)
    public static let textSecondary = Color(UIColor.secondaryLabel)
    public static let textTertiary = Color(UIColor.tertiaryLabel)
}

public extension Color {
    static let appCarmine = AppColors.latviaCarmine
    static let appAccent = AppColors.latviaCarmine
    static let appCardBg = AppColors.cardBackground
    static let appCardBorder = AppColors.cardBorder
    static let appSuccess = AppColors.successGreen
    static let appError = AppColors.errorRed
    static let appWarning = AppColors.warningAmber
}
