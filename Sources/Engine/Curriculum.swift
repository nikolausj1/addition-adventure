import Foundation

/// Curriculum and sequencing (§5). Addend "tables" are introduced in order of
/// cognitive ease rather than numeric order. A fact becomes available once *both*
/// of its addends' tables have been introduced — i.e. at the later of the two.
public enum Curriculum {

    /// Introduction order of the single-addend "tables", easiest first (§5):
    /// rules (+0/+1) → +2 → +10 → +5 → the small middles +3/+4 → the crossing-ten
    /// group +6/+7/+8/+9 (this app drills recall, so +9 is memorized like its
    /// neighbors, not made-ten easy), then the BIG NUMBERS +11/+12 as the finale.
    /// Covers 0…12; the hardest facts land in the later worlds. 11s/12s split across
    /// the last two worlds (never one 25-fact wall). Sim-tuned.
    public static let tableOrder: [Int] = [0, 1, 2, 10, 5, 3, 4, 6, 7, 8, 9, 11, 12]

    /// Rank of a factor in the introduction order (lower = introduced earlier).
    public static func introRank(ofFactor f: Int) -> Int {
        tableOrder.firstIndex(of: f) ?? Int.max
    }

    /// The curriculum slot at which a fact first becomes learnable: the later of
    /// its two factors' table introductions.
    public static func slot(of fact: FactID) -> Int {
        max(introRank(ofFactor: fact.a), introRank(ofFactor: fact.b))
    }

    /// All facts grouped by curriculum slot, in introduction order.
    public static func factsBySlot() -> [[FactID]] {
        var groups = Array(repeating: [FactID](), count: tableOrder.count)
        for fact in FactUniverse.allFacts {
            groups[slot(of: fact)].append(fact)
        }
        return groups
    }

    /// A human-readable label for the table introduced at a slot, e.g. "+7".
    public static func tableLabel(slot: Int) -> String {
        guard slot >= 0, slot < tableOrder.count else { return "" }
        let f = tableOrder[slot]
        return f == 0 || f == 1 ? "+0 and +1" : "+\(f)"
    }
}
