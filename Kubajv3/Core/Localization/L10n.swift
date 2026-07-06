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

    enum Tab {
        static let home = String(localized: "tab.home")
        static let records = String(localized: "tab.records")
        static let settings = String(localized: "tab.settings")
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

    enum Grouping {
        static let title = String(localized: "grouping.title")
        static let selectFolder = String(localized: "grouping.select_folder")
        static let noFolderSelected = String(localized: "grouping.no_folder_selected")
        static let selectFolderPrompt = String(localized: "grouping.select_folder_prompt")
        static let emptyState = String(localized: "grouping.empty_state")
        static let sortAscending = String(localized: "grouping.sort_ascending")
        static let sortDescending = String(localized: "grouping.sort_descending")
        static let exportPDF = String(localized: "grouping.export_pdf")
        static let exportCSV = String(localized: "grouping.export_csv")

        static func rowSummary(quantity: Int, volume: Double, recordCount: Int) -> String {
            String(
                format: String(localized: "grouping.row_summary_format"),
                quantity,
                DisplayFormatting.volume(volume),
                recordCount
            )
        }
    }

    enum Export {
        static let settingsTitle = String(localized: "export.settings_title")
        static let confirmPDF = String(localized: "export.confirm_pdf")
        static let confirmCSV = String(localized: "export.confirm_csv")
        static let pdfTitle = String(localized: "export.pdf_title")
        static let pdfColumnDiameter = String(localized: "export.pdf_column_diameter")
        static let pdfColumnLength = String(localized: "export.pdf_column_length")
        static let pdfColumnQuantity = String(localized: "export.pdf_column_quantity")
        static let pdfColumnVolume = String(localized: "export.pdf_column_volume")
        static let csvColumnDiameter = String(localized: "export.csv_column_diameter")
        static let csvColumnLength = String(localized: "export.csv_column_length")
        static let csvColumnQuantity = String(localized: "export.csv_column_quantity")
        static let csvColumnVolume = String(localized: "export.csv_column_volume")

        static func optionalFieldLabel(index: Int) -> String {
            switch index {
            case 0:
                String(localized: "export.optional_field_1_label")
            case 1:
                String(localized: "export.optional_field_2_label")
            case 2:
                String(localized: "export.optional_field_3_label")
            case 3:
                String(localized: "export.optional_field_4_label")
            case 4:
                String(localized: "export.optional_field_5_label")
            default:
                ""
            }
        }

        static func optionalFieldPlaceholder(index: Int) -> String {
            switch index {
            case 0:
                String(localized: "export.optional_field_1_placeholder")
            case 1:
                String(localized: "export.optional_field_2_placeholder")
            case 2:
                String(localized: "export.optional_field_3_placeholder")
            case 3:
                String(localized: "export.optional_field_4_placeholder")
            case 4:
                String(localized: "export.optional_field_5_placeholder")
            default:
                ""
            }
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

    enum Settings {
        static let title = String(localized: "settings.title")
        static let calculationSection = String(localized: "settings.calculation_section")
        static let defaultFormula = String(localized: "settings.default_formula")
        static let appearanceSection = String(localized: "settings.appearance_section")
        static let theme = String(localized: "settings.theme")
        static let languageSection = String(localized: "settings.language_section")
        static let openLanguageSettings = String(localized: "settings.open_language_settings")
        static let aboutSection = String(localized: "settings.about_section")
        static let versionLabel = String(localized: "settings.version_label")

        static func themeName(for theme: AppTheme) -> String {
            switch theme {
            case .system:
                String(localized: "settings.theme_system")
            case .light:
                String(localized: "settings.theme_light")
            case .dark:
                String(localized: "settings.theme_dark")
            }
        }
    }
}
