import SwiftUI

enum KubajThemeColors {
    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 15 / 255, green: 17 / 255, blue: 21 / 255)
            : KubajColor.background
    }

    static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 28 / 255, green: 31 / 255, blue: 38 / 255)
            : KubajColor.surface
    }

    static func card(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 36 / 255, green: 40 / 255, blue: 48 / 255)
            : .white
    }

    static func inputBackground(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 48 / 255, green: 52 / 255, blue: 62 / 255)
            : KubajColor.inputBackground
    }

    static func textPrimary(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 245 / 255, green: 246 / 255, blue: 248 / 255)
            : KubajColor.textPrimary
    }

    static func textHeading(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255)
            : KubajColor.textHeading
    }

    static func textSecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 174 / 255, green: 181 / 255, blue: 194 / 255)
            : KubajColor.textSecondary
    }

    static func textMuted(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 130 / 255, green: 138 / 255, blue: 152 / 255)
            : KubajColor.textMuted
    }

    static func borderSubtle(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.08)
            : KubajColor.borderSubtle
    }

    /// Subtle alternating row tint when the length (boy) value changes between consecutive rows.
    static func lengthBandBackground(_ scheme: ColorScheme, bandIndex: Int) -> Color {
        guard bandIndex % 2 == 1 else {
            return .clear
        }
        return scheme == .dark
            ? Color.white.opacity(0.045)
            : KubajColor.primary.opacity(0.05)
    }
}
