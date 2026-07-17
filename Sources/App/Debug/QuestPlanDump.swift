import Foundation
import SwiftData

/// Debug (-dumpQuestPlan): simulates 10 quest sessions against the REAL engine
/// with a synthetic learner — instant on +0/+1 rules and small/known sums,
/// slow on first meetings with crossing-ten facts — and prints every question
/// to stdout, one session per "day". Uses an in-memory store; real data untouched.
@MainActor
enum QuestPlanDump {
    static func runIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-dumpQuestPlan") else { return }
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        guard let container = try? ModelContainer(
            for: Fact.self, Profile.self, SessionRecord.self, MilestoneRecord.self,
            configurations: config) else { print("DUMP: container failed"); exit(1) }
        let service = LearningService(context: container.mainContext)
        service.bootstrap()

        var simDate = Date.now
        var exposures: [FactID: Int] = [:]   // carried across days (memory of meetings)
        // -dumpSlow: a correct-but-DELIBERATE kid — right answers, but nothing
        // under 4.5s (above the 4.0s fluency ceiling), so no speed-based test-outs
        // ever fire. This is the case the fast-learner model masks (the W1 grind).
        let slow = ProcessInfo.processInfo.arguments.contains("-dumpSlow")
        // -dumpDays N: how many sessions to simulate (default 10). -dumpQuiet:
        // suppress the per-question lines (for long full-journey runs).
        let args = ProcessInfo.processInfo.arguments
        let cap: Int = args.firstIndex(of: "-dumpDays").flatMap { i in
            i + 1 < args.count ? Int(args[i + 1]) : nil } ?? 10
        let quiet = args.contains("-dumpQuiet")
        // Full-journey stats.
        var subQuestions = 0            // subtraction-inverse (missingFactor) served
        var subMinuends: Set<Int> = []  // distinct minuends seen in subtraction
        var bosses: [(String, Bool)] = []
        func stageCounts() -> (fluentPlus: Int, mastered: Int) {
            let all = (try? container.mainContext.fetch(FetchDescriptor<Fact>())) ?? []
            let snaps = all.map(\.snapshot)
            return (snaps.filter { $0.stage >= .fluency }.count,
                    snaps.filter { $0.stage == .mastered }.count)
        }

