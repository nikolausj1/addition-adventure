import SwiftUI
import SwiftData

/// Session wrap (§6, movement 4): a clear, encouraging summary on a scrim panel over
/// the world backdrop. He always leaves knowing he made progress.
struct WrapView: View {
    @Environment(\.worldTheme) private var theme
    @Environment(\.verticalSizeClass) private var vSize   // compact = iPhone landscape
    @Query(filter: #Predicate<Profile> { $0.isActive }) private var activeProfiles: [Profile]
    let vm: SessionViewModel
    /// "Train the +Ns" tapped on a lost golden fight — the world index to
    /// train. Default no-op so call sites that never offer training (dev/test
    /// runs) don't need to pass anything.
    var onTrain: (Int) -> Void = { _ in }
    let onDone: () -> Void
    private var compact: Bool { vSize == .compact }

    private var snapshots: [FactSnapshot] { (activeProfiles.first?.facts ?? []).map(\.snapshot) }

    /// Boss victory this session (worlds clear only by beating their boss).
    /// Golden fights also set `bossWorldIndex`, so these are explicitly
    /// gated to regular boss fights — the golden result gets its own
    /// presentation below, never this one.
    private var clearedThisSession: Bool {
        vm.bossWorldIndex != nil && !vm.golden && !vm.exhibition && vm.bossPassed
    }
    private var bossFailed: Bool {
        vm.bossWorldIndex != nil && !vm.golden && !vm.exhibition && !vm.bossPassed
    }
    private var goldenWon: Bool { vm.golden && vm.bossPassed }
    private var goldenEscaped: Bool { vm.golden && !vm.bossPassed }
    /// Exhibition replay verdicts (FeatureFlag.bossReplays): local to the
    /// fight — the world stays cleared either way, and a loss is the golden
    /// soft-fail (the guardian escapes; zero failure framing, no numbers).
    private var exhibitionWon: Bool { vm.exhibition && vm.bossPassed }
    private var exhibitionEscaped: Bool { vm.exhibition && !vm.bossPassed }

    private var clearedName: String {
        WorldCatalog.worlds[safe: vm.bossWorldIndex ?? vm.worldStatBefore.index]?.name ?? "World"
    }
    private var guardianName: String {
        WorldCatalog.worlds[safe: vm.bossWorldIndex ?? vm.worldStatBefore.index]?.bossName ?? "Guardian"
    }

    private var headline: String {
        if exhibitionWon { return "\(guardianName) defeated — again!" }
        if exhibitionEscaped { return "The \(guardianName) escaped!" }
        if goldenWon { return "\(clearedName) shines GOLD!" }
        if goldenEscaped { return "The \(guardianName) escaped!" }
        if clearedThisSession { return "\(clearedName) cleared!" }
        if bossFailed { return "So close!" }
        if vm.isQuest && vm.starEarnedThisSession { return "Quest complete!" }
        return "Great work!"
    }

    /// "TRAIN THE +8s" / "TRAIN THE +3s & +4s" — the addend tables a lost
    /// golden fight's world owns, read off the catalog so it never drifts
    /// from the actual fact set.
    private func trainLabel(_ worldIndex: Int) -> String {
        let tables = WorldCatalog.tables(inWorld: worldIndex)
        switch tables.count {
        case 0: return ""
        case 1: return "+\(tables[0])s"
        case 2: return "+\(tables[0])s & +\(tables[1])s"
        default:
            let allButLast = tables.dropLast().map { "+\($0)s" }.joined(separator: ", ")
            return "\(allButLast) & +\(tables.last!)s"
        }
    }

    var body: some View {
        // WrapView sits directly in SessionView's ZStack (an in-hierarchy overlay,
        // not a sheet/cover), which imposes no explicit height on its children —
        // so a plain ScrollView here never actually gets bounded and just renders
        // at its full unclipped content height, silently running off the bottom
        // of the physical screen instead of scrolling. GeometryReader gives the
        // real available height so the ScrollView can be explicitly capped to it
        // and genuinely scroll, guaranteeing "Back to Map" is always reachable.
        GeometryReader { geo in
            Group {
                if compact {
                    ScrollView(showsIndicators: false) { content }
                        .frame(maxHeight: geo.size.height)
                } else {
                    content
                }
            }
            .frame(maxWidth: 500)
            .darkPlate()
            .padding(compact ? 10 : Theme.Metric.pad)
            .background {
                if clearedThisSession || goldenWon || exhibitionWon {
                    ParticleBurst(kind: .confetti,
                                  colors: [Theme.Color.accent, Theme.Color.correct,
                                           theme.primary, .white, theme.accent],
                                  origin: UnitPoint(x: 0.5, y: 0.3), count: 120)
                        .frame(width: 900, height: 800)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var headlineIcon: String {
        if exhibitionWon { return "trophy.fill" }
        if exhibitionEscaped { return "flag.checkered" }
        if goldenWon { return "star.circle.fill" }
        if goldenEscaped { return "flag.checkered" }
        if clearedThisSession { return "trophy.fill" }
        if bossFailed { return "flag.checkered" }
        return "checkmark.seal.fill"
    }
    private var headlineTint: Color {
        if exhibitionWon { return Theme.Color.accent }
        if exhibitionEscaped { return .white }
        if goldenWon { return Theme.Color.accent }
        if goldenEscaped { return .white }
        if clearedThisSession { return Theme.Color.accent }
        if bossFailed { return .white }
        return Theme.Color.correct
    }

    private var content: some View {
        VStack(spacing: compact ? 10 : 22) {
            Image(systemName: headlineIcon)
                .font(.system(size: compact ? 40 : 72))
                .foregroundStyle(headlineTint)
                .symbolRenderingMode(.hierarchical)
                .background {
                    if !bossFailed, !goldenEscaped, !exhibitionEscaped {
                        ParticleBurst(kind: .stars, colors: [Theme.Color.accent, .white], count: 14)
                            .frame(width: compact ? 150 : 260, height: compact ? 150 : 260)
                    }
                }
            Text(headline)
                .font(Theme.Font.display(compact ? 22 : 34)).foregroundStyle(.white)
                .multilineTextAlignment(.center)

            // Golden Guardians acceptance criterion: no fraction, percentage,
            // or fact count is ever shown on a golden result screen. An
            // exhibition replay is the same: no XP totals, no fact counts —
            // nothing was recorded, so there is nothing honest to show.
            if !vm.golden && !vm.exhibition {
                HStack(spacing: compact ? 18 : 28) {
                    stat("\(vm.totalAnswered)", "questions")
                    stat("\(Int(vm.accuracy * 100))%", "accuracy")
                    stat("+\(vm.xpEarned)", "XP", tint: Theme.Color.accent)
                }
            }

            worldProgressCard

            if vm.bossWorldIndex == nil, let c = vm.endCelebration, c.tier >= .t1 {
                Label(c.headline, systemImage: "flame.fill")
                    .font(Theme.Font.label(compact ? 14 : 17)).foregroundStyle(Theme.Color.accent)
            }
            Text(encouragement).font(Theme.Font.body(compact ? 14 : 18)).foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Button(action: onDone) {
                Text("Back to Map").font(Theme.Font.display(compact ? 16 : 20))
                    .frame(maxWidth: .infinity).padding(.vertical, compact ? 10 : 15)
            }
            .buttonStyle(ChunkyKeyStyle(base: theme.primary, deep: theme.deep,
                                        corner: Theme.Metric.corner))
        }
        .padding(compact ? 14 : Theme.Metric.pad + 8)
    }

    private func stat(_ value: String, _ label: String, tint: Color = .white) -> some View {
        VStack(spacing: 4) {
            Text(value).font(Theme.Font.number(compact ? 22 : 30)).foregroundStyle(tint)
            Text(label).font(Theme.Font.label(compact ? 11 : 13)).foregroundStyle(.white.opacity(0.65))
        }
    }

    /// The "what did today count for" answer: the world's star sockets, today's
    /// real gains, and one line that explains the loop (star per quest, 5 → boss).
    @ViewBuilder
    private var worldProgressCard: some View {
        let profile = activeProfiles.first
        let cleared = profile?.clearedWorlds ?? []
        let idx = profile?.currentWorldIndex ?? 0
        let stars = profile?.starsInCurrentWorld ?? 0
        let goal = profile?.starsPerWorldGoal ?? WorldCatalog.starsPerWorld
        let name = WorldCatalog.worlds[safe: idx]?.name ?? "this world"
        let fluentNow = snapshots.filter { $0.stage >= .fluency }.count
        let gained = max(0, fluentNow - vm.worldStatBefore.fluent)
        let allCleared = cleared.count == WorldCatalog.count

        VStack(spacing: compact ? 6 : 8) {
            if vm.exhibition, let bossWorld = vm.bossWorldIndex {
                // Exhibition replay result: no star flow, no numbers — the
                // world stays cleared either way. A loss borrows the golden
                // soft-fail language (the guardian escapes; zero failure
                // framing), and BOTH outcomes offer world-scoped untimed
                // training via the same onTrain plumbing the golden wrap's
                // "TRAIN THE +Ns" button uses.
                let boss = WorldCatalog.worlds[safe: bossWorld]?.bossName ?? "Guardian"
                let worldName = WorldCatalog.worlds[safe: bossWorld]?.name ?? "This world"
                VStack(spacing: 12) {
                    Text(vm.bossPassed
                         ? "The \(boss) bows once more — \(worldName) remembers its champion!"
                         : "The \(boss) slipped away — but \(worldName) is still yours. Train up and try again!")
                        .font(Theme.Font.body(compact ? 14 : 18)).foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        // Wrap, never truncate: sibling ChunkyKey buttons bid
                        // for the VStack's height, and the Text loses that
                        // negotiation (an ellipsis mid-flavor-line looks
                        // broken). Reserve its full wrapped height.
                        .fixedSize(horizontal: false, vertical: true)
                    Button { onTrain(bossWorld) } label: {
                        Text("REPLAY THIS WORLD")
                            .font(Theme.Font.display(16))
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                    }
                    .buttonStyle(ChunkyKeyStyle(base: theme.primary, deep: theme.deep,
                                                corner: Theme.Metric.corner))
                }
            } else if let bossWorld = vm.bossWorldIndex, vm.golden {
                // Golden Guardian result: no fractions, no percentages, no
                // failure framing on a loss — the guardian escaped, that's all.
                let boss = WorldCatalog.worlds[safe: bossWorld]?.bossName ?? "Guardian"
                let worldName = WorldCatalog.worlds[safe: bossWorld]?.name ?? "This world"
                if vm.bossPassed {
                    Text("The \(boss) bows before you — \(worldName) shines gold forever!")
                        .font(Theme.Font.body(compact ? 14 : 18)).foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                } else {
                    VStack(spacing: 12) {
                        Text("The \(boss) slipped away — but it'll be back. Train up and try again!")
                            .font(Theme.Font.body(compact ? 14 : 18)).foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Button { onTrain(bossWorld) } label: {
                            Text("TRAIN THE \(trainLabel(bossWorld))")
                                .font(Theme.Font.display(16))
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                        }
                        .buttonStyle(ChunkyKeyStyle(base: theme.primary, deep: theme.deep,
                                                    corner: Theme.Metric.corner))
                    }
                }
            } else if vm.training {
                // Training wrap: the plainest presentation — no star sockets,
                // no world-progress card, just a normal-finish acknowledgment.
                Text("Nice training round! Ready to challenge the guardian again?")
                    .font(Theme.Font.body(compact ? 14 : 18)).foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            } else if let bossWorld = vm.bossWorldIndex {
                let boss = WorldCatalog.worlds[safe: bossWorld]?.bossName ?? "Guardian"
                if vm.bossPassed {
                    Text("You defeated the \(boss) — the next world is revealed on the map!")
                        .font(Theme.Font.body(compact ? 14 : 18)).foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                } else {
                    Text("The \(boss) held you off — \(vm.correctCount) of \(vm.totalAnswered), and you need \(Int(LearningService.bossPassAccuracy * 100))%. Train up and challenge it again — retries are free!")
                        .font(Theme.Font.body(compact ? 14 : 18)).foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            } else if allCleared {
                // Golden Guardians WP5: the map is beaten, so this branch is
                // always in the golden era now (the certificate is already
                // awarded at map completion). No fact counts, fractions, or
                // percentages here (spec acceptance 5) — the guardians'
                // gilded state is the only signal, read off the profile
                // query this view already holds.
                let allGilded = (profile?.gildedWorlds.count ?? 0) == WorldCatalog.count
                if allGilded {
                    Text("Seven Worlds conquered — the adventure is complete!")
                        .font(Theme.Font.body(compact ? 14 : 18)).foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                } else {
                    Text("The Golden Guardians await on the map!")
                        .font(Theme.Font.body(compact ? 14 : 18)).foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            } else {
                HStack {
                    Text(name).font(Theme.Font.label(compact ? 13 : 15)).foregroundStyle(.white)
                    Spacer()
                    Text("\(fluentNow)/\(FactUniverse.count) facts fluent")
                        .font(Theme.Font.label(compact ? 12 : 14)).foregroundStyle(.white.opacity(0.8))
                }
                WorldStars(filled: stars, total: goal, size: compact ? 20 : 26, spacing: compact ? 6 : 8)
                    .padding(.vertical, 2)
                if vm.isQuest, vm.starEarnedThisSession {
                    Label("Quest complete — star earned!", systemImage: "flame.fill")
                        .font(Theme.Font.label(compact ? 13 : 15)).foregroundStyle(Theme.Color.accent)
                }
                if gained > 0 {
                    Text("+\(gained) new fluent fact\(gained == 1 ? "" : "s") today!")
                        .font(Theme.Font.label(compact ? 12 : 14)).foregroundStyle(Theme.Color.correct)
                }
                Text(stars == goal
                     ? "All \(goal) stars — the BOSS CHALLENGE is waiting on the map. Beat it to open the next world!"
                     : "Every quest earns a star. Fill all \(goal) to summon the \(name) boss.")
                    .font(Theme.Font.label(compact ? 11 : 13)).foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(compact ? 10 : 14)
        .background(Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var encouragement: String {
        if vm.accuracy >= 0.9 { return "You're getting faster every day. 🚀" }
        if vm.totalAnswered >= 15 { return "Showing up is what makes it stick. See you tomorrow!" }
        return "Every bit of practice counts. Nice job today!"
    }
}
