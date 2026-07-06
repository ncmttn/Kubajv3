import Foundation
import SwiftData

@Model
final class Istif {
    var name: String
    var createdAt: Date

    var bolme: Bolme?

    @Relationship(deleteRule: .cascade, inverse: \LogRecord.istif)
    var logRecords: [LogRecord]

    init(
        name: String,
        createdAt: Date = .now,
        bolme: Bolme? = nil,
        logRecords: [LogRecord] = []
    ) {
        self.name = name
        self.createdAt = createdAt
        self.bolme = bolme
        self.logRecords = logRecords
    }
}
