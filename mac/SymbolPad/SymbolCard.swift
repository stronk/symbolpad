import SwiftUI

struct SymbolCard: View {
    let sym: Symbol
    let copied: Bool
    let action: () -> Void

    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 6) {
                    Text(sym.char)
                        .font(.system(size: 28, design: .serif))
                    Text(sym.label)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 4)
                }
                .frame(width: 90, height: 90)
                .background(copied ? Color.green.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            copied  ? Color.green :
                            hovered ? Color.secondary.opacity(0.5) :
                                      Color.secondary.opacity(0.2),
                            lineWidth: 1
                        )
                )

                if copied {
                    Text("Copied")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.green)
                        .padding(.top, 7)
                        .padding(.trailing, 8)
                }
            }
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
