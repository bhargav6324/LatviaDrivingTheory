import Foundation

/// Centralized repository of application constants, links, and contact information for Latvia Driving Theory.
public enum AppLinks {
    // Customer-facing Latvian branding
    public static let appNameLV = "CSDD Teorijas Eksāmens"
    public static let subtitleLV = "B kategorijas testa sagatavošana"
    public static let shortTitleLV = "CSDD Teorija"

    // English localization branding
    public static let appNameEN = "Latvia Driving Theory Test"
    public static let subtitleEN = "CSDD Category B Exam Prep"

    // Primary Support & Legal
    public static let supportEmail = "raxitsingh2002@gmail.com"
    public static let supportEmailMailto = "mailto:raxitsingh2002@gmail.com?subject=CSDD%20Teorijas%20Eksāmens%20Support"

    // Web URLs for App Store Connect & user support
    public static let marketingURL = "https://latviadrivingtheory.netlify.app"
    public static let supportURL = "https://latviadrivingtheory.netlify.app/support"
    public static let privacyURL = "https://latviadrivingtheory.netlify.app/privacy"
    public static let termsURL = "https://latviadrivingtheory.netlify.app/terms"

    // Placeholder for Apple App Store (updated upon App Store Connect provisioning)
    public static let appStoreURL = "#"

    // Bundle & StoreKit Identifiers
    public static let bundleID = "com.latviadriving.theory"

    // Primary StoreKit Product Identifiers
    public static let lifetimeProductID = StoreProducts.lifetime
    public static let monthlyProductID = StoreProducts.monthly

    public static let allProductIDs: [String] = [
        StoreProducts.lifetime,
        StoreProducts.monthly
    ]
}

/// Canonical StoreKit 2 product identifiers for Latvia Driving Theory
public enum StoreProducts {
    public static let lifetime = "lv.drivingtheory.pro.lifetime"
    public static let monthly = "lv.drivingtheory.pro.monthly"

    public static let all: Set<String> = [
        lifetime,
        monthly
    ]
}
