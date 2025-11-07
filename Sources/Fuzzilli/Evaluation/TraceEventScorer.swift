import Foundation

/// Known engine trace events we track during fuzzing.
public enum TraceEventType: CaseIterable, Hashable {
    case elementsTransition
    case icTransition
    case normalization
    case garbageCollection
    case deoptimization
    case generalization
    case migration

    var weight: Int {
        switch self {
        case .elementsTransition:
            return 2
        case .icTransition:
            return 1
        case .normalization:
            return 4
        case .garbageCollection:
            return 4
        case .deoptimization:
            return 12
        case .generalization:
            return 13
        case .migration:
            return 14
        }
    }

    fileprivate var patterns: [String] {
        switch self {
        case .elementsTransition:
            return ["elements transition"]
        case .icTransition:
            return ["ic transition"]
        case .normalization:
            return ["object properties have been normalized", "object elements have been normalized"]
        case .garbageCollection:
            return ["scavenger", "mark-sweep-compact", "minor mark-sweep"]
        case .deoptimization:
            return ["deoptimization", "deoptimize"]
        case .generalization:
            return ["[generalizing]"]
        case .migration:
            return ["[migrating"]
        }
    }

    public var cliLabel: String {
        switch self {
        case .elementsTransition: return "Elements Transition"
        case .icTransition: return "IC Transition"
        case .normalization: return "Normalization"
        case .garbageCollection: return "GC"
        case .deoptimization: return "Deopt"
        case .generalization: return "Generalization"
        case .migration: return "Migrate"
        }
    }
}

/// Scores an execution based on V8 trace output to prioritize corpus entries.
enum TraceEventScorer {
    /// Returns the combined trace weight for the provided execution.
    static func score(for execution: Execution) -> Int {
        return score(stdout: execution.stdout, stderr: execution.stderr)
    }

    /// Returns the combined trace weight based on the provided stdout and stderr output.
    static func score(stdout: String, stderr: String) -> Int {
        let counts = eventCounts(stdout: stdout, stderr: stderr)
        return counts.reduce(0) { partial, entry in
            partial + (entry.value > 0 ? entry.key.weight : 0)
        }
    }

    /// Returns the number of matches per trace event for the provided streams.
    static func eventCounts(stdout: String, stderr: String) -> [TraceEventType: Int] {
        let combined = (stdout + "\n" + stderr).lowercased()
        guard !combined.isEmpty else { return [:] }

        var result = [TraceEventType: Int]()
        for event in TraceEventType.allCases {
            var eventCount = 0
            for pattern in event.patterns {
                eventCount += countOccurrences(of: pattern, in: combined)
            }
            if eventCount > 0 {
                result[event] = eventCount
            }
        }
        return result
    }

    private static func countOccurrences(of pattern: String, in text: String) -> Int {
        guard !pattern.isEmpty else { return 0 }
        var count = 0
        var searchRange = text.startIndex..<text.endIndex

        while let range = text.range(of: pattern, options: [], range: searchRange) {
            count += 1
            searchRange = range.upperBound..<text.endIndex
        }
        return count
    }
}
