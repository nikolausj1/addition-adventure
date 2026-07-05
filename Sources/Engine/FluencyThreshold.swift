import Foundation

/// The fluency time threshold (§4.3): starts forgiving (~4s, this learner is
/// younger) and tightens toward ~2.5s as his baseline speed improves. Floor 2.0s
/// keeps the bar age-appropriate — we don't demand sub-2s single-digit sums.
/// Computed globally from his recent fluency-stage response times.
public enum FluencyThreshold {
    public static let initial: Double = 4.0
    public static let floor: Double = 2.0
    public static let ceiling: Double = 4.0

    /// Given the child's recent fluency-stage correct response times, return the
    /// current threshold. We track a robust centre (median) and set the bar a touch
    /// above it, clamped to [floor, ceiling], so the bar follows his improving speed.
    public static func current(recentFluencyTimes: [Double]) -> Double {
        guard recentFluencyTimes.count >= 5 else { return initial }
        let sorted = recentFluencyTimes.sorted()
        let median = sorted[sorted.count / 2]
        // Aim the bar slightly above his median so ~half of well-known facts clear it,
        // and it ratchets down as the median falls.
        let target = median * 1.1
        return min(ceiling, max(floor, target))
    }

    public static func isFast(_ time: Double, threshold: Double) -> Bool {
        time <= threshold
    }
}
