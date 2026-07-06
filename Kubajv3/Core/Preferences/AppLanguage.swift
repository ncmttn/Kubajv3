import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case tr
    case en
    case de
    case es
    case pt
    case fr
    case sv
    case fi
    case ru

    var id: String { rawValue }

    var localeIdentifier: String { rawValue }

    var displayName: String {
        switch self {
        case .tr:
            String(localized: "language.turkish")
        case .en:
            String(localized: "language.english")
        case .de:
            String(localized: "language.german")
        case .es:
            String(localized: "language.spanish")
        case .pt:
            String(localized: "language.portuguese")
        case .fr:
            String(localized: "language.french")
        case .sv:
            String(localized: "language.swedish")
        case .fi:
            String(localized: "language.finnish")
        case .ru:
            String(localized: "language.russian")
        }
    }
}
