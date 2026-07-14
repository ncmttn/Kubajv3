import SwiftUI

enum KubajColor {
    static let primary = Color(red: 0 / 255, green: 88 / 255, blue: 188 / 255)
    static let primaryEnd = Color(red: 0 / 255, green: 112 / 255, blue: 235 / 255)
    static let background = Color(red: 249 / 255, green: 249 / 255, blue: 249 / 255)
    static let surface = Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255)
    static let inputBackground = Color(red: 226 / 255, green: 226 / 255, blue: 226 / 255)
    static let textPrimary = Color(red: 27 / 255, green: 27 / 255, blue: 27 / 255)
    static let textHeading = Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255)
    static let textSecondary = Color(red: 65 / 255, green: 71 / 255, blue: 85 / 255)
    static let textMuted = Color(red: 113 / 255, green: 119 / 255, blue: 134 / 255)
    static let tabActive = Color(red: 37 / 255, green: 99 / 255, blue: 235 / 255)
    static let tabInactive = Color(red: 148 / 255, green: 163 / 255, blue: 184 / 255)
    static let liveBadgeBackground = Color(red: 0 / 255, green: 88 / 255, blue: 188 / 255, opacity: 0.1)
    static let deleteActionBackground = Color(red: 255 / 255, green: 218 / 255, blue: 214 / 255, opacity: 0.2)
    static let borderSubtle = Color(red: 193 / 255, green: 198 / 255, blue: 215 / 255, opacity: 0.1)
}

enum KubajFont {
    static func labelCaps() -> Font {
        .system(size: 10, weight: .bold)
    }

    static func inputValue() -> Font {
        .system(size: 18, weight: .bold)
    }

    static func button() -> Font {
        .system(size: 18, weight: .bold)
    }

    static func sectionTitle() -> Font {
        .system(size: 18, weight: .bold)
    }

    static func volumeHero() -> Font {
        .system(size: 36, weight: .heavy)
    }

    static func statValue() -> Font {
        .system(size: 20, weight: .bold)
    }

    static func tabLabel() -> Font {
        .system(size: 11, weight: .medium)
    }
}

enum KubajMetric {
    static let cornerRadiusLarge: CGFloat = 24
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusSmall: CGFloat = 8
    static let horizontalPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 32
}
