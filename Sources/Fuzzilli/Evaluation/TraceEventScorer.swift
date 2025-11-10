import Foundation

/// Scores an execution based on V8 trace output to prioritize corpus entries.
enum TraceEventScorer {
    private enum TraceEvent: CaseIterable, Hashable {
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

        var patterns: [String] {
            switch self {
            case .elementsTransition:
                return ["elements transition"]
            case .icTransition:
                return ["ic transition"]
            case .normalization:
                return ["object properties have been normalized", "object elements have been normalized"]
            case .garbageCollection:
                return ["(average mu"]
            case .deoptimization:
                return ["deoptimization", "deoptimize"]
            case .generalization:
                return ["[generalizing]"]
            case .migration:
                return ["[migrating"]
            }
        }

    }

    /// Returns the combined trace weight for the provided execution.
    static func score(for execution: Execution) -> Int {
        return score(stdout: execution.stdout, stderr: execution.stderr)
    }

    /// Returns the combined trace weight based on the provided stdout and stderr output.
    static func score(stdout: String, stderr: String) -> Int {
        if stdout.isEmpty && stderr.isEmpty {
            return 0
        }
        let combinedLog = (stdout + "\n" + stderr).lowercased()
        var encountered = Set<TraceEvent>()
        for event in TraceEvent.allCases {
            if event.patterns.contains(where: { combinedLog.contains($0) }) {
                encountered.insert(event)
            }
        }
        return encountered.reduce(0) { $0 + $1.weight }
    }
}
