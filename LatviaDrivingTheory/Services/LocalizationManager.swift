import SwiftUI
import Combine

public final class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()

    private let languageKey = "latvia_selected_app_language"
    private let hasChosenLanguageKey = "latvia_has_completed_initial_language_selection"

    @Published public var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
        }
    }

    @Published public var hasSelectedLanguageOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSelectedLanguageOnboarding, forKey: hasChosenLanguageKey)
        }
    }

    private init() {
        let storedLang = UserDefaults.standard.string(forKey: languageKey)
        if let stored = storedLang, let lang = AppLanguage(rawValue: stored) {
            self.currentLanguage = lang
        } else {
            // Default to Latvian if device locale is Latvian, otherwise English
            let preferred = Locale.preferredLanguages.first ?? ""
            if preferred.starts(with: "lv") {
                self.currentLanguage = .latvian
            } else {
                self.currentLanguage = .english
            }
        }

        self.hasSelectedLanguageOnboarding = UserDefaults.standard.bool(forKey: hasChosenLanguageKey)
    }

    public func setLanguage(_ language: AppLanguage) {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentLanguage = language
            hasSelectedLanguageOnboarding = true
        }
    }

    public func t(_ key: LocalizationKey) -> String {
        key.localized(for: currentLanguage)
    }
}

public enum LocalizationKey {
    // Navigation / Tabs
    case tabHome
    case tabPractice
    case tabProgress
    case tabSettings

    // Home
    case appTitle
    case categoryB
    case examReadiness
    case questionsMastered
    case mockExamPerformance
    case weakTopics
    case continuePractice
    case resumeRecentTopic
    case mockExamTitle
    case mockExamSubtitle
    case practiceQuestionsTitle
    case practiceQuestionsSubtitle
    case myMistakesTitle
    case myMistakesSubtitle
    case roadSignsTitle
    case roadSignsSubtitle

    // Practice
    case allTopics
    case practiceCategories
    case startPractice
    case questionCount(Int)
    case topicMastery(Int)

    // Quiz / Question Flow
    case questionProgress(Int, Int)
    case questionOf(Int, Int)
    case checkAnswer
    case nextQuestion
    case finishQuiz
    case correct
    case incorrect
    case explanationTitle
    case whyExplanation
    case keyTakeawayTitle
    case legalReference
    case exitQuizTitle
    case exitQuizMessage
    case continueQuiz
    case quitQuiz
    case quitConfirmTitle
    case quitConfirmMessage
    case exitAndReview
    case stay
    case safetyQuestionBadge

    // Summary
    case quizCompleted
    case sessionEndedEarly
    case sessionEarlySubtitle(Int)
    case wellDone
    case keepPracticing
    case yourAnswerLabel
    case quit
    case bestValueBadge
    case scoreResult(Int, Int)
    case accuracy(Int)
    case accuracyLabel
    case questionsAttempted
    case correctStat
    case mistakesStat
    case questionsToReview
    case correctAnswerLabel
    case noMistakesInSession
    case practiceMistakesAction
    case reviewMistakes
    case backToTopics
    case tryAgain

    // Mock Exam
    case mockExamIntroTitle
    case mockExamIntroDescription
    case examRuleQuestions(Int)
    case examRuleTime(Int)
    case examRuleAllowedErrors(Int)
    case examRulePassingScore(Int)
    case startExam
    case timeRemaining
    case questionFlagged
    case flagForReview
    case unflagQuestion
    case questionBoard
    case reviewAll
    case reviewAllAnswers
    case answeredQuestions(Int, Int)
    case submitExam
    case submitExamConfirmTitle
    case submitExamConfirmMessage(Int)
    case cancel
    case submit
    case passed
    case notPassed
    case examPassedTitle
    case examFailedTitle
    case examScoreLabel
    case errorsLabel
    case safetyErrors
    case examScore(Int, Int)
    case examErrorsCount(Int, Int)
    case reviewQuestions
    case retakeExam
    case backToHome

    // Mistakes
    case noMistakesTitle
    case noMistakesSubtitle
    case practiceMistakes
    case clearMasteredMistakes
    case mistakeCountBadge(Int)

    // Road Signs
    case roadSignsCategoryTitle
    case signQuizTitle
    case signQuizSubtitle
    case searchSigns
    case allSigns
    case learnSigns
    case practiceSigns
    case signCategoryAll
    case signCode(String)
    case signQuiz
    case flashcardsLockedTitle
    case flashcardsLockedSubtitle
    case signTestLockedTitle
    case signTestLockedSubtitle

    // Mock Exam Additional
    case mockExamRulesTitle
    case officialCategoryBRules
    case oneFreeMockBadge
    case mockExamCompletedTitle
    case mockExamCompletedDescription
    case unlockUnlimitedMocks
    case examDuration
    case passingRequirements
    case strictSafetyLimit
    case startFreeMock

    // Practice Additional
    case freeQuestionsAvailable(Int)
    case premiumLockedTopic
    case unlockAllTopicQuestions(Int)

    // Mistakes Additional
    case activeMistakes(Int)
    case practiceMyMistakes

    // General & Dialogs
    case done
    case close
    case errorTitle
    case ok

