import SwiftUI

@Observable
final class AppPreferences {
    static let shared = AppPreferences()

    var defaultCalculationMethod: CalculationMethod {
        didSet {
            UserDefaults.standard.set(defaultCalculationMethod.rawValue, forKey: AppPreferenceKey.calculationMethod)
        }
    }

    var appTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(appTheme.rawValue, forKey: AppPreferenceKey.appTheme)
        }
    }

    var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: AppPreferenceKey.hasCompletedOnboarding)
        }
    }

    private init() {
        let methodRaw = UserDefaults.standard.string(forKey: AppPreferenceKey.calculationMethod)
        defaultCalculationMethod = CalculationMethod(rawValue: methodRaw ?? "") ?? .huber

        let themeRaw = UserDefaults.standard.string(forKey: AppPreferenceKey.appTheme)
        appTheme = AppTheme(rawValue: themeRaw ?? "") ?? .system

        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: AppPreferenceKey.hasCompletedOnboarding)
    }

    static var settingsCalculationMethods: [CalculationMethod] {
        [.smalian, .huber, .newton]
    }
}
