import SwiftUI

@Observable
final class AppPreferences {
    static let shared = AppPreferences()

    @ObservationIgnored
    @AppStorage(AppPreferenceKey.calculationMethod)
    private var calculationMethodRawValue = CalculationMethod.huber.rawValue

    @ObservationIgnored
    @AppStorage(AppPreferenceKey.appTheme)
    private var appThemeRawValue = AppTheme.system.rawValue

    var defaultCalculationMethod: CalculationMethod {
        get {
            CalculationMethod(rawValue: calculationMethodRawValue) ?? .huber
        }
        set {
            calculationMethodRawValue = newValue.rawValue
        }
    }

    var appTheme: AppTheme {
        get {
            AppTheme(rawValue: appThemeRawValue) ?? .system
        }
        set {
            appThemeRawValue = newValue.rawValue
        }
    }

    static var settingsCalculationMethods: [CalculationMethod] {
        [.smalian, .huber, .newton]
    }
}