    // Paywall & Premium
    case paywallTitle
    case paywallSubtitle
    case unlockWithPremium
    case premiumActiveStatus
    case premiumLifetimeStatus
    case viewPremiumButton
    case termsOfService
    case privacyPolicy
    case unlockFullAccessSubtitle
    case purchasesUnavailable
    case loadingPurchases
    case retryLoading
    case sectionPremium
    case proCardTitle
    case freePlan
    case freePlanDescription
    case upgradeToPro
    case premiumActive
    case lifetimeAccess
    case studyPreferences
    case dailyGoal
    case studyReminder
    case reminderTime
    case progress
    case resetProgressTitle
    case resetProgressMessage
    case about
    case appNameLabel
    case subtitleLabel
    case versionLabel
    case supportLabel
    case supportWebsiteLabel
    case privacyPolicyLabel
    case termsOfUseLabel
    case legal
    case disclaimerLabel
    case governmentDisclaimerText
    case restorePurchases
    case restorePurchasesSuccess
    case restorePurchasesNotFound

    // Pro Monetization & Paywall
    case paywallBenefit1
    case paywallBenefit2
    case paywallBenefit3
    case paywallBenefit4
    case paywallBenefit5
    case paywallBenefit6
    case paywallBenefit7
    case proLifetimeTitle
    case proLifetimeSubtitle
    case proMonthlyTitle
    case proMonthlyPerMonth
    case proBestValueBadge
    case proLifetimeCTA
    case proMonthlyCTA
    case proSubscriptionNotice
    case proInactiveStatus
    case proMonthlyStatus
    case proLifetimeStatus
    case proLifetimeActiveStatus
    case proActiveStatus
    case manageSubscription
    case proAlreadyLifetimeMessage
    case upgradeToLifetimePrompt

    // Daily Goal
    case dailyGoalTitle
    case dailyGoalCardLabel
    case dailyGoalCompleted
    case dailyGoalProgress(Int, Int)
    case chooseGoal
    case goal5
    case goal10
    case goal20
    case goal30
    case goalCustom
    case questionsPerDay(Int)

    // Streak
    case studyStreak
    case streakDays(Int)
    case streakZero

    // Readiness
    case examReadinessExplanation
    case examReadinessNotEnoughData
    case examReadinessInfoTitle

    // Mock Chart
    case mockScoreTrend
    case mockScoreTrendEmpty
    case mockPassLabel
    case mockFailLabel

    // Activity Calendar
    case activityCalendar
    case activityCalendarEmpty
    case activityNoData
    case activityLightLabel
    case activityMediumLabel
    case activityStrongLabel
    case activityDayDetail(Int, Int, Int)

    // Topic Performance
    case topicPerformanceTitle
    case topicAccuracy(Int)
    case topicAttempted(Int)
    case topicMastered(Int)
    case topicStrong
    case topicWeak
    case topicNoData
    case weakTopicsSection

    // Reminder
    case dailyReminderTitle
    case dailyReminderSubtitle
    case reminderEnabled
    case reminderDisabled
    case reminderTimeLabel
    case reminderPermissionDenied
    case reminderPermissionDeniedMessage

    // Statistics
    case statsTitle
    case statsBestMockScore
    case statsMockExamsCompleted
    case statsMistakesRemaining

    public func localized(for language: AppLanguage) -> String {
        switch language {
        case .latvian:
            return localizedLatvian
        case .english:
            return localizedEnglish
        }
    }

