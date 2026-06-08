import Foundation

class SymbolStore: ObservableObject {
    @Published var symbols: [Symbol] = []

    private lazy var fileURL: URL = {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".symbolpad")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("symbols.json")
    }()

    init() { load() }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let file = try? JSONDecoder().decode(SymbolsFile.self, from: data) else {
            symbols = Self.defaults
            save()
            return
        }
        symbols = file.symbols
    }

    func save() {
        let file = SymbolsFile(version: 1, symbols: symbols)
        guard let data = try? JSONEncoder().encode(file) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func add(_ symbol: Symbol) {
        symbols.append(symbol)
        save()
    }

    func delete(at offsets: IndexSet) {
        symbols.remove(atOffsets: offsets)
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        symbols.move(fromOffsets: source, toOffset: destination)
        save()
    }

    static let defaults: [Symbol] = [
        Symbol(char: "\u{2018}", label: "Single open quote"),
        Symbol(char: "\u{2019}", label: "Single close quote"),
        Symbol(char: "„",        label: "Double low quote"),
        Symbol(char: "\u{201D}", label: "Double close quote"),
        Symbol(char: "¡",        label: "Inverted exclamation"),
        Symbol(char: "–",        label: "En dash"),
        Symbol(char: "→",        label: "Right arrow"),
        Symbol(char: "≤",        label: "Less or equal"),
        Symbol(char: "±",        label: "Plus minus"),
    ]
}
