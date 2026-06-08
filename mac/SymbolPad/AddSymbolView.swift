import SwiftUI

struct AddSymbolView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (Symbol) -> Void

    @State private var char = ""
    @State private var label = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Symbol").font(.headline)

            TextField("→", text: $char)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 28, design: .serif))
                .multilineTextAlignment(.center)
                .frame(width: 80)

            TextField("Label (e.g. Right arrow)", text: $label)
                .textFieldStyle(.roundedBorder)
                .onSubmit { submit() }

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add") { submit() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(char.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 280)
    }

    private func submit() {
        let c = char.trimmingCharacters(in: .whitespaces)
        guard !c.isEmpty else { return }
        let l = label.trimmingCharacters(in: .whitespaces)
        onAdd(Symbol(char: c, label: l.isEmpty ? c : l))
        dismiss()
    }
}
