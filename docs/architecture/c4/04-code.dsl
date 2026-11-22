workspace "Calculate RPW - Code Structure" "Level 4 C4 Code View detailing pure Dart domain patterns and models." {
    model {
        rpwSystem = softwareSystem "Calculate RPW" "Offline RPW line balancing application." {
            clientApp = container "Flutter Client Application" "Dart 3.15" "Platform-agnostic application." {
                solverInterface = component "RpwSolver" "Abstract Interface (Strategy)" "Defines SolveOutcome<RpwResult> solve(RpwInput)."
                hbSolver = component "HelgesonBirnieRpwSolver" "Concrete Strategy" "Iterative cycle check, reverse reachability, forward chains, station packing."
                rpwInput = component "RpwInput and NodeEdge" "Immutable Models" "Represent directed edges, final node, final Tek, and cycle time."
                rpwResult = component "RpwResult, NodeRpwEntry, Workstation" "Immutable Models" "Hold ranked weights, balanced stations, balance delay, and production rate."
                solveOutcome = component "SolveOutcome and RpwFailure" "Sealed Algebraic Types" "Exhaustive SolveSuccess / SolveError and typed failure cases."
                resultNode = component "ResultNode, ResultGroup, ResultItem" "Sealed Composite Pattern" "Hierarchical UI and text export model."
                outputComposer = component "RpwOutputComposer" "Domain Service" "Transforms RpwResult into ResultGroup trees and plain text."
                sampleFactory = component "SampleProblemFactory" "Factory Pattern" "Produces classic 6-node, parallel 8-node, and oversized presets."
            }
        }

        hbSolver -> solverInterface "Implements"
        hbSolver -> rpwInput "Reads"
        hbSolver -> solveOutcome "Returns"
        solveOutcome -> rpwResult "Wraps on success"
        outputComposer -> rpwResult "Reads"
        outputComposer -> resultNode "Builds tree of"
        sampleFactory -> rpwInput "Instantiates"
    }

    views {
        component clientApp "CodeArchitecture" "Code-level domain classes and patterns for Calculate RPW." {
            include *
            autoLayout tb
        }
        styles {
            element "Component" {
                background #85BBF0
                color #000000
            }
        }
    }
}
