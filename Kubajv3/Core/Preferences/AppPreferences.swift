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

    var appLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(appLanguage.rawValue, forKey: AppPreferenceKey.appLanguage)
            AppLocalization.apply(languageCode: appLanguage.localeIdentifier)
        }
    }

    var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: AppPreferenceKey.hasCompletedOnboarding)
        }
    }

    var isHapticEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticEnabled, forKey: AppPreferenceKey.isHapticEnabled)
        }
    }

    var isHighVolumeAlertsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHighVolumeAlertsEnabled, forKey: AppPreferenceKey.isHighVolumeAlertsEnabled)
        }
    }

    private init() {
        let methodRaw = UserDefaults.standard.string(forKey: AppPreferenceKey.calculationMethod)
        defaultCalculationMethod = CalculationMethod(rawValue: methodRaw ?? "") ?? .huber

        let themeRaw = UserDefaults.standard.string(forKey: AppPreferenceKey.appTheme)
        appTheme = AppTheme(rawValue: themeRaw ?? "") ?? .system

        let languageRaw = UserDefaults.standard.string(forKey: AppPreferenceKey.appLanguage)
        appLanguage = AppLanguage(rawValue: languageRaw ?? "") ?? .tr

        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: AppPreferenceKey.hasCompletedOnboarding)

        if UserDefaults.standard.object(forKey: AppPreferenceKey.isHapticEnabled) == nil {
            isHapticEnabled = true
        } else {
            isHapticEnabled = UserDefaults.standard.bool(forKey: AppPreferenceKey.isHapticEnabled)
        }

        isHighVolumeAlertsEnabled = UserDefaults.standard.bool(forKey: AppPreferenceKey.isHighVolumeAlertsEnabled)

        AppLocalization.apply(languageCode: appLanguage.localeIdentifier)
    }

    static var settingsCalculationMethods: [CalculationMethod] {
        [.smalian, .huber, .newton, .ulker]
    }
}
