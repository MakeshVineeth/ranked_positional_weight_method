# 4. RPW Domain Logic Bug Fixes and Input Validation

Date: 2026-11-22

## Status

Accepted

## Context

An audit of the legacy RPW calculation in `Home.dart` uncovered five correctness and availability issues:

1. `rangeOut.contains(nodeId)` compared integer IDs against `List` rows (always `false`) while shadowing loop index `i`, causing an infinite freeze whenever a downstream node depended on an oversized task (`Tek > cycleTime`) or when graphs contained cycles.
2. `getArrowChain` exited early on hitting `finalNodeId`, skipping subsequent outgoing branches from the same source node.
3. RPW values were matched to sorted node rows by list position instead of node ID, scrambling results whenever `finalNodeId` was not numerically largest.
4. `maxRPW` ignored `rangeOut` stations, allowing division by zero or negative balance delay; Production Rate was also printed to console instead of shown in the UI.
5. `clearAll()` omitted several internal lists and fields, leaking stale edges into subsequent runs.

## Decision

Keep the Helgeson and Birnie RPW workflow and output steps intact while fixing all five defects inside `HelgesonBirnieRpwSolver`, `RpwInputValidator`, and `CalculatorViewModel`:

- Validate inputs against OWASP allowlists and safe size caps (`maxEdges = 500`, `maxUniqueNodes = 200`), rejecting self-loops, duplicates, conflicting `Tek` values, cycles, and disconnected graphs before solving.
- Traverse forward arrow chains using a visited set without premature `break` statements.
- Store `tekByNode` and `rpwByNode` keyed strictly by integer node ID.
- Track `rangeOutIds` and `dependsOnBigIds` explicitly with a forward-progress guard so workstation packing always terminates.
- Compute `maxStationLoad` across all workstations, guard zero denominators, and display Production Rate in the UI alongside Balance Delay and Line Efficiency.

## Consequences

- Every valid and invalid input terminates deterministically in bounded time and memory.
- Users receive clear validation errors rather than silent miscalculations or app freezes.
- Regression tests in `test/domain/services/rpw_solver_test.dart` lock in each fix.
