import Foundation
import SwiftUI

public enum RoadSignCategory: String, CaseIterable, Identifiable, Codable {
    case warning = "warning"
    case priority = "priority"
    case prohibitory = "prohibitory"
    case mandatory = "mandatory"
    case information = "information"
    case service = "service"
    case additionalPlate = "additional_plate"

    public var id: String { rawValue }

    public func title(for language: AppLanguage) -> String {
        switch language {
        case .latvian:
            switch self {
            case .warning: return "Brīdinājuma zīmes"
            case .priority: return "Priekšrokas zīmes"
            case .prohibitory: return "Aizlieguma zīmes"
            case .mandatory: return "Rīkojuma zīmes"
            case .information: return "Norādījuma zīmes"
            case .service: return "Servisa zīmes"
            case .additionalPlate: return "Papildzīmes"
            }
        case .english:
            switch self {
            case .warning: return "Warning Signs"
            case .priority: return "Priority Signs"
            case .prohibitory: return "Prohibitory Signs"
            case .mandatory: return "Mandatory Signs"
            case .information: return "Information Signs"
            case .service: return "Service Signs"
            case .additionalPlate: return "Supplementary Plates"
            }
        }
    }
}

public enum SignShape: String, Codable {
    case triangleWarning // Upright red border, white inside
    case invertedTriangle // Give Way (206)
    case octagonStop // Stop sign (207)
    case diamondPriority // Priority Road (201)
    case circleProhibitory // Red border circle (301-326)
    case circleMandatory // Blue round circle (401-414)
    case squareBlue // Square blue information (501-532)
    case rectanglePlate // Supplementary plate (801-840)
}

public struct LocalizedSignContent: Codable {
    public var name: String
    public var meaning: String
    public var legalRule: String?

    public init(name: String, meaning: String, legalRule: String? = nil) {
        self.name = name
        self.meaning = meaning
        self.legalRule = legalRule
    }
}

public struct RoadSign: Identifiable, Codable {
    public var id: String
    public var code: String // e.g. "101", "201", "206", "207", "301", "326"
    public var category: RoadSignCategory
    public var shape: SignShape
    public var symbolType: String // e.g. "curve_right", "give_way", "stop", "speed_50", "pedestrian_cross"
    public var speedValue: Int?
    public var imageName: String?
    public var isPremium: Bool
    public var translations: [String: LocalizedSignContent]

    public init(
        id: String,
        code: String,
        category: RoadSignCategory,
        shape: SignShape,
        symbolType: String,
        speedValue: Int? = nil,
        imageName: String? = nil,
        isPremium: Bool = false,
        translations: [String: LocalizedSignContent]
    ) {
        self.id = id
        self.code = code
        self.category = category
        self.shape = shape
        self.symbolType = symbolType
        self.speedValue = speedValue
        self.imageName = imageName
        self.isPremium = isPremium
        self.translations = translations
    }

    enum CodingKeys: String, CodingKey {
        case id, code, category, shape, symbolType, speedValue, imageName, isPremium, translations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.code = try container.decode(String.self, forKey: .code)
        self.category = try container.decode(RoadSignCategory.self, forKey: .category)
        self.shape = try container.decode(SignShape.self, forKey: .shape)
        self.symbolType = try container.decode(String.self, forKey: .symbolType)
        self.speedValue = try container.decodeIfPresent(Int.self, forKey: .speedValue)
        self.imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
        self.isPremium = (try? container.decode(Bool.self, forKey: .isPremium)) ?? false
        self.translations = try container.decode([String: LocalizedSignContent].self, forKey: .translations)
    }

    public func content(for language: AppLanguage) -> LocalizedSignContent {
        if let direct = translations[language.rawValue] {
            return direct
        }
        if let latvian = translations[AppLanguage.latvian.rawValue] {
            return latvian
        }
        if let english = translations[AppLanguage.english.rawValue] {
            return english
        }
        return LocalizedSignContent(name: "Zīme \(code)", meaning: "")
    }

    public func name(for language: AppLanguage) -> String {
        content(for: language).name
    }

    public func meaning(for language: AppLanguage) -> String {
        content(for: language).meaning
    }

    public var latvianName: String {
        content(for: .latvian).name
    }

    public var englishName: String {
        content(for: .english).name
    }

    public var latvianExplanation: String {
        content(for: .latvian).meaning
    }

    public var englishExplanation: String {
        content(for: .english).meaning
    }
}
