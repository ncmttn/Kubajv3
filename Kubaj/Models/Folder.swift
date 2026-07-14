import Foundation
import SwiftData

@Model
final class Folder {
    var name: String

    var parentFolder: Folder?

    @Relationship(deleteRule: .cascade, inverse: \Folder.parentFolder)
    var subFolders: [Folder]

    @Relationship(deleteRule: .cascade, inverse: \LogRecord.folder)
    var records: [LogRecord]

    init(
        name: String,
        parentFolder: Folder? = nil,
        subFolders: [Folder] = [],
        records: [LogRecord] = []
    ) {
        self.name = name
        self.parentFolder = parentFolder
        self.subFolders = subFolders
        self.records = records
    }
}
