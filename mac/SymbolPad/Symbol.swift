import Foundation

struct Symbol: Identifiable, Codable, Equatable {
    var id: UUID
    var char: String
    var label: String

    init(id: UUID = UUID(), char: String, label: String) {
        self.id = id
        self.char = char
        self.label = label
    }
}

struct SymbolsFile: Codable {
    var version: Int
    var symbols: [Symbol]
}
