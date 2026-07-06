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
    static func tr(_ key: String) -> String {
        AppLocalization.string(key)
    }

    enum App {
        static var name: String { L10n.tr("app.name") }
    }

    enum Splash {
        static var tagline: String { L10n.tr("splash.tagline") }
    }

    enum Tab {
        static var home: String { L10n.tr("tab.home") }
        static var groups: String { L10n.tr("tab.grouping") }
        static var folders: String { L10n.tr("tab.folders") }
        static var settings: String { L10n.tr("tab.settings") }
    }

    enum Common {
        static var cancel: String { L10n.tr("common.cancel") }
    }

    enum Home {
        static var diameterCm: String { L10n.tr("home.diameter_cm") }
        static var topDiameterCm: String { L10n.tr("home.top_diameter_cm") }
        static var buttDiameterCm: String { L10n.tr("home.butt_diameter_cm") }
        static var midDiameterCm: String { L10n.tr("home.mid_diameter_cm") }
        static var lengthM: String { L10n.tr("home.length_m") }
        static var quantity: String { L10n.tr("home.quantity") }
        static var calculate: String { L10n.tr("home.calculate") }
        static var calculateHollow: String { L10n.tr("home.calculate_hollow") }
        static var keyboardNext: String { L10n.tr("home.keyboard_next") }
        static var confirmClearTitle: String { L10n.tr("home.confirm_clear_title") }
        static var confirmClearMessage: String { L10n.tr("home.confirm_clear_message") }
        static var confirmClearAction: String { L10n.tr("home.confirm_clear_action") }
        static var confirmDeleteTitle: String { L10n.tr("home.confirm_delete_title") }
        static var confirmDeleteMessage: String { L10n.tr("home.confirm_delete_message") }
        static var confirmDeleteAction: String { L10n.tr("home.confirm_delete_action") }
        static var lumberBadge: String { L10n.tr("home.lumber_badge") }
        static var save: String { L10n.tr("home.save") }
        static var emptyState: String { L10n.tr("home.empty_state") }
        static var hollowBadge: String { L10n.tr("home.hollow_badge") }
        static var totalVolume: String { L10n.tr("home.total_volume") }
        static var logsCount: String { L10n.tr("home.logs_count") }
        static var avgDiameter: String { L10n.tr("home.avg_diameter") }
        static var cubicMeterUnit: String { L10n.tr("home.cubic_meter_unit") }
        static var recentAdditions: String { L10n.tr("home.recent_additions") }
        static var openGrouping: String { L10n.tr("home.open_grouping") }
        static var diameterIncrement: String { L10n.tr("home.diameter_increment") }
        static var tableNo: String { L10n.tr("home.table_no") }
        static var tableLength: String { L10n.tr("home.table_length") }
        static var tableQty: String { L10n.tr("home.table_qty") }
        static var tableDiameter: String { L10n.tr("home.table_diameter") }
        static var tableVol: String { L10n.tr("home.table_vol") }
        static var tableActions: String { L10n.tr("home.table_actions") }
        static var saveFileTitle: String { L10n.tr("home.save_file_title") }
        static var saveFileMessage: String { L10n.tr("home.save_file_message") }
        static var saveFilePlaceholder: String { L10n.tr("home.save_file_placeholder") }
        static var saveFileConfirm: String { L10n.tr("home.save_file_confirm") }

        static func smalianDiameterFormat(top: Double, butt: Double) -> String {
            String(
                format: L10n.tr("home.smalian_diameter_format"),
                DisplayFormatting.diameter(top),
                DisplayFormatting.diameter(butt)
            )
        }

        static func lumberDiameterFormat(width: Double, thickness: Double) -> String {
            String(
                format: L10n.tr("home.lumber_diameter_format"),
                DisplayFormatting.diameter(width),
                DisplayFormatting.diameter(thickness)
            )
        }

        static func diameterValue(_ value: Double) -> String {
            String(
                format: L10n.tr("home.diameter_value_format"),
                DisplayFormatting.diameter(value)
            )
        }

    }

    enum Grouping {
        static var overline: String { L10n.tr("grouping.overline") }
        static var title: String { L10n.tr("grouping.figma_title") }
        static var subtitle: String { L10n.tr("grouping.subtitle") }
        static var selectFolder: String { L10n.tr("grouping.select_folder") }
        static var noFolderSelected: String { L10n.tr("grouping.no_folder_selected") }
        static var selectFolderPrompt: String { L10n.tr("grouping.select_folder_prompt") }
        static var emptyState: String { L10n.tr("grouping.empty_state") }
        static var draftSession: String { L10n.tr("grouping.draft_session") }
        static var draftEmptyState: String { L10n.tr("grouping.draft_empty_state") }
        static var deleteFile: String { L10n.tr("grouping.delete_file") }
        static var confirmDeleteFileTitle: String { L10n.tr("grouping.confirm_delete_file_title") }
        static var confirmDeleteFileMessage: String { L10n.tr("grouping.confirm_delete_file_message") }
        static var totalVolume: String { L10n.tr("grouping.total_volume") }
        static var avgDiameter: String { L10n.tr("grouping.avg_diameter") }
        static var logCount: String { L10n.tr("grouping.log_count") }
        static func volumeValue(_ volume: Double) -> String {
            String(
                format: L10n.tr("grouping.volume_value_format"),
                DisplayFormatting.volume(volume)
            )
        }

    }

    enum Export {
        static var settingsTitle: String { L10n.tr("export.settings_title") }
        static var confirmPDF: String { L10n.tr("export.confirm_pdf") }
        static var confirmCSV: String { L10n.tr("export.confirm_csv") }
        static var pdfTitle: String { L10n.tr("export.pdf_title") }
        static var pdfColumnDiameter: String { L10n.tr("export.pdf_column_diameter") }
        static var pdfColumnLength: String { L10n.tr("export.pdf_column_length") }
        static var pdfColumnQuantity: String { L10n.tr("export.pdf_column_quantity") }
        static var pdfColumnVolume: String { L10n.tr("export.pdf_column_volume") }
        static var csvColumnDiameter: String { L10n.tr("export.csv_column_diameter") }
        static var csvColumnLength: String { L10n.tr("export.csv_column_length") }
        static var csvColumnQuantity: String { L10n.tr("export.csv_column_quantity") }
        static var csvColumnVolume: String { L10n.tr("export.csv_column_volume") }
        static var totalRowLabel: String { L10n.tr("export.total_row_label") }

        static func reportFieldLabel(_ field: ReportField) -> String {
            switch field {
            case .companyName:
                L10n.tr("export.report.company_name_label")
            case .reportDate:
                L10n.tr("export.report.report_date_label")
            case .location:
                L10n.tr("export.report.location_label")
            case .reporter:
                L10n.tr("export.report.reporter_label")
            case .projectCode:
                L10n.tr("export.report.project_code_label")
            }
        }

        static func reportFieldPlaceholder(_ field: ReportField) -> String {
            switch field {
            case .companyName:
                L10n.tr("export.report.company_name_placeholder")
            case .reportDate:
                L10n.tr("export.report.report_date_placeholder")
            case .location:
                L10n.tr("export.report.location_placeholder")
            case .reporter:
                L10n.tr("export.report.reporter_placeholder")
            case .projectCode:
                L10n.tr("export.report.project_code_placeholder")
            }
        }
    }

    enum Folders {
        static var title: String { L10n.tr("folders.title") }
        static var subtitle: String { L10n.tr("folders.subtitle") }
        static var emptyState: String { L10n.tr("folders.empty_state") }

        static func recordCount(_ count: Int) -> String {
            String(format: L10n.tr("folders.record_count_format"), count)
        }
    }

    enum Lumber {
        static var widthCm: String { L10n.tr("lumber.width_cm") }
        static var thicknessCm: String { L10n.tr("lumber.thickness_cm") }
    }

    enum Hollow {
        static var title: String { L10n.tr("hollow.title") }
        static var outerDiameter: String { L10n.tr("hollow.outer_diameter") }
        static var innerDiameter: String { L10n.tr("hollow.inner_diameter") }
        static var length: String { L10n.tr("hollow.length") }
        static var quantity: String { L10n.tr("hollow.quantity") }
        static var addToList: String { L10n.tr("hollow.add_to_list") }
        static var alternativeTitle: String { L10n.tr("hollow.alternative_title") }

        static func addDiameter(_ diameter: Int) -> String {
            String(
                format: L10n.tr("hollow.add_diameter_format"),
                diameter
            )
        }

        static func equivalentDiameter(_ diameter: Int) -> String {
            String(
                format: L10n.tr("hollow.equivalent_diameter_format"),
                diameter
            )
        }

        static func netVolume(_ volume: Double) -> String {
            String(
                format: L10n.tr("hollow.net_volume_format"),
                DisplayFormatting.volume(volume)
            )
        }
    }

    enum FolderSelection {
        static var title: String { L10n.tr("folder_selection.title") }
        static var createFolder: String { L10n.tr("folder_selection.create_folder") }
        static var createSubfolder: String { L10n.tr("folder_selection.create_subfolder") }
        static var namePlaceholder: String { L10n.tr("folder_selection.name_placeholder") }
        static var noFolders: String { L10n.tr("folder_selection.no_folders") }
        static var noSubfolders: String { L10n.tr("folder_selection.no_subfolders") }
        static var confirmSave: String { L10n.tr("folder_selection.confirm_save") }
        static var create: String { L10n.tr("folder_selection.create") }
    }

    enum Formula {
        static var smalian: String { L10n.tr("calculation_method.smalian") }
        static var huber: String { L10n.tr("calculation_method.huber") }
        static var newton: String { L10n.tr("calculation_method.newton") }
        static var ulker: String { L10n.tr("calculation_method.ulker") }
    }

    enum Model {
        static var folder: String { L10n.tr("model.folder") }
    }

    enum Settings {
        static var title: String { L10n.tr("settings.title") }
        static var generalSection: String { L10n.tr("settings.general_section") }
        static var highVolumeAlerts: String { L10n.tr("settings.high_volume_alerts") }
        static var darkMode: String { L10n.tr("settings.dark_mode") }
        static var hapticFeedback: String { L10n.tr("settings.haptic_feedback") }
        static var enginePreferencesSection: String { L10n.tr("settings.engine_preferences_section") }
        static var calculationMethod: String { L10n.tr("settings.calculation_method") }
        static var formulaSmalianSubtitle: String { L10n.tr("settings.formula_smalian_subtitle") }
        static var formulaHuberSubtitle: String { L10n.tr("settings.formula_huber_subtitle") }
        static var formulaNewtonSubtitle: String { L10n.tr("settings.formula_newton_subtitle") }
        static var formulaUlkerSubtitle: String { L10n.tr("settings.formula_ulker_subtitle") }
        static var supportSection: String { L10n.tr("settings.support_section") }
        static var rateUsTitle: String { L10n.tr("settings.rate_us_title") }
        static var rateUsSubtitle: String { L10n.tr("settings.rate_us_subtitle") }
        static var contactTitle: String { L10n.tr("settings.contact_title") }
        static var contactSubtitle: String { L10n.tr("settings.contact_subtitle") }
        static var contactEmailSubject: String { L10n.tr("settings.contact_email_subject") }
        static var reportHeaderSubtitle: String { L10n.tr("settings.report_header_subtitle") }
        static var languageSection: String { L10n.tr("settings.language_section") }
        static var languagePickerTitle: String { L10n.tr("settings.language_picker_title") }
        static var footerCompany: String { L10n.tr("settings.footer_company") }

        static func footerVersion(_ version: String) -> String {
            String(format: L10n.tr("settings.footer_version_format"), L10n.App.name.uppercased(), version)
        }

    }

    enum Onboarding {
        static var nextStep: String { L10n.tr("onboarding.next_step") }
        static var skipIntro: String { L10n.tr("onboarding.skip_intro") }
        static var getStarted: String { L10n.tr("onboarding.get_started") }
        static var step1TitleLine1: String { L10n.tr("onboarding.step1_title_line1") }
        static var step1TitleLine2: String { L10n.tr("onboarding.step1_title_line2") }
        static var step1Subtitle: String { L10n.tr("onboarding.step1_subtitle") }
        static var step2TitleLine1: String { L10n.tr("onboarding.step2_title_line1") }
        static var step2TitleLine2: String { L10n.tr("onboarding.step2_title_line2") }
        static var step2Subtitle: String { L10n.tr("onboarding.step2_subtitle") }
        static var step3TitleLine1: String { L10n.tr("onboarding.step3_title_line1") }
        static var step3TitleLine2: String { L10n.tr("onboarding.step3_title_line2") }
        static var step3Subtitle: String { L10n.tr("onboarding.step3_subtitle") }
    }
}
