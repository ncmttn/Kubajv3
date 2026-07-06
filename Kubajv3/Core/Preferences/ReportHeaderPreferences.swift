import Foundation

enum ReportField: Int, CaseIterable, Identifiable {
    case companyName
    case reportDate
    case location
    case reporter
    case projectCode

    var id: Int { rawValue }
}

enum ReportHeaderPreferences {
  private static let prefix = "report.header."

  static func value(for field: ReportField) -> String {
    UserDefaults.standard.string(forKey: key(for: field)) ?? ""
  }

  static func setValue(_ value: String, for field: ReportField) {
    UserDefaults.standard.set(value, forKey: key(for: field))
  }

  static var metadata: ExportMetadata {
    ExportMetadata(fields: ReportField.allCases.map { value(for: $0) })
  }

  private static func key(for field: ReportField) -> String {
    prefix + String(field.rawValue)
  }
}
