import Foundation
import SwiftUI

public enum TopicCategory: String, CaseIterable, Identifiable, Codable {
    case rightOfWay = "right_of_way"
    case intersections = "intersections"
    case trafficLights = "traffic_lights"
    case roadSigns = "road_signs"
    case roadMarkings = "road_markings"
    case speedAndDistance = "speed_and_distance"
    case overtaking = "overtaking"
    case stoppingAndParking = "stopping_and_parking"
    case pedestriansAndCyclists = "pedestrians_and_cyclists"
    case publicTransport = "public_transport"
    case laneSelection = "lane_selection"
    case vehicleSafety = "vehicle_safety"
    case driverResponsibilities = "driver_responsibilities"
    case alcoholAndProhibitions = "alcohol_and_prohibitions"
    case hazards = "hazards"
    case motorways = "motorways"
    case emergencyAndFirstAid = "emergency_and_first_aid"
    case railwayCrossings = "railway_crossings"
    case ecoDriving = "eco_driving"

    public var id: String { rawValue }

    public static var allCases: [TopicCategory] {
        [
            .rightOfWay,
            .intersections,
            .trafficLights,
            .roadSigns,
            .roadMarkings,
            .speedAndDistance,
            .overtaking,
            .stoppingAndParking,
            .pedestriansAndCyclists,
            .publicTransport,
            .laneSelection,
            .vehicleSafety,
            .driverResponsibilities,
            .alcoholAndProhibitions,
            .hazards,
            .motorways,
            .emergencyAndFirstAid,
            .railwayCrossings,
            .ecoDriving
        ]
    }

    public init?(canonical: String) {
        let normalized = canonical
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        switch normalized {
        case "right_of_way", "priority", "priority_rules":
            self = .rightOfWay
        case "intersections", "krustojumi":
            self = .intersections
        case "road_signs", "signs", "cela_zimes":
            self = .roadSigns
        case "road_markings", "markings", "cela_apzimejumi":
            self = .roadMarkings
        case "speed_and_distance", "speed_distance", "speed", "atrums":
            self = .speedAndDistance
        case "overtaking", "overtake", "apdzisana":
            self = .overtaking
        case "stopping_and_parking", "stopping_parking", "parking", "stavesana":
            self = .stoppingAndParking
        case "pedestrians_and_cyclists", "pedestrians_cyclists", "pedestrians", "gajeji":
            self = .pedestriansAndCyclists
        case "public_transport", "tram", "sabiedriskais_transports":
            self = .publicTransport
        case "lane_selection", "lane_positioning", "joslas":
            self = .laneSelection
        case "vehicle_safety", "safety", "vehicle", "tehniskais_stavoklis":
            self = .vehicleSafety
        case "driver_responsibilities", "driver_duties", "vaditaja_pienakumi":
            self = .driverResponsibilities
        case "alcohol_and_prohibitions", "alcohol", "alkohols":
            self = .alcoholAndProhibitions
        case "hazards", "hazard_awareness", "bistamiba":
            self = .hazards
        case "motorways", "motorway_driving", "atrgaitas_celi":
            self = .motorways
        case "emergency_and_first_aid", "emergency", "pirma_palidziba":
            self = .emergencyAndFirstAid
        case "railway_crossings", "railway", "dzelzcels":
            self = .railwayCrossings
        case "traffic_lights", "traffic_lights_signals", "traffic_light", "luksofors":
            self = .trafficLights
        case "eco_driving", "safe_driving", "eko_brauksana":
            self = .ecoDriving
        default:
            return nil
        }
    }

    public var iconName: String {
        switch self {
        case .rightOfWay: return "arrow.triangle.swap"
        case .intersections: return "point.topleft.down.to.point.bottomright.curvepath"
        case .trafficLights: return "circle.grid.3x1.fill"
        case .roadSigns: return "shield.fill"
        case .roadMarkings: return "road.lanes"
        case .speedAndDistance: return "gauge.with.needle.fill"
        case .overtaking: return "arrow.left.and.right.circle.fill"
        case .stoppingAndParking: return "parkingsign.circle.fill"
        case .pedestriansAndCyclists: return "figure.walk"
        case .publicTransport: return "tram.fill"
        case .laneSelection: return "arrow.up.and.down.and.sparkles"
        case .vehicleSafety: return "wrench.and.screwdriver.fill"
        case .driverResponsibilities: return "person.badge.shield.checkmark.fill"
        case .alcoholAndProhibitions: return "nosign"
        case .hazards: return "exclamationmark.triangle.fill"
        case .motorways: return "speedometer"
        case .emergencyAndFirstAid: return "cross.case.fill"
        case .railwayCrossings: return "tram.circle.fill"
        case .ecoDriving: return "leaf.fill"
        }
    }