        for session in 1...cap {
            // Boss-ready (5 sockets filled)? Fight it first, as the kid would.
            let worldIdx = service.currentWorldIdx()
            if service.starsInCurrentWorld() == service.starsPerWorldGoal(),
               !service.activeProfile().clearedWorlds.contains(worldIdx) {
                let boss = SessionViewModel(service: service, boss: true, worldIndex: worldIdx)
                boss.now = { simDate }
                while boss.stage != .finished {
                    guard let q = boss.current else { break }
                    simDate += 3
                    boss.answer(q.expectedAnswer, simulatedRT: 1.8)
                    boss.pendingCelebration = nil
                    if boss.stage == .feedback { boss.next() }
                }
                let bossName = WorldCatalog.worlds[safe: worldIdx]?.bossName ?? "Boss"
                bosses.append((bossName, boss.bossPassed))
                print("\n⚔️  BOSS FIGHT: \(bossName) — "
                      + (boss.bossPassed ? "DEFEATED, world \(worldIdx + 1) cleared!" : "held off"))
            }
            let vm = SessionViewModel(service: service)
            vm.now = { simDate }
            let world = WorldCatalog.worlds[safe: vm.worldStatBefore.index]?.name ?? "?"
            if !quiet { print("\n━━━ SESSION \(session) — \(world) ━━━") }
            var n = 0
            while vm.stage != .finished, n < 400 {
                // Completion can land with the queue already exhausted — resolve
                // the pending slam/finish before checking for a next question.
                if vm.pendingStarEarned != nil { vm.starEarnedDismissed(); continue }
                guard let q = vm.current else {
                    if vm.stage == .feedback { vm.next(); continue }
                    break
                }
                n += 1
                // Learner model tuned to the target kid: +0/+1 rules instant,
                // small sums / doubles / +2 / +10 known; middles warm up quickly;
                // crossing-ten facts (7+8, 6+9…) stay slow for many exposures.
                // Subtraction inverses (missingFactor) are the slowest — new skill.
                let trivial = min(q.fact.a, q.fact.b) <= 1
                let easy = q.fact.a == q.fact.b || q.fact.a == 2 || q.fact.b == 2
                    || q.fact.b == 10 || q.fact.sum <= 6
                let hard = q.fact.sum > 10 && min(q.fact.a, q.fact.b) > 2
                let seen = exposures[q.fact, default: 0]
                exposures[q.fact] = seen + 1
                // Well-practiced facts eventually reach fluent speed (~2.1s) so the
                // journey can complete; new/hard facts stay slow for many exposures.
                let base: Double = q.missingFactor ? (seen < 3 ? 6.5 : seen < 8 ? 3.5 : 2.2)
                    : trivial ? 1.5
                    : easy ? 1.8
                    : hard ? (seen < 2 ? 8.5 : seen < 5 ? 5.0 : seen < 8 ? 3.4 : 1.7)
                    : (seen < 2 ? 5.5 : seen < 4 ? 3.2 : 1.6)
                let rt = slow ? max(base, 4.5) : base
                if q.missingFactor { subQuestions += 1; subMinuends.insert(q.prompt.answer) }
                let tag = q.format == .recognition ? "C " : (q.missingFactor ? "MF" : "K ")
<<<<<<< HEAD
                if !quiet {
                    print(String(format: "%3d [%@] %@  bar %3.0f%%", n, tag, q.displayText,
                                 vm.questMeter * 100))
                }
=======
                let mv = q.movement == .core ? "core" : (q.movement == .review ? "rev " : "warm")
                print(String(format: "%3d [%@ %@ lp%.1f] %@  bar %5.1f%%", n, tag, mv,
                             service.ladderProgress(q.fact), q.displayText,
                             vm.questMeter * 100))
>>>>>>> 27de971 (Kid-linear Quest Meter (answer-count floor) + real keypad fix (overlay))
                simDate += rt + 1.2   // answer + feedback beat
                vm.answer(q.expectedAnswer, simulatedRT: rt)
                vm.pendingCelebration = nil
                if vm.stage == .feedback { vm.next() }
                if vm.pendingStarEarned != nil { vm.starEarnedDismissed() }
            }
<<<<<<< HEAD
            let (fluent, mastered) = stageCounts()
            let clearedNow = service.activeProfile().clearedWorlds.count
            print("Day \(session): \(vm.totalAnswered) answers, "
                  + "~\(Int((vm.elapsed / 60).rounded())) min, "
                  + "world \(service.currentWorldIdx() + 1) ★\(service.starsInCurrentWorld())/\(service.starsPerWorldGoal()), "
                  + "cleared \(clearedNow)/7, fluent \(fluent)/\(FactUniverse.count), "
                  + "mastered \(mastered)")
=======
            print("→ \(vm.totalAnswered) answers, "
                  + "star \(vm.starEarnedThisSession ? "EARNED" : "not earned"), "
                  + "world \(service.currentWorldIdx() + 1) stars \(service.starsInCurrentWorld())/\(service.starsPerWorldGoal())")
>>>>>>> 27de971 (Kid-linear Quest Meter (answer-count floor) + real keypad fix (overlay))
            fflush(stdout)
            simDate += 86_400   // next day
            if clearedNow >= WorldCatalog.count {
                print("\n🏆 ADVENTURE COMPLETE — all 7 worlds cleared on day \(session) "
                      + "(fluent \(fluent)/\(FactUniverse.count), mastered \(mastered))")
                break
            }
        }

        // End-of-run summary.
        let (fluent, mastered) = stageCounts()
        let cleared = service.activeProfile().clearedWorlds.count
        print("\n══════ FULL-JOURNEY SUMMARY ══════")
        print("Facts fluent+: \(fluent)/\(FactUniverse.count)")
        print("Facts mastered: \(mastered)/\(FactUniverse.count)")
        print("Worlds cleared: \(cleared)/\(WorldCatalog.count)")
        print("Bosses fought: " + (bosses.isEmpty ? "none"
              : bosses.map { "\($0.0)\($0.1 ? "✓" : "✗")" }.joined(separator: ", ")))
        print("Subtraction (inverse) questions served: \(subQuestions)")
        if !subMinuends.isEmpty {
            print("  subtraction minuends seen: \(subMinuends.min()!)…\(subMinuends.max()!) "
                  + "(\(subMinuends.count) distinct)")
        }
        fflush(stdout)
        exit(0)
    }
}
