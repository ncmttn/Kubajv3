import Foundation

enum DisplayFormatting {
    static func volume(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(3)))
    }

    static func diameter(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)))
    }

    static func length(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }
}

enum L10n {
    enum App {
        static let name = String(localized: "app.name")
    }

    enum Common {
        static let cancel = String(localized: "common.cancel")
    }

    enum Home {
        static let diameterCm = String(localized: "home.diameter_cm")
        static let lengthM = String(localized: "home.length_m")
        static let quantity = String(localized: "home.quantity")
        static let addEntry = String(localized: "home.add_entry")
        static let calculateHollow = String(localized: "home.calculate_hollow")
        static let save = String(localized: "home.save")
        static let emptyState = String(localized: "home.empty_state")
        static let swipeDelete = String(localized: "home.swipe_delete")
        static let swipeDecrease = String(localized: "home.swipe_decrease")
        static let swipeIncrease = String(localized: "home.swipe_increase")
        static let hollowBadge = String(localized: "home.hollow_badge")

        static func dimensions(diameter: Double, length: Double) -> String {
            String(
                format: String(localized: "home.dimensions_format"),
                DisplayFormatting.diameter(diameter),
                DisplayFormatting.length(length)
            )
        }

        static func rowSummary(quantity: Int, volume: Double) -> String {
            String(
                format: String(localized: "home.row_summary_format"),
                quantity,
                DisplayFormatting.volume(volume)
            )
        }
    }

    enum Hollow {
        static let title = String(localized: "hollow.title")
        static let outerDiameter = String(localized: "hollow.outer_diameter")
        static let innerDiameter = String(localized: "hollow.inner_diameter")
        static let length = String(localized: "hollow.length")
        static let quantity = String(localized: "hollow.quantity")
        static let addToList = String(localized: "hollow.add_to_list")

        static func equivalentDiameter(_ diameter: Int) -> String {
            String(
                format: String(localized: "hollow.equivalent_diameter_format"),
                diameter
            )
        }

        static func netVolume(_ volume: Double) -> String {
            String(
                format: String(localized: "hollow.net_volume_format"),
                DisplayFormatting.volume(volume)
            )
        }
    }

    enum FolderSelection {
        static let title = String(localized: "folder_selection.title")
        static let createFolder = String(localized: "folder_selection.create_folder")
        static let createSubfolder = String(localized: "folder_selection.create_subfolder")
        static let namePlaceholder = String(localized: "folder_selection.name_placeholder")
        static let noFolders = String(localized: "folder_selection.no_folders")
        static let noSubfolders = String(localized: "folder_selection.no_subfolders")
        static let confirmSave = String(localized: "folder_selection.confirm_save")
        static let create = String(localized: "folder_selection.create")
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
