# User Guide

Calculate RPW helps industrial engineers, operations students, and manufacturing teams balance assembly lines by grouping tasks into workstations without exceeding a target cycle time.

## Key Terms

- **Node**: A numbered work element in your assembly sequence (1, 2, 3, and so on).
- **Tek**: Time required to finish a single work element (zero or positive).
- **Precedence Edge (`From -> To`)**: Dependency showing that the `From` task must finish before the `To` task starts.
- **Final Node**: Terminal task where all precedence paths converge.
- **Cycle Time**: Maximum allowed workload per workstation.
- **RPW (Ranked Positional Weight)**: Sum of a task's own `Tek` plus the `Tek` of every downstream task reachable from it.
- **Balance Delay**: Idle fraction across all stations relative to total station capacity.
- **Production Rate**: Output rate given by `1 / maxStationLoad` units per minute.

## Guided Form Mode

1. Select **Guided Form** at the top of the calculator (or choose a preset from **Quick Examples**).
2. Enter **From**, **To**, and the From node's **Tek**, then select **Add**.
3. Enter the **Final Node**, **Final Tek**, and target **Cycle Time**.
4. Select **Calculate** to generate workstation assignments, RPW rankings, arrow chains, and efficiency metrics.
5. Tap any result card to copy that entry, or select **Copy Report** to copy the full summary.

## Quick Text Mode

Switch to **Quick Text** for keyboard-driven entry with spaces:

1. Enter total number of connections (for example `6`).
2. Enter each connection as `From To Tek` (for example `1 2 0.4`).
3. Enter `FinalNode Tek` (for example `6 0.4`).
4. Enter `CycleTime` (for example `1.0`). Calculation starts automatically after step 4.

## Worked 6-Node Example

- Edges: `1 2 0.4`, `1 3 0.4`, `2 4 0.6`, `3 4 0.3`, `4 5 0.5`, `5 6 0.2`
- Final node and Tek: `6 0.4`
- Cycle time: `1.0`
- Balanced output:
  - **Station 1**: `N1, N2` (Load `1.0`, Idle `0`)
  - **Station 2**: `N3, N4, N5` (Load `1.0`, Idle `0`)
  - **Station 3**: `N6` (Load `0.4`, Idle `0.6`)
  - **Balance Delay**: `20%` (`0.2`), **Line Efficiency**: `80%`, **Production Rate**: `1 units/min`
