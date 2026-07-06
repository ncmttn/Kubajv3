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
            L10n.tr("language.turkish")
        case .en:
            L10n.tr("language.english")
        case .de:
            L10n.tr("language.german")
        case .es:
            L10n.tr("language.spanish")
        case .pt:
            L10n.tr("language.portuguese")
        case .fr:
            L10n.tr("language.french")
        case .sv:
            L10n.tr("language.swedish")
        case .fi:
            L10n.tr("language.finnish")
        case .ru:
            L10n.tr("language.russian")
        }
    }
}
