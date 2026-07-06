import Foundation
import SwiftData

@Model
final class Bolme {
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Istif.bolme)
    var istifler: [Istif]

    init(
        name: String,
        createdAt: Date = .now,
        istifler: [Istif] = []
    ) {
        self.name = name
        self.createdAt = createdAt
        self.istifler = istifler
    }
}
