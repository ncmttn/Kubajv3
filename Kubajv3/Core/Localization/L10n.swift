import Foundation

enum L10n {
    enum App {
        static let name = String(localized: "app.name")
        static let sprintPlaceholder = String(localized: "app.sprint_placeholder")
    }

    enum Formula {
        static let smalian = String(localized: "calculation_method.smalian")
        static let huber = String(localized: "calculation_method.huber")
        static let newton = String(localized: "calculation_method.newton")
        static let ulker = String(localized: "calculation_method.ulker")

        static func displayName(for method: CalculationMethod) -> String {
            switch method {
            case .smalian:
                smalian
            case .huber:
                huber
            case .newton:
                newton
            case .ulker:
                ulker
            }
        }
    }

    enum Model {
        static let folder = String(localized: "model.folder")
        static let logRecord = String(localized: "model.log_record")
    }
}
