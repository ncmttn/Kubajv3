import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }

    var resolvedColorScheme: ColorScheme {
        switch self {
        case .system, .light:
            .light
        case .dark:
            .dark
        }
    }
}
