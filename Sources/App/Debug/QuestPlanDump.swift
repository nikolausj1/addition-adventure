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

        for session in 1...10 {
            // Boss-ready (5 sockets filled)? Fight it first, as the kid would.
            let worldIdx = service.currentWorldIdx()
            if service.starsInCurrentWorld() == 5,
               !service.activeProfile().clearedWorlds.contains(worldIdx) {
                let boss = SessionViewModel(service: service, boss: true, worldIndex: worldIdx)
                boss.now = { simDate }
                boss.clockRun()
                while boss.stage != .finished {
                    guard let q = boss.current else { break }
                    simDate += 3
                    boss.answer(q.expectedAnswer, simulatedRT: 1.8)
                    boss.pendingCelebration = nil
                    if boss.stage == .feedback { boss.next() }
                }
                let bossName = WorldCatalog.worlds[safe: worldIdx]?.bossName ?? "Boss"
                print("\n⚔️  BOSS FIGHT: \(bossName) — "
                      + (boss.bossPassed ? "DEFEATED, world \(worldIdx + 1) cleared!" : "held off"))
            }
            let vm = SessionViewModel(service: service)
            vm.now = { simDate }
            vm.clockRun()
            let world = WorldCatalog.worlds[safe: vm.worldStatBefore.index]?.name ?? "?"
            print("\n━━━ SESSION \(session) — \(world) ━━━")
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
                let base: Double = q.missingFactor ? 6.5
                    : trivial ? 1.6
                    : easy ? 2.4
                    : hard ? (seen < 2 ? 8.5 : seen < 5 ? 5.0 : seen < 8 ? 3.6 : 2.6)
                    : (seen < 2 ? 5.5 : seen < 4 ? 3.4 : 2.4)
                let rt = slow ? max(base, 4.5) : base
                let tag = q.format == .recognition ? "C " : (q.missingFactor ? "MF" : "K ")
                print(String(format: "%3d [%@] %@  bar %3.0f%%", n, tag, q.displayText,
                             vm.questMeter * 100))
                simDate += rt + 1.2   // answer + feedback beat
                vm.answer(q.expectedAnswer, simulatedRT: rt)
                vm.pendingCelebration = nil
                if vm.stage == .feedback { vm.next() }
                if vm.pendingStarEarned != nil { vm.starEarnedDismissed() }
            }
            print("→ \(vm.totalAnswered) answers, ~\(Int((vm.elapsed / 60).rounded())) min, "
                  + "star \(vm.starEarnedThisSession ? "EARNED" : "not earned"), "
                  + "world \(service.currentWorldIdx() + 1) stars \(service.starsInCurrentWorld())/5")
            fflush(stdout)
            simDate += 86_400   // next day
        }
        exit(0)
    }
}
