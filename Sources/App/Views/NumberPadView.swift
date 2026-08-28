import SwiftUI

/// Calculator-style number pad (7-8-9 top), large kid-friendly keys, positioned low
/// for two-handed iPad reach (§12). Keys are chunky world-tinted 3D buttons that
/// physically depress, so they read as game pieces over the environment art.
struct NumberPadView: View {
    @Environment(\.worldTheme) private var theme
    /// iPhone landscape = compact vertical → shorter keys/tighter spacing so the
    /// pad fits the short screen. iPad (regular) keeps the big two-handed keys.
    @Environment(\.verticalSizeClass) private var vSize
    let enterEnabled: Bool
    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    let onEnter: () -> Void
    /// Overrides the world tint on the digit keys (the parent gate shouldn't
    /// wear a kid-session world color).
    var keyTint: Color? = nil

    private let rows = [[7, 8, 9], [4, 5, 6], [1, 2, 3]]
    private var compact: Bool { vSize == .compact }
    private var keyHeight: CGFloat { compact ? 50 : 62 }
    private var gap: CGFloat { compact ? 10 : 14 }

    var body: some View {
        VStack(spacing: gap) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: gap) { ForEach(row, id: \.self) { digit(_: $0) } }
            }
            HStack(spacing: gap) {
                key(systemImage: "delete.left.fill",
                    base: Color(white: 0.42), deep: Color(white: 0.25), action: onDelete)
                    .accessibilityLabel("Delete")
                digit(0)
                key(systemImage: "checkmark",
                    base: enterBase, deep: enterBase.shaded(by: -0.35),
                    enabled: enterEnabled, action: onEnter)
                    .accessibilityLabel("Enter")
            }
        }
        .frame(maxWidth: compact ? 380 : 430)
    }

    /// Enter must never read as just another digit key. It is green by default
    /// ("go"), but four of the seven worlds are themselves green, teal or
    /// cyan — Aurora Summit, the last world, sits 2 degrees off the green, and
    /// Firefly Bayou, Giant's Grove and The Sunken Reef are within 42 — so on
    /// those pads a green Enter vanishes into the digits. When the world's key
    /// colour is within 45 degrees of the green, Enter switches to the warm
    /// gold instead, which is far from every world primary except Wandering
    /// Isles, and that world keeps the green.
    private var enterBase: Color {
        let keyColor = keyTint ?? theme.primary
        let green = Theme.Color.correct
        guard let d = keyColor.hueDistance(to: green), d < 45 else { return green }
        return Theme.Color.accent
    }

    private func digit(_ n: Int) -> some View {
        Button { onDigit(n) } label: {
            Text("\(n)").font(Theme.Font.number(compact ? 27 : 32))
                .frame(maxWidth: .infinity, minHeight: keyHeight)
        }
        .buttonStyle(ChunkyKeyStyle(base: keyTint ?? theme.primary,
                                    deep: keyTint.map { $0.shaded(by: -0.35) } ?? theme.deep))
    }

    private func key(systemImage: String, base: Color, deep: Color,
                     enabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage).font(.system(size: compact ? 21 : 25, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: keyHeight)
        }
        .buttonStyle(ChunkyKeyStyle(base: base, deep: deep))
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.45)
        .saturation(enabled ? 1 : 0.4)
    }
}
