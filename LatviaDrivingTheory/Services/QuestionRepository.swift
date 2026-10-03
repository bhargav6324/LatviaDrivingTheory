import Foundation

public final class QuestionRepository: ObservableObject {
    public static let shared = QuestionRepository()

    public let contentVersion: String = "development-1"

    @Published public private(set) var questions: [Question] = []

    private init() {
        loadQuestions()
    }

    public func loadQuestions() {
        var loaded: [Question]?

        // 1. Attempt to load from bundled Questions.json
        let bundleUrl = Bundle.main.url(forResource: "Questions", withExtension: "json")
            ?? Bundle(for: QuestionRepository.self).url(forResource: "Questions", withExtension: "json")

        if let url = bundleUrl,
           let data = try? Data(contentsOf: url),
           let decoded = decodeQuestions(from: data, source: "bundle (\(url.lastPathComponent))") {
            loaded = decoded
        }

        // 2. Direct path check if running locally or in development environment
        if loaded == nil {
            let devPaths = [
                "LatviaDrivingTheory/Resources/Questions.json",
                "Resources/Questions.json",
                "../Resources/Questions.json"
            ]
            for path in devPaths {
                let url = URL(fileURLWithPath: path)
                if let data = try? Data(contentsOf: url),
                   let decoded = decodeQuestions(from: data, source: "dev path \(path)") {
                    loaded = decoded
                    break
                }
            }
        }

        // 3. Fallback to default Latvian question bank if needed
        if let questions = loaded, !questions.isEmpty {
            self.questions = questions
        } else {
            print("[QuestionRepository] ⚠️ Notice: Falling back to default Latvian question bank (\(QuestionRepository.defaultQuestionBank.count) questions).")
            self.questions = QuestionRepository.defaultQuestionBank
        }

        #if DEBUG
        QuestionValidator.validate(questions: self.questions)
        #endif
    }

    private func decodeQuestions(from data: Data, source: String) -> [Question]? {
        do {
            let decoded = try JSONDecoder().decode([Question].self, from: data)
            if !decoded.isEmpty {
                print("[QuestionRepository] ✅ Loaded \(decoded.count) questions from \(source).")
                return decoded
            }
        } catch {
            print("[QuestionRepository] ⚠️ Batch decode failed for \(source): \(error)")
        }

        // Resilient item-by-item decode to rescue questions if JSON has individual flaws
        if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            var decodedItems: [Question] = []
            let decoder = JSONDecoder()
            for (index, itemDict) in jsonArray.enumerated() {
                if let itemData = try? JSONSerialization.data(withJSONObject: itemDict),
                   let q = try? decoder.decode(Question.self, from: itemData) {
                    decodedItems.append(q)
                } else {
                    let qId = itemDict["id"] as? String ?? "#\(index)"
                    print("[QuestionRepository] ⚠️ Failed parsing question \(qId)")
                }
            }
            if !decodedItems.isEmpty {
                print("[QuestionRepository] ⚠️ Rescued \(decodedItems.count) questions from \(source).")
                return decodedItems
            }
        }