    private var localizedLatvian: String {
        switch self {
        // Navigation / Tabs
        case .tabHome: return "Sākums"
        case .tabPractice: return "Treniņš"
        case .tabProgress: return "Progress"
        case .tabSettings: return "Iestatījumi"

        // Home
        case .appTitle: return "CSDD Teorija"
        case .categoryB: return "B kategorija"
        case .examReadiness: return "Gatavība eksāmenam"
        case .questionsMastered: return "Apgūtie jautājumi"
        case .mockExamPerformance: return "Eksāmenu rezultāti"
        case .weakTopics: return "Vājās tēmas"
        case .continuePractice: return "Turpināt mācīties"
        case .resumeRecentTopic: return "Atsākt pēdējo tēmu"
        case .mockExamTitle: return "Testa eksāmens"
        case .mockExamSubtitle: return "30 jautājumi • 30 min • Max 3 kļūdas"
        case .practiceQuestionsTitle: return "Treniņš pa tēmām"
        case .practiceQuestionsSubtitle: return "Mācies jautājumus ar tūlītējiem skaidrojumiem"
        case .myMistakesTitle: return "Manas kļūdas"
        case .myMistakesSubtitle: return "Atkārto jautājumus, kuros pieļāvi kļūdas"
        case .roadSignsTitle: return "Ceļa zīmes"
        case .roadSignsSubtitle: return "Ceļa zīmju katalogs un atpazīšanas tests"

        // Practice
        case .allTopics: return "Visas tēmas"
        case .practiceCategories: return "Mācību sadaļas"
        case .startPractice: return "Sākt treniņu"
        case .questionCount(let n): return "\(n) jautājumi"
        case .topicMastery(let m): return "\(m)% apgūts"

        // Quiz / Question Flow
        case .questionProgress(let current, let total): return "\(current) no \(total)"
        case .questionOf(let current, let total): return "\(current) no \(total)"
        case .checkAnswer: return "Pārbaudīt atbildi"
        case .nextQuestion: return "Nākamais jautājums"
        case .finishQuiz: return "Pabeigt treniņu"
        case .correct: return "Pareizi! ✓"
        case .incorrect: return "Nepareizi ✕"
        case .explanationTitle: return "Noteikuma skaidrojums"
        case .whyExplanation: return "Kāpēc šī atbilde ir pareiza?"
        case .keyTakeawayTitle: return "Galvenais likums"
        case .legalReference: return "Likuma atsauce (CSN)"
        case .exitQuizTitle: return "Pārtraukt treniņu?"
        case .exitQuizMessage: return "Jūsu atbildētie jautājumi tiks saglabāti statistikā."
        case .continueQuiz: return "Turpināt"
        case .quitQuiz: return "Iziet"
        case .quitConfirmTitle: return "Pārtraukt treniņu?"
        case .quitConfirmMessage: return "Jūsu atbildētie jautājumi un kļūdas tiks saglabāti statistikā."
        case .exitAndReview: return "Pārtraukt un pārskatīt"
        case .stay: return "Turpināt treniņu"
        case .safetyQuestionBadge: return "Satiksmes drošība"

        // Summary
        case .quizCompleted: return "Treniņš pabeigts!"
        case .sessionEndedEarly: return "Treniņš pārtraukts"
        case .sessionEarlySubtitle(let n): return "Jūs atbildējāt uz \(n) jautājumiem."
        case .wellDone: return "Lielisks darbs! Teicams rezultāts."
        case .keepPracticing: return "Turpini trenēties, lai uzlabotu rezultātu!"
        case .yourAnswerLabel: return "Jūsu atbilde:"
        case .quit: return "Iziet"
        case .bestValueBadge: return "Ieteicamais"
        case .scoreResult(let c, let t): return "\(c) no \(t) pareizi"
        case .accuracy(let a): return "\(a)% precizitāte"
        case .accuracyLabel: return "Precizitāte"
        case .questionsAttempted: return "Atbildēti"
        case .correctStat: return "Pareizi"
        case .mistakesStat: return "Kļūdas"
        case .questionsToReview: return "Kļūdu pārskats"
        case .correctAnswerLabel: return "Pareizā atbilde:"
        case .noMistakesInSession: return "Nevienas kļūdas šajā treniņā!"
        case .practiceMistakesAction: return "Trenēt šīs kļūdas"
        case .reviewMistakes: return "Pārskatīt kļūdas"
        case .backToTopics: return "Atpakaļ pie tēmām"
        case .tryAgain: return "Mēģināt vēlreiz"

        // Mock Exam
        case .mockExamIntroTitle: return "CSDD B kategorijas testa eksāmens"
        case .mockExamIntroDescription: return "Oficiālā CSDD teorijas eksāmena simulācija. Pārbaudi savas zināšanas reālos eksāmena apstākļos."
        case .examRuleQuestions(let n): return "\(n) nejauši izvēlēti jautājumi"
        case .examRuleTime(let m): return "\(m) minūšu laika limits"
        case .examRuleAllowedErrors(let e): return "Atļautas ne vairāk kā \(e) kļūdas"
        case .examRulePassingScore(let p): return "Nepieciešamas vismaz \(p) pareizas atbildes"
        case .startExam: return "Sākt eksāmenu"
        case .timeRemaining: return "Atlikušais laiks"
        case .questionFlagged: return "Atzīmēts pārskatīšanai"
        case .flagForReview: return "Atzīmēt jautājumu"
        case .unflagQuestion: return "Noņemt atzīmi"
        case .questionBoard: return "Jautājumu karte"
        case .reviewAll: return "Pārskatīt visas atbildes"
        case .reviewAllAnswers: return "Pārskatīt atbildes"
        case .answeredQuestions(let a, let t): return "\(a) no \(t) atbildēti"
        case .submitExam: return "Iesniegt eksāmenu"
        case .submitExamConfirmTitle: return "Vai tiešām vēlaties iesniegt?"
        case .submitExamConfirmMessage(let u):
            if u > 0 {
                return "Jums ir \(u) neatbildēti jautājumi. Iesniedzot tie tiks ieskaitīti kā kļūdas."
            } else {
                return "Visi jautājumi ir atbildēti. Vai vēlaties pabeigt eksāmenu?"
            }
        case .cancel: return "Atcelt"
        case .submit: return "Iesniegt"
        case .passed: return "Nokārtots! 🎉"
        case .notPassed: return "Nav nokārtots"
        case .examPassedTitle: return "Apsveicam! Eksāmens nokārtots! 🎉"
        case .examFailedTitle: return "Eksāmens nav nokārtots"
        case .examScoreLabel: return "Rezultāts"
        case .errorsLabel: return "Kļūdas"
        case .safetyErrors: return "Drošība"
        case .examScore(let s, let t): return "Rezultāts: \(s) no \(t)"
        case .examErrorsCount(let e, let m): return "\(e) kļūdas (atļauts max \(m))"
        case .reviewQuestions: return "Pārskatīt atbildes"
        case .retakeExam: return "Kārtot eksāmenu vēlreiz"
        case .backToHome: return "Uz sākumu"

        // Mistakes
        case .noMistakesTitle: return "Nav nevienas kļūdas!"
        case .noMistakesSubtitle: return "Lielisks darbs! Pieļautās kļūdas parādīsies šeit, lai jūs varētu tās atkārtot."
        case .practiceMistakes: return "Trenēt kļūdas"
        case .clearMasteredMistakes: return "Notīrīt apgūtās kļūdas"
        case .mistakeCountBadge(let n): return "\(n) kļūdas"

        // Road Signs
        case .roadSignsCategoryTitle: return "Ceļa zīmju kategorijas"
        case .signQuizTitle: return "Zīmju tests"
        case .signQuizSubtitle: return "Pārbaudi ceļa zīmju atpazīšanu"
        case .searchSigns: return "Meklēt ceļa zīmi..."
        case .allSigns: return "Visas zīmes"
        case .learnSigns: return "Zīmju saraksts"
        case .practiceSigns: return "Mācību kartītes"
        case .signCategoryAll: return "Visas kategorijas"
        case .signCode(let c): return "Zīme \(c)"
        case .signQuiz: return "Zīmju tests"
        case .flashcardsLockedTitle: return "Ceļa zīmju mācību kartītes"
        case .flashcardsLockedSubtitle: return "Apgūsti visas Latvijas ceļa zīmes ar ērtām divpusējām kartītēm."
        case .signTestLockedTitle: return "Ceļa zīmju zināšanu tests"
        case .signTestLockedSubtitle: return "Pārbaudi savas spējas atpazīt priekšrokas, aizlieguma un brīdinājuma zīmes."

        // Mock Exam Additional
        case .mockExamRulesTitle: return "CSDD B kategorijas eksāmena noteikumi"
        case .officialCategoryBRules: return "Oficiālā teorijas eksāmena prasības un nosacījumi"
        case .oneFreeMockBadge: return "1 bezmaksas testa eksāmens"
        case .mockExamCompletedTitle: return "Bezmaksas eksāmens pabeigts"
        case .mockExamCompletedDescription: return "Jūs esat pabeidzis savu bezmaksas testa eksāmenu. Pārejiet uz Premium, lai iegūtu neierobežotus eksāmenus un pilnu jautājumu banku."
        case .unlockUnlimitedMocks: return "Atbloķēt neierobežotus eksāmenus"
        case .examDuration: return "Eksāmena ilgums"
        case .passingRequirements: return "Nokārtošanas prasības"
        case .strictSafetyLimit: return "Satiksmes drošības jautājumi"
        case .startFreeMock: return "Sākt bezmaksas eksāmenu"

        // Practice Additional
        case .freeQuestionsAvailable(let count): return "\(count) bezmaksas jautājumi"
        case .premiumLockedTopic: return "Tikai Premium"
        case .unlockAllTopicQuestions(let count): return "Atbloķēt visus \(count) jautājumus ar Premium"

        // Mistakes Additional
        case .activeMistakes(let count): return "\(count) aktīvas kļūdas"
        case .practiceMyMistakes: return "Trenēt manas kļūdas"

        // General
        case .done: return "Gatavs"
        case .close: return "Aizvērt"
        case .errorTitle: return "Kļūda"
        case .ok: return "Labi"

        // Paywall & Premium
        case .paywallTitle: return "Sagatavojies eksāmenam pārliecinoši"
        case .paywallSubtitle: return "Nodrošini sekmīgu CSDD teorijas eksāmena nokārtošanu ar pirmo reizi."
        case .unlockWithPremium: return "Atbloķēt ar Premium"
        case .premiumActiveStatus: return "Aktīvs"
        case .premiumLifetimeStatus: return "Mūža piekļuve"
        case .viewPremiumButton: return "Iegūt pilno versiju"
        case .termsOfService: return "Lietošanas noteikumi"
        case .privacyPolicy: return "Privātuma politika"
        case .unlockFullAccessSubtitle: return "Atveriet pilnu piekļuvi visiem sagatavošanās materiāliem."
        case .purchasesUnavailable: return "Pirkumi pašlaik nav pieejami. Lūdzu, mēģiniet vēlāk."
        case .loadingPurchases: return "Ielādē pirkumus..."
        case .retryLoading: return "Mēģināt vēlreiz"
        case .sectionPremium: return "Premium versija"
        case .proCardTitle: return "CSDD Teorija Pro"
        case .freePlan: return "Bezmaksas versija"
        case .freePlanDescription: return "Ierobežots jautājumu skaits un 1 testa eksāmens. Pārejiet uz pilno versiju, lai piekļūtu visiem materiāliem."
        case .upgradeToPro: return "Pāriet uz Pro"
        case .premiumActive: return "Premium ir aktīvs"
        case .lifetimeAccess: return "Mūža piekļuve bez abonēšanas"
        case .studyPreferences: return "Mācību iestatījumi"
        case .dailyGoal: return "Dienas mērķis"
        case .studyReminder: return "Mācību atgādinājums"
        case .reminderTime: return "Atgādinājuma laiks"
        case .progress: return "Progress"
        case .resetProgressTitle: return "Dzēst visu progresu?"
        case .resetProgressMessage: return "Tas dzēsīs visus treniņu rezultātus, kļūdas un eksāmenu vēsturi. Šo darbību nevar atsaukt."
        case .about: return "Par lietotni"
        case .appNameLabel: return "Lietotnes nosaukums"
        case .subtitleLabel: return "Apraksts"
        case .versionLabel: return "Versija"
        case .supportLabel: return "Atbalsts"
        case .supportWebsiteLabel: return "Atbalsta vietne"
        case .privacyPolicyLabel: return "Privātuma politika"
        case .termsOfUseLabel: return "Lietošanas noteikumi"
        case .legal: return "Juridiskā informācija"
        case .disclaimerLabel: return "Atruna par CSDD"
        case .governmentDisclaimerText: return "CSDD Teorijas Eksāmens ir neatkarīgs mācību līdzeklis un nav saistīts ar Ceļu satiksmes drošības direkciju (CSDD) vai Latvijas Republiku, kā arī nav to apstiprināts vai sponsorēts."
        case .restorePurchases: return "Atjaunot pirkumus"
        case .restorePurchasesSuccess: return "Pirkumi ir veiksmīgi atjaunoti."
        case .restorePurchasesNotFound: return "Iepriekšējs pirkums šim Apple ID netika atrasts."

        // Pro Monetization & Paywall
        case .paywallBenefit1: return "Pilna jautājumu banka"
        case .paywallBenefit2: return "Neierobežoti izmēģinājuma eksāmeni"
        case .paywallBenefit3: return "Detalizēti skaidrojumi"
        case .paywallBenefit4: return "Kļūdu atkārtošana"
        case .paywallBenefit5: return "Visas tēmas"
        case .paywallBenefit6: return "Visas ceļa zīmes"
        case .paywallBenefit7: return "Progresa statistika"
        case .proLifetimeTitle: return "PRO uz mūžu"
        case .proLifetimeSubtitle: return "Vienreizējs pirkums"
        case .proMonthlyTitle: return "PRO mēnesim"
        case .proMonthlyPerMonth: return "/ mēnesī"
        case .proBestValueBadge: return "LABĀKĀ VĒRTĪBA"
        case .proLifetimeCTA: return "Iegūt PRO uz mūžu"
        case .proMonthlyCTA: return "Sākt PRO"
        case .proSubscriptionNotice: return "Abonements tiek automātiski atjaunots katru mēnesi. To var jebkurā laikā pārvaldīt vai atcelt savos Apple konta iestatījumos."
        case .proInactiveStatus: return "PRO nav aktīvs"
        case .proMonthlyStatus: return "PRO mēneša abonements"
        case .proLifetimeStatus: return "PRO uz mūžu"
        case .proLifetimeActiveStatus: return "PRO uz mūžu aktīvs"
        case .proActiveStatus: return "PRO aktīvs"
        case .manageSubscription: return "Pārvaldīt abonementu"
        case .proAlreadyLifetimeMessage: return "Jums jau ir aktīva pilna mūža piekļuve visām iespējām."
        case .upgradeToLifetimePrompt: return "Pāriet uz PRO mūža piekļuvi"

        // Daily Goal
        case .dailyGoalTitle: return "Dienas mērķis"
        case .dailyGoalCardLabel: return "Šodienas mērķis"
        case .dailyGoalCompleted: return "Dienas mērķis sasniegts! ✓"
        case .dailyGoalProgress(let done, let target): return "\(done) / \(target) jautājumi"
        case .chooseGoal: return "Izvēlēties dienas mērķi"
        case .goal5: return "5 jautājumi dienā"
        case .goal10: return "10 jautājumi dienā"
        case .goal20: return "20 jautājumi dienā"
        case .goal30: return "30 jautājumi dienā"
        case .goalCustom: return "Pielāgots"
        case .questionsPerDay(let n): return "\(n) jautājumi / dienā"

        // Streak
        case .studyStreak: return "Mācību sērija"
        case .streakDays(let n): return n == 1 ? "1 diena pēc kārtas" : "\(n) dienas pēc kārtas"
        case .streakZero: return "Sāc savu sēriju šodien!"

        // Readiness
        case .examReadinessExplanation: return "Gatavības rādītājs atspoguļo jūsu nesenos rezultātus un tēmu apguvi."
        case .examReadinessNotEnoughData: return "Atbildi uz vairāk jautājumiem, lai aprēķinātu gatavību eksāmenam."
        case .examReadinessInfoTitle: return "Par eksāmena gatavību"

        // Mock Chart
        case .mockScoreTrend: return "Testa eksāmenu dinamika"
        case .mockScoreTrendEmpty: return "Pabeidz testa eksāmenu, lai šeit redzētu rezultātu grafiku."
        case .mockPassLabel: return "Nokārtots"
        case .mockFailLabel: return "Nenokārtots"

        // Activity Calendar
        case .activityCalendar: return "Mācību aktivitāte"
        case .activityCalendarEmpty: return "Sāc treniņu, lai redzētu aktivitātes kalendāru."
        case .activityNoData: return "Nav aktivitātes"
        case .activityLightLabel: return "Maza"
        case .activityMediumLabel: return "Vidēja"
        case .activityStrongLabel: return "Augsta"
        case .activityDayDetail(let q, let acc, let mocks):
            var parts: [String] = []
            parts.append("\(q) jautājumi")
            if q > 0 { parts.append("\(acc)% precizitāte") }
            if mocks > 0 { parts.append("\(mocks) eksāmeni") }
            return parts.joined(separator: "  •  ")

        // Topic Performance
        case .topicPerformanceTitle: return "Sekmes pa tēmām"
        case .topicAccuracy(let a): return "\(a)% precizitāte"
        case .topicAttempted(let n): return "\(n) mēģinājumi"
        case .topicMastered(let n): return "\(n) apgūti"
        case .topicStrong: return "Labi"
        case .topicWeak: return "Jāuzlabo"
        case .topicNoData: return "Nav sākts"
        case .weakTopicsSection: return "Tēmas, kurām jāpievērš uzmanība"

        // Reminder
        case .dailyReminderTitle: return "Dienas atgādinājums"
        case .dailyReminderSubtitle: return "Regulārs atgādinājums palīdz uzturēt mācību tempu."
        case .reminderEnabled: return "Ieslēgts"
        case .reminderDisabled: return "Izslēgts"
        case .reminderTimeLabel: return "Atgādinājuma laiks"
        case .reminderPermissionDenied: return "Paziņojumi nav atļauti"
        case .reminderPermissionDeniedMessage: return "Lūdzu, atļaujiet paziņojumus ierīces Iestatījumos."

        // Statistics
        case .statsTitle: return "Statistika"
        case .statsBestMockScore: return "Labākais rezultāts"
        case .statsMockExamsCompleted: return "Eksāmeni"
        case .statsMistakesRemaining: return "Kļūdas"
        }
    }

