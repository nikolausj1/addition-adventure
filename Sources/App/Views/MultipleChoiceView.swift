import SwiftUI

/// Recognition stage (§4.2): four options on chunky world-tinted keys — one button
/// family per level, numbers dead-center. Feedback happens in place: the correct key
/// turns green and glows, others step back. Nothing on screen moves.
struct MultipleChoiceView: View {
    @Environment(\.worldTheme) private var theme
    /// iPhone landscape (compact vertical): prompt beside the option grid, shorter
    /// keys — the tall prompt-over-2×2 stack doesn't fit the short screen.
    @Environment(\.verticalSizeClass) private var vSize
    let question: PlannedQuestion
    let showFeedback: Bool
    let selected: Int?
    let onSelect: (Int) -> Void

    private var answer: Int { question.prompt.answer }
    private var compact: Bool { vSize == .compact }
    private let columns = [GridItem(.flexible(), spacing: 18), GridItem(.flexible(), spacing: 18)]

    var body: some View {
        Group {
            if compact {
                HStack(spacing: 28) { PromptText(question.displayText); grid }
            } else {
                VStack(spacing: 26) { PromptText(question.displayText); grid }
            }
        }
        .animation(Theme.Motion.snappy, value: showFeedback)
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: compact ? 12 : 18) {
            ForEach(question.options ?? [], id: \.self) { option in
                optionButton(option)
            }
        }
        .frame(maxWidth: compact ? 360 : 560)
    }

    private func optionButton(_ option: Int) -> some View {
        let isAnswer = option == answer
        let isPicked = option == selected
        let dimmed = showFeedback && !isAnswer
        return Button { if !showFeedback { onSelect(option) } } label: {
            Text("\(option)")
                .font(Theme.Font.number(compact ? 32 : 38))
                .frame(maxWidth: .infinity, minHeight: compact ? 66 : 92)
        }
        .buttonStyle(ChunkyKeyStyle(base: keyBase(isAnswer: isAnswer, isPicked: isPicked),
                                    deep: keyDeep(isAnswer: isAnswer),
                                    corner: 20))
        .disabled(showFeedback)
        .saturation(dimmed ? 0.45 : 1)
        .opacity(dimmed ? (isPicked ? 0.8 : 0.55) : 1)
        .scaleEffect(showFeedback && isAnswer ? 1.05 : 1)
        .shadow(color: showFeedback && isAnswer ? Theme.Color.correct.opacity(0.75) : .clear,
                radius: 14)
        .overlay {
            if showFeedback && isAnswer {
                ParticleBurst(kind: .stars, colors: [Theme.Color.accent, .white], count: 10)
                    .frame(width: 170, height: 170)
            }
        }
        .accessibilityLabel("\(option)")
    }

    private func keyBase(isAnswer: Bool, isPicked: Bool) -> Color {
        guard showFeedback else { return theme.primary }
        if isAnswer { return Theme.Color.correct }
        if isPicked { return Color(white: 0.45) }
        return theme.primary
    }

    private func keyDeep(isAnswer: Bool) -> Color {
        showFeedback && isAnswer ? Theme.Color.correct.shaded(by: -0.35) : theme.deep
    }
}

/// The hero numeral prompt on the world's ornate plaque (the button art, reborn) —
/// dark-glass fallback for any world without plaque art. Readability always wins:
/// a soft dark blob sits behind the numeral over the busy frame centers.
struct PromptText: View {
    @Environment(\.worldTheme) private var theme
    let text: String
    init(_ text: String) { self.text = text }

    private static let plaqueHeight: CGFloat = 150
    /// Clear space kept between the numeral and the frame's ornate ends.
    private static let sidePadding: CGFloat = 44
    /// Never narrower than this, so a short prompt still reads as a plaque
    /// rather than a token.
    private static let minPlaqueWidth: CGFloat = 300

    var body: some View {
        if let skin = Self.stretchableSkin(theme.buttonImage) {
            // The PLAQUE stretches to fit the question; the numeral never
            // shrinks. The frame is 9-sliced (resizable(capInsets:)) so its
            // ornate ends stay their true size while only the flat middle
            // widens — "4 + 2" and "24 − 12 = ?" both render at full 58pt.
            // (Before this, the text sat in a ZStack with no width to shrink
            // against, so a long prompt simply overflowed the frame.)
            numeral
                .padding(.horizontal, Self.sidePadding)
                .frame(minWidth: Self.minPlaqueWidth)
                .frame(height: Self.plaqueHeight)
                .background(skin)
                .fixedSize(horizontal: true, vertical: false)
                .shadow(color: .black.opacity(0.45), radius: 10, y: 5)
        } else {
            numeral
                .padding(.horizontal, 36).padding(.vertical, 12)
                .darkPlate()
        }
    }

    private var numeral: some View {
        Text(text)
            .font(Theme.Font.display(58))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.55), radius: 3, y: 2)
            // Safety net only: the plaque widens to fit, so this should never
            // engage in normal play.
            .minimumScaleFactor(0.5).lineLimit(1)
    }

    /// The world's frame as a 9-slice: corners and ornate ends held at their
    /// own size, flat middle free to stretch. Caps are fractions of the
    /// asset's POINT size — the plaque imagesets are declared @3x so their
    /// point size matches the size they render at, which is what keeps the
    /// caps from swamping the destination.
    static func stretchableSkin(_ name: String) -> Image? {
        #if canImport(UIKit)
        guard let ui = UIImage(named: name) else { return nil }
        let s = ui.size
        let capH = min(s.width * 0.30, (minPlaqueWidth - 20) / 2)
        let capV = min(s.height * 0.32, (plaqueHeight - 20) / 2)
        return Image(uiImage: ui)
            .resizable(capInsets: EdgeInsets(top: capV, leading: capH,
                                             bottom: capV, trailing: capH),
                       resizingMode: .stretch)
        #else
        return nil
        #endif
    }
}