    public func title(for language: AppLanguage) -> String {
        switch language {
        case .latvian:
            switch self {
            case .rightOfWay: return "Priekšrokas noteikumi"
            case .intersections: return "Krustojumu šķērsošana"
            case .trafficLights: return "Satiksmes regulēšana un luksofori"
            case .roadSigns: return "Ceļa zīmes"
            case .roadMarkings: return "Ceļa apzīmējumi"
            case .speedAndDistance: return "Ātrums un droša distance"
            case .overtaking: return "Apdzīšana un izmaiņa"
            case .stoppingAndParking: return "Apstāšanās un stāvēšana"
            case .pedestriansAndCyclists: return "Gājēji un mikromobilitāte"
            case .publicTransport: return "Sabiedriskais transports un tramvaji"
            case .laneSelection: return "Braukšanas joslu izvēle"
            case .vehicleSafety: return "Transportlīdzekļa tehniskais stāvoklis"
            case .driverResponsibilities: return "Vadītāja pienākumi"
            case .alcoholAndProhibitions: return "Alkohola un aizliegumu normas"
            case .hazards: return "Bīstamas situācijas un riska novērtēšana"
            case .motorways: return "Ātrgaitas ceļi un automaģistrāles"
            case .emergencyAndFirstAid: return "Pirmā palīdzība un ārkārtas situācijas"
            case .railwayCrossings: return "Dzelzceļa pārbrauktuves"
            case .ecoDriving: return "Droša un ekonomiska braukšana"
            }
        case .english:
            switch self {
            case .rightOfWay: return "Priority Rules"
            case .intersections: return "Intersections"
            case .trafficLights: return "Traffic Lights & Regulation"
            case .roadSigns: return "Road Signs"
            case .roadMarkings: return "Road Markings"
            case .speedAndDistance: return "Speed & Safe Distance"
            case .overtaking: return "Overtaking & Passing"
            case .stoppingAndParking: return "Stopping & Parking"
            case .pedestriansAndCyclists: return "Pedestrians & Cyclists"
            case .publicTransport: return "Public Transport & Trams"
            case .laneSelection: return "Lane Selection & Positioning"
            case .vehicleSafety: return "Vehicle Technical Condition"
            case .driverResponsibilities: return "Driver Responsibilities"
            case .alcoholAndProhibitions: return "Alcohol & Prohibited Behaviour"
            case .hazards: return "Hazard Awareness & Road Safety"
            case .motorways: return "Motorways & Expressways"
            case .emergencyAndFirstAid: return "Emergency Situations & First Aid"
            case .railwayCrossings: return "Railway Crossings"
            case .ecoDriving: return "Eco-Driving & Safe Driving"
            }
        }
    }

