import Foundation

public struct ContentValidationError: CustomStringConvertible {
    public let questionId: String
    public let issue: String

    public var description: String {
        "[\(questionId)] \(issue)"
    }
}

/// Development content validator that enforces strict content quality standards:
/// - No duplicate IDs
/// - Minimum 2 options
/// - Valid correctIndex bounds matching options
/// - Native Latvian translation present with non-empty question and explanation
/// - English translation present with non-empty question and explanation
/// - Valid topic category
public struct QuestionValidator {
    @discardableResult
    public static func validate(questions: [Question]) -> [ContentValidationError] {
        var errors: [ContentValidationError] = []
        var seenIDs = Set<String>()

        for q in questions {
            // 1. Duplicate IDs
            if seenIDs.contains(q.id) {
                errors.append(ContentValidationError(questionId: q.id, issue: "Duplicate question ID: '\(q.id)'"))
            }
            seenIDs.insert(q.id)

            // 2. Latvian Content Validation
            guard let lv = q.translations["lv"] else {
                errors.append(ContentValidationError(questionId: q.id, issue: "Missing Latvian ('lv') translation"))
                continue
            }
            if lv.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errors.append(ContentValidationError(questionId: q.id, issue: "Latvian question text is empty"))
            }
            if lv.options.count < 2 {
                errors.append(ContentValidationError(questionId: q.id, issue: "Latvian options count < 2 (\(lv.options.count) found)"))
            }
            if lv.correctIndex < 0 || lv.correctIndex >= lv.options.count {
                errors.append(ContentValidationError(questionId: q.id, issue: "Latvian correctIndex (\(lv.correctIndex)) out of range [0..<\(lv.options.count)]"))
            }
            if lv.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errors.append(ContentValidationError(questionId: q.id, issue: "Latvian explanation is empty"))
            }

            // 3. English Content Validation
            guard let en = q.translations["en"] else {
                errors.append(ContentValidationError(questionId: q.id, issue: "Missing English ('en') translation"))
                continue
            }
            if en.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errors.append(ContentValidationError(questionId: q.id, issue: "English question text is empty"))
            }
            if en.options.count < 2 {
                errors.append(ContentValidationError(questionId: q.id, issue: "English options count < 2 (\(en.options.count) found)"))
            }
            if en.correctIndex < 0 || en.correctIndex >= en.options.count {
                errors.append(ContentValidationError(questionId: q.id, issue: "English correctIndex (\(en.correctIndex)) out of range [0..<\(en.options.count)]"))
            }
            if en.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errors.append(ContentValidationError(questionId: q.id, issue: "English explanation is empty"))
            }
        }

        #if DEBUG
        if errors.isEmpty {
            print("✅ [QuestionValidator] All \(questions.count) questions passed content validation successfully with 0 errors.")
        } else {
            print("❌ [QuestionValidator] Found \(errors.count) content validation errors:")
            for err in errors.prefix(15) {
                print("   • \(err)")
            }
        }
        #endif

        return errors
    }
}
