import Foundation

/// A world in the Addition Adventure map. Identity is data-driven so art and
/// names can change without touching logic. Art/names are reused from the
/// multiplication app; only the curriculum slots each world owns change.
public struct World: Sendable, Equatable {
    public let index: Int          // 0-based
    public let name: String
    public let bossName: String    // the world's guardian (boss challenge)
    public let assetKey: String    // e.g. "world1" → world1_bg / world1_node / world1_button
    public let slots: [Int]        // curriculum slot indices this world owns
    public let palette: WorldPalette

    public var number: Int { index + 1 }
}

/// Per-world colors (hex strings; converted to Color in the app's theme layer).
public struct WorldPalette: Sendable, Equatable {
    public let primary: String
    public let accent: String
    public let deep: String
    public init(_ primary: String, _ accent: String, _ deep: String) {
        self.primary = primary; self.accent = accent; self.deep = deep
    }
}

/// The 7-world journey. Worlds map onto contiguous curriculum slots (§5), front-loaded
/// easy, hard tables solo. New learning is scoped per world; review is cumulative.
public enum WorldCatalog {
    public static let worlds: [World] = [
        World(index: 0, name: "The Wandering Isles", bossName: "Old Mossback",
              assetKey: "world1", slots: [0, 1, 2, 3, 4],   // +0,+1,+2,+10,+5
              palette: WorldPalette("#EBB035", "#3FC9C0", "#2A6E68")),
        World(index: 1, name: "Giant's Grove",   bossName: "Timberjaw",
              assetKey: "world2", slots: [5, 6],            // +3,+4
              palette: WorldPalette("#3E7A34", "#E8C25A", "#1E3D18")),
        World(index: 2, name: "Firefly Bayou",   bossName: "Glowfang",
              assetKey: "world3", slots: [7, 8],            // +6,+7
              palette: WorldPalette("#2E8B7A", "#C6F26E", "#14323C")),
        World(index: 3, name: "The Sunken Reef", bossName: "Shellwreck the Hermit King",
              assetKey: "world4", slots: [9],               // +8
              palette: WorldPalette("#29A3C4", "#FF7E79", "#0E4A66")),
        World(index: 4, name: "Crystal Hollows", bossName: "Geode Golem",
              assetKey: "world5", slots: [10],              // +9
              palette: WorldPalette("#8E5BC0", "#D9A9FF", "#3A1F5E")),
        World(index: 5, name: "Thunderfall Canyon", bossName: "Cascade Colossus",
              assetKey: "world6", slots: [11],              // +11 (big-numbers finale)
              palette: WorldPalette("#5FA8D8", "#DFF3F8", "#23506B")),
        World(index: 6, name: "Aurora Summit",   bossName: "Frostcrown, the Aurora King",
              assetKey: "world7", slots: [12],              // +12 (summit: 12+12)
              palette: WorldPalette("#46C08A", "#B08CFF", "#141B3C")),
    ]

    public static var count: Int { worlds.count }

    /// Daily-quest stars that fill a world before its boss unlocks. Pure pacing:
    /// stars are session trophies, decoupled from fact mastery, so this only
    /// sets how many sessions land between boss fights. Set to 3 (2026-07-06) so
    /// a ~4-day/week player beats all 7 worlds before a Sept-8 school start with
    /// margin (28 sessions + 7 bosses ≈ 35, vs. ~36 available).
    public static let starsPerWorld = 3

    /// Which world introduces a given fact (the world owning the fact's curriculum slot).
    public static func worldIndex(ofFact fact: FactID) -> Int {
        let slot = Curriculum.slot(of: fact)
        return worlds.first(where: { $0.slots.contains(slot) })?.index ?? worlds.count - 1
    }

    public static func facts(inWorld index: Int) -> [FactID] {
        FactUniverse.allFacts.filter { worldIndex(ofFact: $0) == index }
    }

    /// The addend "table" numbers a world owns, in curriculum order — e.g. The
    /// Wandering Isles (slots 0-4) owns tables [0, 1, 2, 10, 5]. Golden
    /// Guardians (phase 3) labels each node with these once the map turns
    /// gold, and the retreat screen's "Train the +Ns" button reads them off
    /// here too.
    public static func tables(inWorld index: Int) -> [Int] {
        guard let w = worlds[safe: index] else { return [] }
        return w.slots.map { Curriculum.tableOrder[$0] }
    }

    /// The highest curriculum slot owned by a world (for gating new-fact introduction).
    public static func maxSlot(forWorld index: Int) -> Int {
        worlds[safe: index]?.slots.max() ?? Curriculum.tableOrder.count - 1
    }
}

extension Array {
    subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}