    public func description(for language: AppLanguage) -> String {
        switch language {
        case .latvian:
            switch self {
            case .rightOfWay: return "Galvenā ceļa zīmes, labās rokas likums un pārkārtošanās."
            case .intersections: return "Regulējami un neregulējami krustojumi, trajektorijas."
            case .trafficLights: return "Luksoforu signāli, papildsekcijas un regulētāja žesti."
            case .roadSigns: return "Brīdinājuma, aizlieguma, rīkojuma un norādījuma zīmes."
            case .roadMarkings: return "Garenvirziena, šķērsvirziena līnijas un bultas."
            case .speedAndDistance: return "Atļautie ātrumi apdzīvotās vietās, ārpus tām un distance."
            case .overtaking: return "Paredzamība, aizliegumi un drošs apdzīšanas manevrs."
            case .stoppingAndParking: return "Aizliegtās vietas, stāvēšanas laiks un papildplāksnītes."
            case .pedestriansAndCyclists: return "Pārejas, velojoslas, dzīvojamās zonas un gājēju aizsardzība."
            case .publicTransport: return "Tramvaju priekšroka, sabiedriskā transporta joslas."
            case .laneSelection: return "Manevrēšana pirms pagrieziena un rāvējslēdzēja princips."
            case .vehicleSafety: return "Riepu protektora dziļums, gaismas, bremzes un tehniskā apskate."
            case .driverResponsibilities: return "Nepieciešamie dokumenti, pasažieru drošība un tehniskais aprīkojums."
            case .alcoholAndProhibitions: return "Atļautās promiles (0.2 / 0.5), telefona lietošana pie stūres."
            case .hazards: return "Akvaplanēšana, apledojums, migla, meža dzīvnieki un tumsa."
            case .motorways: return "Ātrgaitas ceļu noteikumi, minimālais ātrums un aizliegumi."
            case .emergencyAndFirstAid: return "Avārijas zīmes izvietošana, 112 izsaukums, saskaņotais paziņojums."
            case .railwayCrossings: return "Barjeras, signālugunis un drošas šķērsošanas prasības."
            case .ecoDriving: return "Plūdena braukšana, pareiza pārnesumu izvēle un degvielas taupība."
            }
        case .english:
            switch self {
            case .rightOfWay: return "Main road signs, the right-hand rule, and lane change priority."
            case .intersections: return "Controlled and uncontrolled crossroads, turns and trajectories."
            case .trafficLights: return "Traffic light signals, arrow sections, and traffic controller gestures."
            case .roadSigns: return "Warning, prohibitory, mandatory, and information signs."
            case .roadMarkings: return "Longitudinal and transverse markings, directional arrows."
            case .speedAndDistance: return "Permitted speeds inside and outside built-up areas and safe distance."
            case .overtaking: return "Safe overtaking visibility, prohibitions, and maneuvers."
            case .stoppingAndParking: return "Prohibited stopping areas, parking discs, and restriction plates."
            case .pedestriansAndCyclists: return "Crossings, bicycle paths, living zones, and vulnerable road users."
            case .publicTransport: return "Tram priority, bus lanes, and boarding/alighting safety."
            case .laneSelection: return "Pre-turn positioning and the zipper merging principle."
            case .vehicleSafety: return "Tire tread depth, lighting, brakes, and roadworthiness."
            case .driverResponsibilities: return "Mandatory documents, seatbelts, child seats, and warning equipment."
            case .alcoholAndProhibitions: return "Blood alcohol limits (0.2 / 0.5 promille) and mobile phone usage."
            case .hazards: return "Aquaplaning, black ice, fog, twilight, and wild animal crossings."
            case .motorways: return "High-speed roads, acceleration lanes, and prohibited vehicles."
            case .emergencyAndFirstAid: return "Warning triangle placement, European accident statement, 112 emergency."
            case .railwayCrossings: return "Crossing barriers, flashing lights, and stopping obligations."
            case .ecoDriving: return "Smooth driving technique, anticipatory driving, and fuel conservation."
            }
        }
    }
}

// MARK: - Topic Icon View
public struct TopicIconView: View {
    public var topic: TopicCategory
    public var size: CGFloat
    public var color: Color

    public init(topic: TopicCategory, size: CGFloat = 20, color: Color = AppColors.latviaCarmine) {
        self.topic = topic
        self.size = size
        self.color = color
    }

    public var body: some View {
        if topic == .trafficLights {
            trafficLightIcon
        } else {
            Image(systemName: topic.iconName)
                .font(.system(size: size, weight: .semibold))
                .foregroundColor(color)
        }
    }

    private var trafficLightIcon: some View {
        VStack(spacing: size * 0.10) {
            Circle()
                .fill(color)
                .frame(width: size * 0.28, height: size * 0.28)
            Circle()
                .fill(color)
                .frame(width: size * 0.28, height: size * 0.28)
            Circle()
                .fill(color)
                .frame(width: size * 0.28, height: size * 0.28)
        }
        .padding(.vertical, size * 0.14)
        .padding(.horizontal, size * 0.12)
        .background(
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .stroke(color, lineWidth: max(1.2, size * 0.08))
        )
    }
}
