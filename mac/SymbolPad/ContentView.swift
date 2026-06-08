import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: SymbolStore
    @EnvironmentObject private var appState: AppState
    @AppStorage("theme") private var theme: AppTheme = .system
    @State private var copiedID: UUID?
    @State private var showAdd = false

    let columns = Array(repeating: GridItem(.fixed(90), spacing: 10), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            if appState.editMode {
                editHeader
                Divider()
                editList
            } else {
                grid
            }
        }
        .frame(width: 420)
        .preferredColorScheme(theme.colorScheme)
        .sheet(isPresented: $showAdd) {
            AddSymbolView { sym in store.add(sym) }
        }
    }

    // MARK: - Edit header (only visible in edit mode)

    private var editHeader: some View {
        HStack {
            Text("Edit Symbols")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Button {
                showAdd = true
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
            .padding(.trailing, 6)

            Button("Done") {
                appState.editMode = false
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Grid (normal mode, no header)

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(store.symbols) { sym in
                SymbolCard(sym: sym, copied: copiedID == sym.id) {
                    copy(sym)
                }
            }
        }
        .padding(12)
    }

    // MARK: - List (edit mode)

    private var editList: some View {
        List {
            ForEach($store.symbols) { $sym in
                HStack(spacing: 12) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    Text(sym.char)
                        .font(.system(size: 22, design: .serif))
                        .frame(width: 36, alignment: .center)
                    TextField("Label", text: $sym.label)
                        .textFieldStyle(.plain)
                        .onSubmit { store.save() }
                        .onChange(of: sym.label) { store.save() }
                    Spacer()
                    Button {
                        if let idx = store.symbols.firstIndex(where: { $0.id == sym.id }) {
                            store.delete(at: IndexSet(integer: idx))
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .onMove(perform: store.move)
        }
        .listStyle(.plain)
        .frame(height: min(CGFloat(store.symbols.count) * 46 + 8, 400))
    }

    // MARK: - Actions

    private func copy(_ sym: Symbol) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(sym.char, forType: .string)
        copiedID = sym.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if copiedID == sym.id { copiedID = nil }
        }
    }
}
