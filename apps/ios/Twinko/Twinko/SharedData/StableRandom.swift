import Foundation

/// SplitMix64 — a tiny deterministic generator for features that need
/// stable, repeatable variation (e.g. Astrology's daily content).
/// Tarot draws never use this in production paths.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

/// Stable across launches (unlike `hashValue`, which is seeded per
/// process).
func stableHash(_ text: String) -> UInt64 {
    var hash: UInt64 = 5381
    for byte in text.utf8 {
        hash = (hash &* 33) ^ UInt64(byte)
    }
    return hash
}