        return nil
    }

    public func questions(for topic: TopicCategory) -> [Question] {
        questions.filter { $0.topic == topic }
    }

    public func question(with id: String) -> Question? {
        questions.first { $0.id == id }
    }

    public func signTestQuestions() -> [Question] {
        let signQuestions = questions.filter { $0.topic == .roadSigns }
        return signQuestions.isEmpty ? questions : signQuestions
    }

    public func randomQuestions(count: Int, topic: TopicCategory? = nil) -> [Question] {
        let pool = topic == nil ? questions : questions(for: topic!)
        guard !pool.isEmpty else { return [] }
        return Array(pool.shuffled().prefix(count))
    }

    /// Generates a balanced mock exam question set according to ExamConfiguration
    public func randomExamQuestions(config: ExamConfiguration = .latvianCategoryB) -> [Question] {
        let all = questions.shuffled()
        guard all.count >= config.questionCount else {
            // If question bank is smaller than desired exam count during early dev, cycle with unique identifiers
            var result: [Question] = []
            while result.count < config.questionCount {
                for q in all {
                    if result.count < config.questionCount {
                        result.append(q)
                    }
                }
            }
            return result
        }

        // Try to balance safety questions
        let safetyQuestions = all.filter { $0.isSafetyQuestion }
        let normalQuestions = all.filter { !$0.isSafetyQuestion }

        var selected: [Question] = []
        let safetyTarget = min(config.safetyQuestionCount, safetyQuestions.count)
        selected.append(contentsOf: safetyQuestions.prefix(safetyTarget))

        let remainingTarget = config.questionCount - selected.count
        selected.append(contentsOf: normalQuestions.prefix(remainingTarget))

        if selected.count < config.questionCount {
            let needed = config.questionCount - selected.count
            let fallbackPool = all.filter { q in !selected.contains { $0.id == q.id } }
            selected.append(contentsOf: fallbackPool.prefix(needed))
        }

        return selected.shuffled()
    }

    // Default built-in question bank for immediate offline readiness
    public static let defaultQuestionBank: [Question] = [
        Question(
            id: "LV-B-ROW-01",
            topic: .rightOfWay,
            subtopic: "Krustojumi ar vienādas nozīmes ceļiem",
            difficulty: .easy,
            isSafetyQuestion: true,
            source: LegalSource(title: "Ceļu satiksmes noteikumi (CSN)", section: "128. punkts"),
            translations: [
                "lv": LocalizedQuestionContent(
                    question: "Tu tuvojies vienādas nozīmes ceļu krustojumam. No labās puses tuvojas cits transportlīdzeklis. Kuram ir priekšroka?",
                    options: [
                        "Transportlīdzeklim, kas tuvojas no labās puses",
                        "Tavam transportlīdzeklim, jo tu brauc taisni",
                        "Tam, kurš pirmais iebrauc krustojumā",
                        "Tam, kuram ir lielāks braukšanas ātrums"
                    ],
                    correctIndex: 0,
                    explanation: "Vienādas nozīmes ceļu krustojumā transportlīdzekļa vadītājam jādod ceļš transportlīdzekļiem, kas tuvojas krustojumam no labās puses (CSN 128. punkts — t.s. labās rokas likums).",
                    keyTakeaway: "Vienādas nozīmes krustojumā vienmēr dod ceļu no labās puses braucošajam."
                ),
                "en": LocalizedQuestionContent(
                    question: "You are approaching an uncontrolled intersection of equal roads. Another vehicle is approaching from your right. Who has priority?",
                    options: [
                        "The vehicle approaching from the right",
                        "Your vehicle, because you are driving straight",
                        "Whichever vehicle enters the intersection first",
                        "The vehicle travelling at higher speed"
                    ],
                    correctIndex: 0,
                    explanation: "Under Section 128 of the Latvian Traffic Regulations (CSN), at an intersection of roads of equal importance, drivers must give way to vehicles approaching from the right (the right-hand rule).",
                    keyTakeaway: "At equal intersections, always yield to traffic from the right."
                )
            ]
        ),
        Question(
            id: "LV-B-ROW-02",
            topic: .rightOfWay,
            subtopic: "Nogriešanās pa kreisi",
            difficulty: .medium,
            isSafetyQuestion: true,
            source: LegalSource(title: "Ceļu satiksmes noteikumi (CSN)", section: "129. punkts"),
            translations: [
                "lv": LocalizedQuestionContent(
                    question: "Nogriežoties pa kreisi vai apgriežoties braukšanai pretējā virzienā, kuram vadītājam jādod ceļš?",
                    options: [
                        "Pretimbraucošajiem transportlīdzekļiem, kas brauc taisni vai nogriežas pa labi",
                        "Tikai tiem transportlīdzekļiem, kas brauc no aizmugures",
                        "Nevienam, ja manevrs ir laikus sākts",
                        "Tikai sabiedriskajam transportam"
                    ],
                    correctIndex: 0,
                    explanation: "Nogriežoties pa kreisi vai apgriežoties braukšanai pretējā virzienā, vadītājam jādod ceļš tiem pretimbraucošajiem transportlīdzekļiem, kas brauc taisni vai nogriežas pa labi (CSN 129. punkts).",
                    keyTakeaway: "Griežoties pa kreisi, palaid pretimbraucējus, kuri brauc taisni vai griežas pa labi."
                ),
                "en": LocalizedQuestionContent(
                    question: "When turning left or making a U-turn at an intersection, who must you give way to?",
                    options: [
                        "Oncoming vehicles driving straight or turning right",
                        "Only vehicles approaching from behind",
                        "No one, provided the maneuver was started early",
                        "Only scheduled public transport"
                    ],
                    correctIndex: 0,
                    explanation: "When turning left or making a U-turn, drivers must give way to oncoming traffic continuing straight or turning right (CSN Section 129).",
                    keyTakeaway: "Left turners must yield to oncoming straight and right-turning vehicles."
                )
            ]
        ),
        Question(
            id: "LV-B-INT-01",
            topic: .intersections,
            subtopic: "Apļveida krustojums",
            difficulty: .medium,
            isSafetyQuestion: true,
            source: LegalSource(title: "Ceļu satiksmes noteikumi (CSN)", section: "131. punkts"),
            translations: [
                "lv": LocalizedQuestionContent(
                    question: "Iebraucot apļveida krustojumā, pirms kura uzstādīta zīme 'Dodiet ceļu' (206) kopā ar zīmi 'Apbraukšanas virziens' (409), kuram ir priekšroka?",
                    options: [
                        "Transportlīdzekļiem, kas jau atrodas apļveida krustojumā",
                        "Transportlīdzeklim, kas iebrauc aplī no labās puses",
                        "Transportlīdzeklim ar lielāku braukšanas ātrumu",
                        "Priekšroka mainās atkarībā no diennakts laika"
                    ],
                    correctIndex: 0,
                    explanation: "Ja pirms iebraukšanas apļveida krustojumā uzstādīta zīme 206 'Dodiet ceļu', vadītājam obligāti jādod ceļš transportlīdzekļiem, kuri jau atrodas aplī.",
                    keyTakeaway: "Aplī esošajam ir priekšroka, ja pie iebrauktuves ir zīme 'Dodiet ceļu'."
                ),
                "en": LocalizedQuestionContent(
                    question: "When entering a roundabout marked with sign 206 ('Give Way') combined with sign 409 ('Roundabout'), who has priority?",
                    options: [
                        "Vehicles already circulating on the roundabout",
                        "The vehicle entering the roundabout from the right",
                        "The faster moving vehicle",
                        "Priority depends on the time of day"
                    ],
                    correctIndex: 0,
                    explanation: "When entering a roundabout equipped with a Give Way sign, entering drivers must yield to vehicles already travelling on the roundabout.",
                    keyTakeaway: "Circulating vehicles have priority when Give Way is posted at the entrance."
                )
            ]
        ),
        Question(
            id: "LV-B-SGN-01",
            topic: .roadSigns,
            subtopic: "Zīme 207 STOP",
            difficulty: .easy,
            isSafetyQuestion: true,
            source: LegalSource(title: "Ceļu satiksmes noteikumi (CSN)", section: "207. zīme"),
            translations: [
                "lv": LocalizedQuestionContent(
                    question: "Ko pieprasa ceļa zīme 207 'Neapstājoties tālāk braukt aizliegts' (STOP)?",
                    options: [
                        "Obligāti pilnībā apturēt transportlīdzekli pirms stoplīnijas vai krustojuma brauktuvju malas",
                        "Samazināt ātrumu un apstāties tikai tad, ja tuvojas citi transportlīdzekļi",
                        "Apstāties tikai tad, ja brauc pa kreisi",
                        "Apstāties tikai diennakts tumšajā laikā"
                    ],
                    correctIndex: 0,
                    explanation: "Zīme 207 (STOP) kategoriski pieprasa pilnīgu transportlīdzekļa apturēšanu pirms stoplīnijas, bet ja tās nav — pirms šķērsojamās brauktuves malas.",
                    keyTakeaway: "Pie STOP zīmes pilnīga apstāšanās ir obligāta vienmēr, pat ja ceļš ir brīvs."
                ),
                "en": LocalizedQuestionContent(
                    question: "What does road sign 207 ('STOP') require drivers to do?",
                    options: [
                        "Come to a complete stop before the stop line or crossing carriageway edge",
                        "Slow down and stop only if another vehicle is approaching",
                        "Stop only if making a left turn",
                        "Stop only during hours of darkness"
                    ],
                    correctIndex: 0,
                    explanation: "Road sign 207 unconditionally mandates a complete standstill before the stop line or before the intersecting carriageway edge.",
                    keyTakeaway: "A complete stop is mandatory at every STOP sign, even if the road appears empty."
                )
            ]
        ),
        Question(
            id: "LV-B-SPD-01",
            topic: .speedAndDistance,
            subtopic: "Atļautais braukšanas ātrums",
            difficulty: .easy,
            isSafetyQuestion: false,
            source: LegalSource(title: "Ceļu satiksmes noteikumi (CSN)", section: "101. punkts"),
            translations: [
                "lv": LocalizedQuestionContent(
                    question: "Kāds ir maksimālais atļautais braukšanas ātrums B kategorijas vieglajam automobilim apdzīvotā vietā un ārpus tās Latvijā?",
                    options: [
                        "50 km/h apdzīvotā vietā un 90 km/h ārpus apdzīvotām vietām",
                        "60 km/h apdzīvotā vietā un 100 km/h ārpus apdzīvotām vietām",
                        "50 km/h apdzīvotā vietā un 110 km/h ārpus apdzīvotām vietām",
                        "40 km/h apdzīvotā vietā un 80 km/h ārpus apdzīvotām vietām"
                    ],
                    correctIndex: 0,
                    explanation: "Vieglajiem automobiļiem standarta ātrums apdzīvotās vietās ir 50 km/h, bet ārpus tām — 90 km/h (CSN 101. punkts).",
                    keyTakeaway: "Standarta ātrums Latvijā: 50 km/h pilsētā, 90 km/h ārpus tās."
                ),
                "en": LocalizedQuestionContent(
                    question: "What is the general maximum speed limit for Category B passenger cars in Latvia inside and outside built-up areas?",
                    options: [
                        "50 km/h inside built-up areas and 90 km/h outside built-up areas",
                        "60 km/h inside built-up areas and 100 km/h outside built-up areas",
                        "50 km/h inside built-up areas and 110 km/h outside built-up areas",
                        "40 km/h inside built-up areas and 80 km/h outside built-up areas"
                    ],
                    correctIndex: 0,
                    explanation: "Under CSN Section 101, the general speed limit is 50 km/h in built-up areas and 90 km/h outside built-up areas for passenger cars.",
                    keyTakeaway: "Default speed limits: 50 km/h in towns, 90 km/h on rural roads."
                )
            ]
        ),
        Question(
            id: "LV-B-ALC-01",
            topic: .alcoholAndProhibitions,
            subtopic: "Alkohola koncentrācijas ierobežojumi",
            difficulty: .medium,
            isSafetyQuestion: true,
            source: LegalSource(title: "Ceļu satiksmes likums", section: "28. pants"),
            translations: [
                "lv": LocalizedQuestionContent(
                    question: "Kāda ir maksimāli pieļaujamā alkohola koncentrācija asinīs vadītājam ar stāžu zem 2 gadiem?",
                    options: [
                        "0,2 promiles",
                        "0,5 promiles",
                        "0,0 promiles",
                        "0,8 promiles"
                    ],
                    correctIndex: 0,
                    explanation: "Jaunajiem vadītājiem ar stāžu zem 2 gadiem pieļaujamā norma ir līdz 0,2 promilēm. Virs 2 gadiem stāža — 0,5 promiles.",
                    keyTakeaway: "Jaunajiem vadītājiem robeža ir 0,2 promiles."
                ),
                "en": LocalizedQuestionContent(
                    question: "What is the maximum blood alcohol concentration permitted for a driver with less than 2 years of experience?",
                    options: [
                        "0.2 per mille (promille)",
                        "0.5 per mille (promille)",
                        "0.0 per mille (promille)",
                        "0.8 per mille (promille)"
                    ],
                    correctIndex: 0,
                    explanation: "Drivers with less than two years experience have a 0.2 promille limit.",
                    keyTakeaway: "Novice drivers have a strict 0.2 promille limit."
                )
            ]
        ),
        Question(
            id: "LV-B-SAF-01",
            topic: .vehicleSafety,
            subtopic: "Ziemas riepu prasības",
            difficulty: .medium,
            isSafetyQuestion: true,
            source: LegalSource(title: "Ceļu satiksmes noteikumi (CSN)", section: "223. punkts"),
            translations: [
                "lv": LocalizedQuestionContent(
                    question: "Kāds ir minimālais pieļaujamais riepu protektora dziļums vieglajam automobilim ziemas periodā (1. decembris – 1. marts)?",
                    options: [
                        "4,0 mm (vasaras riepām minimālais ir 1,6 mm)",
                        "3,0 mm (vasaras riepām minimālais ir 2,0 mm)",
                        "5,0 mm (vasaras riepām minimālais ir 1,0 mm)",
                        "2,0 mm visu gadu"
                    ],
                    correctIndex: 0,
                    explanation: "Ziemas riepām protektora dziļums nedrīkst būt mazāks par 4,0 mm. Vasaras riepām minimālais ir 1,6 mm.",
                    keyTakeaway: "Ziemas riepas: min 4,0 mm. Obligāts periods: 1. decembris – 1. marts."
                ),
                "en": LocalizedQuestionContent(
                    question: "What is the minimum permitted tire tread depth for passenger cars in Latvia during winter (Dec 1 – Mar 1)?",
                    options: [
                        "4.0 mm (summer tire minimum is 1.6 mm)",
                        "3.0 mm (summer tire minimum is 2.0 mm)",
                        "5.0 mm (summer tire minimum is 1.0 mm)",
                        "2.0 mm all year round"
                    ],
                    correctIndex: 0,
                    explanation: "Winter tires must have at least 4.0 mm tread depth from Dec 1 to Mar 1.",
                    keyTakeaway: "Winter tire minimum tread is 4.0 mm."
                )
            ]
        ),
        Question(
            id: "LV-B-EMG-01",
            topic: .emergencyAndFirstAid,
            subtopic: "Avārijas trīsstūra izvietošana",
            difficulty: .medium,
            isSafetyQuestion: true,
            source: LegalSource(title: "Ceļu satiksmes noteikumi (CSN)", section: "160. punkts"),
            translations: [
                "lv": LocalizedQuestionContent(
                    question: "Kādā attālumā no automobiļa jāizliek avārijas trīsstūris ārpus apdzīvotām vietām piespiedu apstāšanās gadījumā?",
                    options: [
                        "Ne mazāk kā 50 metru attālumā (apdzīvotās vietās — ne mazāk kā 15 metru)",
                        "Ne mazāk kā 25 metru attālumā",
                        "Ne mazāk kā 100 metru attālumā",
                        "Tieši pie aizmugurējā bufera"
                    ],
                    correctIndex: 0,
                    explanation: "Ārpus apdzīvotām vietām avārijas trīsstūris jāizliek vismaz 50 m no auto, pilsētās — vismaz 15 m.",
                    keyTakeaway: "Avārijas trīsstūris: vismaz 50 m ārpus pilsētas, 15 m pilsētā."
                ),
                "en": LocalizedQuestionContent(
                    question: "At what distance behind the vehicle must the warning triangle be placed outside built-up areas?",
                    options: [
                        "At least 50 meters (in built-up areas at least 15 meters)",
                        "At least 25 meters",
                        "At least 100 meters",
                        "Directly at the rear bumper"
                    ],
                    correctIndex: 0,
                    explanation: "At least 50 meters outside built-up areas, and at least 15 meters inside.",
                    keyTakeaway: "Warning triangle distance: 50 m rural, 15 m urban."
                )
            ]
        )
    ]
}
