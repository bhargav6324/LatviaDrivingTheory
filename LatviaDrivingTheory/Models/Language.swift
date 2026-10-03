import Foundation

public enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case latvian = "lv"
    case english = "en"

    public var id: String { rawValue }

    public var flag: String {
        switch self {
        case .latvian: return "🇱🇻"
        case .english: return "🇬🇧"
        }
    }

    public var displayName: String {
        switch self {
        case .latvian: return "Latviešu"
        case .english: return "English"
        }
    }

    public var subtitle: String {
        switch self {
        case .latvian: return "Latvian"
        case .english: return "English"
        }
    }
}
