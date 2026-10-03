import SwiftUI

/// Displays the authentic Latvia Driving Theory app logo.
public struct AppLogoView: View {
    public var size: CGFloat
    public var cornerRadius: CGFloat

    public init(size: CGFloat = 72, cornerRadius: CGFloat? = nil) {
        self.size = size
        self.cornerRadius = cornerRadius ?? (size * 0.22)
    }

    public var body: some View {
        Group {
            if let image = UIImage(named: "AppLogo") ?? UIImage(named: "AppIcon") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                // High-quality fallback vector emblem in Latvian carmine red
                ZStack {
                    LinearGradient(
                        colors: [AppColors.latviaCarmine, AppColors.latviaCarmineDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    VStack(spacing: 2) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: size * 0.42, weight: .bold))
                            .foregroundColor(.white)
                        Text("CSDD")
                            .font(.system(size: size * 0.20, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.95))
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
    }
}