    private var localizedEnglish: String {
        switch self {
        // Navigation / Tabs
        case .tabHome: return "Home"
        case .tabPractice: return "Practice"
        case .tabProgress: return "Progress"
        case .tabSettings: return "Settings"

        // Home
        case .appTitle: return "CSDD Theory"
        case .categoryB: return "Category B"
        case .examReadiness: return "Exam Readiness"
        case .questionsMastered: return "Questions Mastered"
        case .mockExamPerformance: return "Mock Exam Scores"
        case .weakTopics: return "Weak Topics"
        case .continuePractice: return "Continue Practice"
        case .resumeRecentTopic: return "Resume Recent Topic"
        case .mockExamTitle: return "Mock Exam"
        case .mockExamSubtitle: return "30 questions • 30 mins • Max 3 errors"
        case .practiceQuestionsTitle: return "Practice by Topic"
        case .practiceQuestionsSubtitle: return "Study questions with instant rule explanations"
        case .myMistakesTitle: return "My Mistakes"
        case .myMistakesSubtitle: return "Review and master incorrectly answered questions"
        case .roadSignsTitle: return "Road Signs"
        case .roadSignsSubtitle: return "Latvian road signs catalog & identification quiz"

        // Practice
        case .allTopics: return "All Topics"
        case .practiceCategories: return "Study Categories"
        case .startPractice: return "Start Practice"
        case .questionCount(let n): return "\(n) questions"
        case .topicMastery(let m): return "\(m)% mastered"

        // Quiz / Question Flow
        case .questionProgress(let current, let total): return "\(current) of \(total)"
        case .questionOf(let current, let total): return "\(current) of \(total)"
        case .checkAnswer: return "Check Answer"
        case .nextQuestion: return "Next Question"
        case .finishQuiz: return "Finish Practice"
        case .correct: return "Correct! ✓"
        case .incorrect: return "Incorrect ✕"
        case .explanationTitle: return "Rule Explanation"
        case .whyExplanation: return "Why is this correct?"
        case .keyTakeawayTitle: return "Key Rule"
        case .legalReference: return "Legal Reference (CSN)"
        case .exitQuizTitle: return "Exit Practice?"
        case .exitQuizMessage: return "Your answered questions will be saved to your statistics."
        case .continueQuiz: return "Continue"
        case .quitQuiz: return "Quit"
        case .quitConfirmTitle: return "Exit Practice?"
        case .quitConfirmMessage: return "Your answered questions and mistakes will be saved to your progress."
        case .exitAndReview: return "Exit & Review"
        case .stay: return "Continue Practice"
        case .safetyQuestionBadge: return "Traffic Safety"

        // Summary
        case .quizCompleted: return "Practice Completed!"
        case .sessionEndedEarly: return "Practice Ended Early"
        case .sessionEarlySubtitle(let n): return "You answered \(n) questions."
        case .wellDone: return "Well done! Great result."
        case .keepPracticing: return "Keep practicing to improve your score!"
        case .yourAnswerLabel: return "Your answer:"
        case .quit: return "Quit"
        case .bestValueBadge: return "Recommended"
        case .scoreResult(let c, let t): return "\(c) of \(t) correct"
        case .accuracy(let a): return "\(a)% accuracy"
        case .accuracyLabel: return "Accuracy"
        case .questionsAttempted: return "Attempted"
        case .correctStat: return "Correct"
        case .mistakesStat: return "Mistakes"
        case .questionsToReview: return "Questions to Review"
        case .correctAnswerLabel: return "Correct answer:"
        case .noMistakesInSession: return "No mistakes in this session!"
        case .practiceMistakesAction: return "Practice These Mistakes"
        case .reviewMistakes: return "Review Mistakes"
        case .backToTopics: return "Back to Topics"
        case .tryAgain: return "Try Again"

        // Mock Exam
        case .mockExamIntroTitle: return "CSDD Category B Mock Exam"
        case .mockExamIntroDescription: return "Simulate the real Latvian CSDD theory test under official examination conditions."
        case .examRuleQuestions(let n): return "\(n) randomly chosen questions"
        case .examRuleTime(let m): return "\(m) minutes time limit"
        case .examRuleAllowedErrors(let e): return "Maximum \(e) mistakes allowed"
        case .examRulePassingScore(let p): return "At least \(p) correct answers to pass"
        case .startExam: return "Start Exam"
        case .timeRemaining: return "Time Remaining"
        case .questionFlagged: return "Marked for Review"
        case .flagForReview: return "Flag Question"
        case .unflagQuestion: return "Remove Flag"
        case .questionBoard: return "Question Board"
        case .reviewAll: return "Review All Answers"
        case .reviewAllAnswers: return "Review Answers"
        case .answeredQuestions(let a, let t): return "\(a) of \(t) answered"
        case .submitExam: return "Submit Exam"
        case .submitExamConfirmTitle: return "Submit Exam?"
        case .submitExamConfirmMessage(let u):
            if u > 0 {
                return "You have \(u) unanswered question(s). Unanswered questions will be counted as errors."
            } else {
                return "All questions have been answered. Would you like to finish the exam?"
            }
        case .cancel: return "Cancel"
        case .submit: return "Submit"
        case .passed: return "Passed! 🎉"
        case .notPassed: return "Not Passed"
        case .examPassedTitle: return "Congratulations! Exam Passed! 🎉"
        case .examFailedTitle: return "Exam Not Passed"
        case .examScoreLabel: return "Score"
        case .errorsLabel: return "Errors"
        case .safetyErrors: return "Safety"
        case .examScore(let s, let t): return "Score: \(s) of \(t)"
        case .examErrorsCount(let e, let m): return "\(e) errors (max allowed: \(m))"
        case .reviewQuestions: return "Review Questions"
        case .retakeExam: return "Retake Exam"
        case .backToHome: return "Back to Home"

        // Mistakes
        case .noMistakesTitle: return "No Mistakes Yet!"
        case .noMistakesSubtitle: return "Great job! Any questions you answer incorrectly will appear here for focused review."
        case .practiceMistakes: return "Practice Mistakes"
        case .clearMasteredMistakes: return "Clear Mastered Mistakes"
        case .mistakeCountBadge(let n): return "\(n) mistakes"

        // Road Signs
        case .roadSignsCategoryTitle: return "Road Sign Categories"
        case .signQuizTitle: return "Sign Quiz"
        case .signQuizSubtitle: return "Test your knowledge of Latvian road signs"
        case .searchSigns: return "Search road signs..."
        case .allSigns: return "All Signs"
        case .learnSigns: return "Browse Signs"
        case .practiceSigns: return "Flashcards"
        case .signCategoryAll: return "All Categories"
        case .signCode(let c): return "Sign \(c)"
        case .signQuiz: return "Sign Test"
        case .flashcardsLockedTitle: return "Road Sign Flashcards"
        case .flashcardsLockedSubtitle: return "Master all Latvian road signs with interactive double-sided flashcards."
        case .signTestLockedTitle: return "Road Sign Knowledge Test"
        case .signTestLockedSubtitle: return "Test your ability to recognize priority, warning, and prohibitory signs."

        // Mock Exam Additional
        case .mockExamRulesTitle: return "CSDD Category B Exam Rules"
        case .officialCategoryBRules: return "Official theory exam requirements and standards"
        case .oneFreeMockBadge: return "1 Free Mock Exam Available"
        case .mockExamCompletedTitle: return "Free Mock Exam Completed"
        case .mockExamCompletedDescription: return "You have completed your 1 free mock exam. Upgrade to Premium for unlimited exams, full question bank, and analytics."
        case .unlockUnlimitedMocks: return "Unlock Unlimited Mock Exams"
        case .examDuration: return "Exam Duration"
        case .passingRequirements: return "Passing Requirements"
        case .strictSafetyLimit: return "Traffic Safety Questions"
        case .startFreeMock: return "Start Free Mock Exam"

        // Practice Additional
        case .freeQuestionsAvailable(let count): return "\(count) free questions"
        case .premiumLockedTopic: return "Premium Only"
        case .unlockAllTopicQuestions(let count): return "Unlock all \(count) questions with Premium"

        // Mistakes Additional
        case .activeMistakes(let count): return "\(count) active mistakes"
        case .practiceMyMistakes: return "Practice My Mistakes"

        // General
        case .done: return "Done"
        case .close: return "Close"
        case .errorTitle: return "Error"
        case .ok: return "OK"

        // Paywall & Premium
        case .paywallTitle: return "Pass Your CSDD Exam With Confidence"
        case .paywallSubtitle: return "Unlock complete preparation tools for the Latvian Category B theory examination."
        case .unlockWithPremium: return "Unlock With Premium"
        case .premiumActiveStatus: return "Active"
        case .premiumLifetimeStatus: return "Lifetime Access"
        case .viewPremiumButton: return "Upgrade to Premium"
        case .termsOfService: return "Terms of Use"
        case .privacyPolicy: return "Privacy Policy"
        case .unlockFullAccessSubtitle: return "Unlock all study features to prepare for your theory exam."
        case .purchasesUnavailable: return "Purchases are temporarily unavailable. Please try again later."
        case .loadingPurchases: return "Loading purchases..."
        case .retryLoading: return "Retry"
        case .sectionPremium: return "Premium"
        case .proCardTitle: return "CSDD Theory Pro"
        case .freePlan: return "Free Plan"
        case .freePlanDescription: return "Limited sample questions and 1 free mock exam. Unlock Pro for the full question bank and unlimited exams."
        case .upgradeToPro: return "Upgrade to Pro"
        case .premiumActive: return "Premium Active"
        case .lifetimeAccess: return "Lifetime Access • One-time purchase"
        case .studyPreferences: return "Study Preferences"
        case .dailyGoal: return "Daily Goal"
        case .studyReminder: return "Study Reminder"
        case .reminderTime: return "Reminder Time"
        case .progress: return "Progress"
        case .resetProgressTitle: return "Reset All Progress?"
        case .resetProgressMessage: return "This will erase all practice history, mistakes, exam records, streaks and goals. This action cannot be undone."
        case .about: return "About"
        case .appNameLabel: return "App Name"
        case .subtitleLabel: return "Subtitle"
        case .versionLabel: return "Version"
        case .supportLabel: return "Support"
        case .supportWebsiteLabel: return "Support Website"
        case .privacyPolicyLabel: return "Privacy Policy"
        case .termsOfUseLabel: return "Terms of Use"
        case .legal: return "Legal"
        case .disclaimerLabel: return "CSDD Disclaimer"
        case .governmentDisclaimerText: return "CSDD Teorijas Eksāmens is an independent educational tool and is not affiliated with, endorsed by, or sponsored by CSDD or the Republic of Latvia."
        case .restorePurchases: return "Restore Purchases"
        case .restorePurchasesSuccess: return "Purchases have been successfully restored."
        case .restorePurchasesNotFound: return "No previous purchase was found for this Apple ID."

        // Pro Monetization & Paywall
        case .paywallBenefit1: return "Full question bank"
        case .paywallBenefit2: return "Unlimited mock exams"
        case .paywallBenefit3: return "Detailed explanations"
        case .paywallBenefit4: return "Mistake practice"
        case .paywallBenefit5: return "All topics"
        case .paywallBenefit6: return "All road signs"
        case .paywallBenefit7: return "Progress statistics"
        case .proLifetimeTitle: return "PRO Lifetime"
        case .proLifetimeSubtitle: return "One-time purchase"
        case .proMonthlyTitle: return "PRO Monthly"
        case .proMonthlyPerMonth: return "/ month"
        case .proBestValueBadge: return "BEST VALUE"
        case .proLifetimeCTA: return "Get PRO Lifetime"
        case .proMonthlyCTA: return "Start PRO"
        case .proSubscriptionNotice: return "Subscription automatically renews every month. You can manage or cancel anytime in your Apple ID Account Settings."
        case .proInactiveStatus: return "PRO Inactive"
        case .proMonthlyStatus: return "PRO Monthly Subscription"
        case .proLifetimeStatus: return "PRO Lifetime"
        case .proLifetimeActiveStatus: return "PRO Lifetime Active"
        case .proActiveStatus: return "PRO Active"
        case .manageSubscription: return "Manage Subscription"
        case .proAlreadyLifetimeMessage: return "You already have active lifetime full access to all features."
        case .upgradeToLifetimePrompt: return "Upgrade to PRO Lifetime"

        // Daily Goal
        case .dailyGoalTitle: return "Daily Goal"
        case .dailyGoalCardLabel: return "Today's Goal"
        case .dailyGoalCompleted: return "Daily goal completed! ✓"
        case .dailyGoalProgress(let done, let target): return "\(done) / \(target) questions"
        case .chooseGoal: return "Choose Daily Goal"
        case .goal5: return "5 questions / day"
        case .goal10: return "10 questions / day"
        case .goal20: return "20 questions / day"
        case .goal30: return "30 questions / day"
        case .goalCustom: return "Custom"
        case .questionsPerDay(let n): return "\(n) questions / day"

        // Streak
        case .studyStreak: return "Study Streak"
        case .streakDays(let n): return n == 1 ? "1 day streak" : "\(n) days streak"
        case .streakZero: return "Start your streak today"

        // Readiness
        case .examReadinessExplanation: return "Readiness reflects your recent test accuracy and topic coverage."
        case .examReadinessNotEnoughData: return "Answer more questions to calculate your exam readiness."
        case .examReadinessInfoTitle: return "About Exam Readiness"

        // Mock Chart
        case .mockScoreTrend: return "Mock Exam Performance"
        case .mockScoreTrendEmpty: return "Complete a mock exam to see your score trajectory."
        case .mockPassLabel: return "Passed"
        case .mockFailLabel: return "Failed"

        // Activity Calendar
        case .activityCalendar: return "Study Activity"
        case .activityCalendarEmpty: return "Start practicing to track your daily study habits."
        case .activityNoData: return "No activity"
        case .activityLightLabel: return "Light"
        case .activityMediumLabel: return "Medium"
        case .activityStrongLabel: return "High"
        case .activityDayDetail(let q, let acc, let mocks):
            var parts: [String] = []
            parts.append("\(q) questions answered")
            if q > 0 { parts.append("\(acc)% accuracy") }
            if mocks > 0 { parts.append("\(mocks) mock exams") }
            return parts.joined(separator: "  •  ")

        // Topic Performance
        case .topicPerformanceTitle: return "Topic Performance"
        case .topicAccuracy(let a): return "\(a)% accuracy"
        case .topicAttempted(let n): return "\(n) attempted"
        case .topicMastered(let n): return "\(n) mastered"
        case .topicStrong: return "Good"
        case .topicWeak: return "Needs Work"
        case .topicNoData: return "Not started"
        case .weakTopicsSection: return "Areas to Improve"

        // Reminder
        case .dailyReminderTitle: return "Daily Reminder"
        case .dailyReminderSubtitle: return "Daily reminder notifications help you stay on track."
        case .reminderEnabled: return "Enabled"
        case .reminderDisabled: return "Disabled"
        case .reminderTimeLabel: return "Reminder Time"
        case .reminderPermissionDenied: return "Notifications Denied"
        case .reminderPermissionDeniedMessage: return "Please enable notifications in Settings to receive study reminders."

        // Statistics
        case .statsTitle: return "Statistics"
        case .statsBestMockScore: return "Best Mock Score"
        case .statsMockExamsCompleted: return "Exams"
        case .statsMistakesRemaining: return "Mistakes"
        }
    }
}
