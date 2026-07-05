import Foundation

/// Curriculum and sequencing (§5). Addend "tables" are introduced in order of
/// cognitive ease rather than numeric order. A fact becomes available once *both*
/// of its addends' tables have been introduced — i.e. at the later of the two.
public enum Curriculum {

    /// Introduction order of the single-addend "tables", easiest first (§5):
    /// rules (+0/+1) → +2 → +10, then +11/+12 (add-ten-plus, easy once +10 lands)
    /// → +5/+9 (fives, make-ten) → the middles → the hard +6/+7/+8. Covers 0…12,
    /// with 11s/12s woven in early rather than saved for a finale. Sim-tuned.
    public static let tableOrder: [Int] = [0, 1, 2, 10, 11, 12, 5, 9, 3, 4, 6, 7, 8]

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
