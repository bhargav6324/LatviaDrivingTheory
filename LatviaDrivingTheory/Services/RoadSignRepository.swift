import Foundation

public final class RoadSignRepository: ObservableObject {
    public static let shared = RoadSignRepository()

    @Published public private(set) var signs: [RoadSign] = []

    private init() {
        self.signs = RoadSignRepository.defaultLatvianSigns
    }

    public func signs(for category: RoadSignCategory) -> [RoadSign] {
        signs.filter { $0.category == category }
    }

    public func sign(with code: String) -> RoadSign? {
        signs.first { $0.code == code }
    }

    public static let defaultLatvianSigns: [RoadSign] = [
        // PRIORITY SIGNS (200 series)
        RoadSign(
            id: "LV-SGN-201",
            code: "201",
            category: .priority,
            shape: .diamondPriority,
            symbolType: "priority_road",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Galvenais ceļš",
                    meaning: "Dod tiesības braukt pa krustojumiem ar priekšroku pār mazāk svarīga ceļa braucējiem.",
                    legalRule: "CSN 201. zīme. Piešķir priekšroku neregulējamos krustojumos."
                ),
                "en": LocalizedSignContent(
                    name: "Priority Road",
                    meaning: "Gives right of way through uncontrolled intersections.",
                    legalRule: "CSN Sign 201."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-202",
            code: "202",
            category: .priority,
            shape: .diamondPriority,
            symbolType: "priority_end",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Galvenā ceļa beigas",
                    meaning: "Apzīmē vietu, kur beidzas ceļš ar priekšroku.",
                    legalRule: "CSN 202. zīme."
                ),
                "en": LocalizedSignContent(
                    name: "End of Priority Road",
                    meaning: "Marks the end of priority road privileges.",
                    legalRule: "CSN Sign 202."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-206",
            code: "206",
            category: .priority,
            shape: .invertedTriangle,
            symbolType: "give_way",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Dodiet ceļu",
                    meaning: "Vadītājam jādod ceļš transportlīdzekļiem, kas brauc pa šķērsojamo vai galveno ceļu.",
                    legalRule: "CSN 206. zīme. Nav obligāti jāapstājas, ja ceļš ir brīvs un netiek traucēta satiksme."
                ),
                "en": LocalizedSignContent(
                    name: "Give Way (Yield)",
                    meaning: "Drivers must yield to vehicles moving on the intersecting priority road.",
                    legalRule: "CSN Sign 206."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-207",
            code: "207",
            category: .priority,
            shape: .octagonStop,
            symbolType: "stop",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Neapstājoties tālāk braukt aizliegts (STOP)",
                    meaning: "Aizliegts braukt tālāk bez obligātas pilnīgas apstāšanās pirms stoplīnijas.",
                    legalRule: "CSN 207. zīme. Pilnīga apstāšanās ir obligāta."
                ),
                "en": LocalizedSignContent(
                    name: "STOP",
                    meaning: "Prohibits proceeding without bringing the vehicle to a full standstill.",
                    legalRule: "CSN Sign 207."
                )
            ]
        ),

        // WARNING SIGNS (100 series)
        RoadSign(
            id: "LV-SGN-101",
            code: "101",
            category: .warning,
            shape: .triangleWarning,
            symbolType: "curve_right",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Bīstams līkums pa labi",
                    meaning: "Brīdina par ceļa posmu ar maza rādiusa bīstamu līkumu pa labi.",
                    legalRule: "CSN 101. zīme. Uzstāda 50-100 m pirms līkuma pilsētā, 150-300 m ārpus pilsētas."
                ),
                "en": LocalizedSignContent(
                    name: "Dangerous Bend to the Right",
                    meaning: "Warns of a sharp curve to the right ahead.",
                    legalRule: "CSN Sign 101."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-102",
            code: "102",
            category: .warning,
            shape: .triangleWarning,
            symbolType: "curve_left",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Bīstams līkums pa kreisi",
                    meaning: "Brīdina par ceļa posmu ar maza rādiusa bīstamu līkumu pa kreisi.",
                    legalRule: "CSN 102. zīme."
                ),
                "en": LocalizedSignContent(
                    name: "Dangerous Bend to the Left",
                    meaning: "Warns of a sharp curve to the left ahead.",
                    legalRule: "CSN Sign 102."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-121",
            code: "121",
            category: .warning,
            shape: .triangleWarning,
            symbolType: "pedestrian_cross",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Gājēju pāreja (brīdinājums)",
                    meaning: "Brīdina par tuvošanos gājēju pārejai, ko apzīmē ar 521. zīmi vai 920. marķējumu.",
                    legalRule: "CSN 121. zīme. Vadītājam jāsamazina ātrums un jābūt gatavam apstāties."
                ),
                "en": LocalizedSignContent(
                    name: "Pedestrian Crossing Warning",
                    meaning: "Warns of an approaching pedestrian crossing.",
                    legalRule: "CSN Sign 121."
                )
            ]
        ),

        // PROHIBITORY SIGNS (300 series)
        RoadSign(
            id: "LV-SGN-301",
            code: "301",
            category: .prohibitory,
            shape: .circleProhibitory,
            symbolType: "no_entry",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Iebraukt aizliegts ('Ķieģelis')",
                    meaning: "Aizliedz iebraukt visu veidu transportlīdzekļiem šajā virzienā.",
                    legalRule: "CSN 301. zīme."
                ),
                "en": LocalizedSignContent(
                    name: "No Entry",
                    meaning: "Prohibits entry for all vehicles from this direction.",
                    legalRule: "CSN Sign 301."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-312",
            code: "312",
            category: .prohibitory,
            shape: .circleProhibitory,
            symbolType: "speed_50",
            speedValue: 50,
            translations: [
                "lv": LocalizedSignContent(
                    name: "Maksimālā ātruma ierobežojums (50 km/h)",
                    meaning: "Aizliedz braukt ar ātrumu, kas pārsniedz zīmē norādīto (50 km/h).",
                    legalRule: "CSN 312. zīme. Spēkā līdz tuvākajam krustojumam vai zīmei 313."
                ),
                "en": LocalizedSignContent(
                    name: "Maximum Speed Limit (50 km/h)",
                    meaning: "Prohibits driving at speeds exceeding 50 km/h.",
                    legalRule: "CSN Sign 312."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-326",
            code: "326",
            category: .prohibitory,
            shape: .circleProhibitory,
            symbolType: "no_stopping",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Apstāties aizliegts",
                    meaning: "Aizliedz transportlīdzekļu apstāšanos un stāvēšanu zīmes darbības pusē.",
                    legalRule: "CSN 326. zīme. Neattiecas uz pasažieru iekāpšanu taksometros, ja ir papildplāksnīte."
                ),
                "en": LocalizedSignContent(
                    name: "No Stopping",
                    meaning: "Prohibits both stopping and parking on that side of the road.",
                    legalRule: "CSN Sign 326."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-327",
            code: "327",
            category: .prohibitory,
            shape: .circleProhibitory,
            symbolType: "no_parking",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Stāvēt aizliegts",
                    meaning: "Aizliedz transportlīdzekļu stāvēšanu. Apstāšanās pasažieru iekāpšanai vai izkāpšanai ir atļauta.",
                    legalRule: "CSN 327. zīme."
                ),
                "en": LocalizedSignContent(
                    name: "No Parking",
                    meaning: "Prohibits parking; momentary stopping to load/unload passengers is permitted.",
                    legalRule: "CSN Sign 327."
                )
            ]
        ),

        // MANDATORY SIGNS (400 series)
        RoadSign(
            id: "LV-SGN-401",
            code: "401",
            category: .mandatory,
            shape: .circleMandatory,
            symbolType: "straight_only",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Braukt taisni",
                    meaning: "Atļauj braukt tikai taisni.",
                    legalRule: "CSN 401. zīme."
                ),
                "en": LocalizedSignContent(
                    name: "Proceed Straight Only",
                    meaning: "Mandates proceeding only straight ahead.",
                    legalRule: "CSN Sign 401."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-409",
            code: "409",
            category: .mandatory,
            shape: .circleMandatory,
            symbolType: "roundabout_mandatory",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Apbraukšanas virziens (Aplis)",
                    meaning: "Atļauj kustību tikai bultiņu norādītajā virzienā apļveida krustojumā.",
                    legalRule: "CSN 409. zīme."
                ),
                "en": LocalizedSignContent(
                    name: "Roundabout Mandatory Direction",
                    meaning: "Mandates driving only in the direction shown by arrows on the roundabout.",
                    legalRule: "CSN Sign 409."
                )
            ]
        ),

        // INFORMATION SIGNS (500 series)
        RoadSign(
            id: "LV-SGN-501",
            code: "501",
            category: .information,
            shape: .squareBlue,
            symbolType: "one_way",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Vienvirziena ceļš",
                    meaning: "Ceļš vai brauktuve, pa kuru transportlīdzekļu kustība visā platumā notiek vienā virzienā.",
                    legalRule: "CSN 501. zīme."
                ),
                "en": LocalizedSignContent(
                    name: "One-Way Road",
                    meaning: "Road or carriageway where vehicular traffic flows in one direction across all lanes.",
                    legalRule: "CSN Sign 501."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-521",
            code: "521",
            category: .information,
            shape: .squareBlue,
            symbolType: "pedestrian_crossing_info",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Gājēju pāreja",
                    meaning: "Norāda vietu, kur gājējiem atļauts šķērsot brauktuvi ar priekšroku.",
                    legalRule: "CSN 521. zīme. Vadītājam jādod ceļš gājējiem, kas uzsākuši vai atrodas uz pārejas."
                ),
                "en": LocalizedSignContent(
                    name: "Pedestrian Crossing",
                    meaning: "Designates a regulated crossing area where pedestrians have priority.",
                    legalRule: "CSN Sign 521."
                )
            ]
        ),
        RoadSign(
            id: "LV-SGN-532",
            code: "532",
            category: .information,
            shape: .squareBlue,
            symbolType: "parking_info",
            translations: [
                "lv": LocalizedSignContent(
                    name: "Stāvvieta",
                    meaning: "Vieta, kas paredzēta transportlīdzekļu stāvēšanai.",
                    legalRule: "CSN 532. zīme."
                ),
                "en": LocalizedSignContent(
                    name: "Parking Area",
                    meaning: "Designates an area reserved for vehicular parking.",
                    legalRule: "CSN Sign 532."
                )
            ]
        )
    ]
}
