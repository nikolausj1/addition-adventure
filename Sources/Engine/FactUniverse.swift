import Foundation

/// The fact universe (§4.1): the unique addend pairs from 0+0 through 12+12,
/// first addend ≤ second (commutatively normalized). 91 facts. Their subtraction
/// inverses (sum − addend, minuends up to 24) are display forms of these same
/// facts, so no separate subtraction universe is tracked.
public enum FactUniverse {
    public static let minFactor = 0
    public static let maxFactor = 12

    /// All 91 canonical facts, in a stable order (sorted by the larger addend then smaller).
    public static let allFacts: [FactID] = {
        var facts: [FactID] = []
        for b in minFactor...maxFactor {
            for a in minFactor...b {
                facts.append(FactID(a, b))
            }
        }
        return facts.sorted()
    }()

    public static var count: Int { allFacts.count }   // 91
}
