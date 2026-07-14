import Foundation

private var associatedLanguageBundleKey: UInt8 = 0

/// Bundle subclass that redirects localized string lookups to the bundle of the
/// currently selected in-app language, allowing the language to change at runtime
/// without relaunching the app.
final class LanguageAwareBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &associatedLanguageBundleKey) as? Bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

enum AppLocalization {
    private static let swizzleOnce: Void = {
        object_setClass(Bundle.main, LanguageAwareBundle.self)
    }()

    /// Points `Bundle.main` at the `.lproj` bundle for the given language code.
    static func apply(languageCode: String) {
        _ = swizzleOnce

        let bundle: Bundle?
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") {
            bundle = Bundle(path: path)
        } else {
            bundle = nil
        }

        objc_setAssociatedObject(
            Bundle.main,
            &associatedLanguageBundleKey,
            bundle,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    /// Resolves a localized string from the currently selected language bundle.
    static func string(_ key: String) -> String {
        Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }
}
