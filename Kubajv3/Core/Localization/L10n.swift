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

    enum Splash {
        static let tagline = String(localized: "splash.tagline")
    }

    enum Tab {
        static let home = String(localized: "tab.home")
        static let groups = String(localized: "tab.grouping")
        static let folders = String(localized: "tab.folders")
        static let settings = String(localized: "tab.settings")
    }

    enum Common {
        static let cancel = String(localized: "common.cancel")
    }

    enum Home {
        static let diameterCm = String(localized: "home.diameter_cm")
        static let topDiameterCm = String(localized: "home.top_diameter_cm")
        static let buttDiameterCm = String(localized: "home.butt_diameter_cm")
        static let midDiameterCm = String(localized: "home.mid_diameter_cm")
        static let lengthM = String(localized: "home.length_m")
        static let quantity = String(localized: "home.quantity")
        static let addEntry = String(localized: "home.add_entry")
        static let calculate = String(localized: "home.calculate")
        static let calculateHollow = String(localized: "home.calculate_hollow")
        static let calculateLumber = String(localized: "home.calculate_lumber")
        static let keyboardNext = String(localized: "home.keyboard_next")
        static let confirmClearTitle = String(localized: "home.confirm_clear_title")
        static let confirmClearMessage = String(localized: "home.confirm_clear_message")
        static let confirmClearAction = String(localized: "home.confirm_clear_action")
        static let confirmDeleteTitle = String(localized: "home.confirm_delete_title")
        static let confirmDeleteMessage = String(localized: "home.confirm_delete_message")
        static let confirmDeleteAction = String(localized: "home.confirm_delete_action")
        static let lumberBadge = String(localized: "home.lumber_badge")
        static let save = String(localized: "home.save")
        static let emptyState = String(localized: "home.empty_state")
        static let swipeDelete = String(localized: "home.swipe_delete")
        static let swipeDecrease = String(localized: "home.swipe_decrease")
        static let swipeIncrease = String(localized: "home.swipe_increase")
        static let hollowBadge = String(localized: "home.hollow_badge")
        static let totalVolume = String(localized: "home.total_volume")
        static let logsCount = String(localized: "home.logs_count")
        static let avgDiameter = String(localized: "home.avg_diameter")
        static let cubicMeterUnit = String(localized: "home.cubic_meter_unit")
        static let recentAdditions = String(localized: "home.recent_additions")
        static let liveBadge = String(localized: "home.live_badge")
        static let viewFullHistory = String(localized: "home.view_full_history")
        static let openGrouping = String(localized: "home.open_grouping")
        static let diameterIncrement = String(localized: "home.diameter_increment")
        static let tableNo = String(localized: "home.table_no")
        static let tableLength = String(localized: "home.table_length")
        static let tableQty = String(localized: "home.table_qty")
        static let tableDiameter = String(localized: "home.table_diameter")
        static let tableVol = String(localized: "home.table_vol")
        static let tableActions = String(localized: "home.table_actions")
        static let saveFileTitle = String(localized: "home.save_file_title")
        static let saveFileMessage = String(localized: "home.save_file_message")
        static let saveFilePlaceholder = String(localized: "home.save_file_placeholder")
        static let saveFileConfirm = String(localized: "home.save_file_confirm")

        static func dimensions(diameter: Double, length: Double) -> String {
            String(
                format: String(localized: "home.dimensions_format"),
                DisplayFormatting.diameter(diameter),
                DisplayFormatting.length(length)
            )
        }

        static func dimFormat(length: Double, diameter: Double) -> String {
            String(
                format: String(localized: "home.dim_format"),
                DisplayFormatting.length(length),
                DisplayFormatting.diameter(diameter)
            )
        }

        static func smalianDimFormat(top: Double, butt: Double, length: Double) -> String {
            String(
                format: String(localized: "home.smalian_dim_format"),
                DisplayFormatting.diameter(top),
                DisplayFormatting.diameter(butt),
                DisplayFormatting.length(length)
            )
        }

        static func smalianDiameterFormat(top: Double, butt: Double) -> String {
            String(
                format: String(localized: "home.smalian_diameter_format"),
                DisplayFormatting.diameter(top),
                DisplayFormatting.diameter(butt)
            )
        }

        static func lumberDimFormat(width: Double, thickness: Double, length: Double) -> String {
            String(
                format: String(localized: "home.lumber_dim_format"),
                DisplayFormatting.diameter(width),
                DisplayFormatting.diameter(thickness),
                DisplayFormatting.length(length)
            )
        }

        static func lumberDiameterFormat(width: Double, thickness: Double) -> String {
            String(
                format: String(localized: "home.lumber_diameter_format"),
                DisplayFormatting.diameter(width),
                DisplayFormatting.diameter(thickness)
            )
        }

        static func diameterValue(_ value: Double) -> String {
            String(
                format: String(localized: "home.diameter_value_format"),
                DisplayFormatting.diameter(value)
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
        static let overline = String(localized: "grouping.overline")
        static let title = String(localized: "grouping.figma_title")
        static let subtitle = String(localized: "grouping.subtitle")
        static let selectFolder = String(localized: "grouping.select_folder")
        static let noFolderSelected = String(localized: "grouping.no_folder_selected")
        static let selectFolderPrompt = String(localized: "grouping.select_folder_prompt")
        static let emptyState = String(localized: "grouping.empty_state")
        static let draftSession = String(localized: "grouping.draft_session")
        static let draftEmptyState = String(localized: "grouping.draft_empty_state")
        static let sortAscending = String(localized: "grouping.sort_ascending")
        static let sortDescending = String(localized: "grouping.sort_descending")
        static let exportPDF = String(localized: "grouping.export_pdf")
        static let exportCSV = String(localized: "grouping.export_csv")
        static let deleteFile = String(localized: "grouping.delete_file")
        static let confirmDeleteFileTitle = String(localized: "grouping.confirm_delete_file_title")
        static let confirmDeleteFileMessage = String(localized: "grouping.confirm_delete_file_message")
        static let totalVolume = String(localized: "grouping.total_volume")
        static let activeBatches = String(localized: "grouping.active_batches")
        static let avgDiameter = String(localized: "grouping.avg_diameter")
        static let logCount = String(localized: "grouping.log_count")
        static let columnDiameter = String(localized: "grouping.column_diameter")
        static let columnLength = String(localized: "grouping.column_length")
        static let columnQuantity = String(localized: "grouping.column_quantity")
        static let columnVolume = String(localized: "grouping.column_volume")
        static let summaryLogs = String(localized: "grouping.summary_logs")
        static let summaryVolume = String(localized: "grouping.summary_volume")
        static let exportCardTitle = String(localized: "grouping.export_card_title")
        static let exportCardSubtitle = String(localized: "grouping.export_card_subtitle")

        static func rowSummary(quantity: Int, volume: Double, recordCount: Int) -> String {
            String(
                format: String(localized: "grouping.row_summary_format"),
                quantity,
                DisplayFormatting.volume(volume),
                recordCount
            )
        }

        static func volumeValue(_ volume: Double) -> String {
            String(
                format: String(localized: "grouping.volume_value_format"),
                DisplayFormatting.volume(volume)
            )
        }

        static func lengthValue(_ length: Double) -> String {
            String(
                format: String(localized: "grouping.length_value_format"),
                DisplayFormatting.length(length)
            )
        }

        static func sectionSummary(diameter: Double) -> String {
            String(
                format: String(localized: "grouping.section_summary_format"),
                DisplayFormatting.diameter(diameter)
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
        static let totalRowLabel = String(localized: "export.total_row_label")

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

        static func reportFieldLabel(_ field: ReportField) -> String {
            switch field {
            case .companyName:
                String(localized: "export.report.company_name_label")
            case .reportDate:
                String(localized: "export.report.report_date_label")
            case .location:
                String(localized: "export.report.location_label")
            case .reporter:
                String(localized: "export.report.reporter_label")
            case .projectCode:
                String(localized: "export.report.project_code_label")
            }
        }

        static func reportFieldPlaceholder(_ field: ReportField) -> String {
            switch field {
            case .companyName:
                String(localized: "export.report.company_name_placeholder")
            case .reportDate:
                String(localized: "export.report.report_date_placeholder")
            case .location:
                String(localized: "export.report.location_placeholder")
            case .reporter:
                String(localized: "export.report.reporter_placeholder")
            case .projectCode:
                String(localized: "export.report.project_code_placeholder")
            }
        }
    }

    enum Folders {
        static let title = String(localized: "folders.title")
        static let subtitle = String(localized: "folders.subtitle")
        static let emptyState = String(localized: "folders.empty_state")

        static func recordCount(_ count: Int) -> String {
            String(format: String(localized: "folders.record_count_format"), count)
        }
    }

    enum Lumber {
        static let title = String(localized: "lumber.title")
        static let widthCm = String(localized: "lumber.width_cm")
        static let thicknessCm = String(localized: "lumber.thickness_cm")
        static let lengthM = String(localized: "lumber.length_m")
        static let quantity = String(localized: "lumber.quantity")
        static let addToList = String(localized: "lumber.add_to_list")

        static func previewVolume(_ volume: String) -> String {
            String(format: String(localized: "lumber.preview_volume_format"), volume)
        }
    }

    enum Hollow {
        static let title = String(localized: "hollow.title")
        static let outerDiameter = String(localized: "hollow.outer_diameter")
        static let innerDiameter = String(localized: "hollow.inner_diameter")
        static let length = String(localized: "hollow.length")
        static let quantity = String(localized: "hollow.quantity")
        static let addToList = String(localized: "hollow.add_to_list")
        static let alternativeTitle = String(localized: "hollow.alternative_title")

        static func addDiameter(_ diameter: Int) -> String {
            String(
                format: String(localized: "hollow.add_diameter_format"),
                diameter
            )
        }

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
        static let generalSection = String(localized: "settings.general_section")
        static let highVolumeAlerts = String(localized: "settings.high_volume_alerts")
        static let darkMode = String(localized: "settings.dark_mode")
        static let hapticFeedback = String(localized: "settings.haptic_feedback")
        static let enginePreferencesSection = String(localized: "settings.engine_preferences_section")
        static let calculationMethod = String(localized: "settings.calculation_method")
        static let dataManagementSection = String(localized: "settings.data_management_section")
        static let exportPdfTitle = String(localized: "settings.export_pdf_title")
        static let exportPdfSubtitle = String(localized: "settings.export_pdf_subtitle")
        static let generatePdf = String(localized: "settings.generate_pdf")
        static let exportExcelTitle = String(localized: "settings.export_excel_title")
        static let exportExcelSubtitle = String(localized: "settings.export_excel_subtitle")
        static let exportSpreadsheet = String(localized: "settings.export_spreadsheet")
        static let formulaSmalianSubtitle = String(localized: "settings.formula_smalian_subtitle")
        static let formulaHuberSubtitle = String(localized: "settings.formula_huber_subtitle")
        static let formulaNewtonSubtitle = String(localized: "settings.formula_newton_subtitle")
        static let formulaUlkerSubtitle = String(localized: "settings.formula_ulker_subtitle")
        static let supportSection = String(localized: "settings.support_section")
        static let rateUsTitle = String(localized: "settings.rate_us_title")
        static let rateUsSubtitle = String(localized: "settings.rate_us_subtitle")
        static let contactTitle = String(localized: "settings.contact_title")
        static let contactSubtitle = String(localized: "settings.contact_subtitle")
        static let contactEmailSubject = String(localized: "settings.contact_email_subject")
        static let reportHeaderTitle = String(localized: "settings.report_header_title")
        static let reportHeaderSubtitle = String(localized: "settings.report_header_subtitle")
        static let saveReportHeader = String(localized: "settings.save_report_header")
        static let outputInfoTitle = String(localized: "settings.output_info_title")
        static let outputInfoBody = String(localized: "settings.output_info_body")
        static let professionalLookTitle = String(localized: "settings.professional_look_title")
        static let previewDraftTitle = String(localized: "settings.preview_draft_title")
        static let calculationSection = String(localized: "settings.calculation_section")
        static let defaultFormula = String(localized: "settings.default_formula")
        static let appearanceSection = String(localized: "settings.appearance_section")
        static let theme = String(localized: "settings.theme")
        static let languageSection = String(localized: "settings.language_section")
        static let languagePickerTitle = String(localized: "settings.language_picker_title")
        static let openLanguageSettings = String(localized: "settings.open_language_settings")
        static let aboutSection = String(localized: "settings.about_section")
        static let versionLabel = String(localized: "settings.version_label")
        static let footerCompany = String(localized: "settings.footer_company")

        static func footerVersion(_ version: String) -> String {
            String(format: String(localized: "settings.footer_version_format"), L10n.App.name.uppercased(), version)
        }

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

    enum Onboarding {
        static let nextStep = String(localized: "onboarding.next_step")
        static let skipIntro = String(localized: "onboarding.skip_intro")
        static let getStarted = String(localized: "onboarding.get_started")
        static let step1TitleLine1 = String(localized: "onboarding.step1_title_line1")
        static let step1TitleLine2 = String(localized: "onboarding.step1_title_line2")
        static let step1Subtitle = String(localized: "onboarding.step1_subtitle")
        static let step2TitleLine1 = String(localized: "onboarding.step2_title_line1")
        static let step2TitleLine2 = String(localized: "onboarding.step2_title_line2")
        static let step2Subtitle = String(localized: "onboarding.step2_subtitle")
        static let step3TitleLine1 = String(localized: "onboarding.step3_title_line1")
        static let step3TitleLine2 = String(localized: "onboarding.step3_title_line2")
        static let step3Subtitle = String(localized: "onboarding.step3_subtitle")
    }
}
