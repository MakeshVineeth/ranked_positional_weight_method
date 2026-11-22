import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:ranked_positional_method/app/router/app_router.dart';
import 'package:ranked_positional_method/core/layout/window_size_class.dart';
import 'package:ranked_positional_method/domain/services/sample_problem_factory.dart';
import 'package:ranked_positional_method/ui/features/calculator/view_models/calculator_view_model.dart';

/// In-app documentation explaining the RPW method, terms, and input modes.
class HelpGuideScreen extends StatelessWidget {
  /// Creates a [HelpGuideScreen].
  const HelpGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double pad = WindowSizeClass.fromWidth(constraints.maxWidth) == WindowSizeClass.wear
            ? 14
            : 20;

        final List<Widget> items = <Widget>[
          Semantics(
            header: true,
            child: Text(
              'How to Use Calculate RPW',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This app balances assembly lines offline using the Ranked Positional Weight (RPW) method introduced by Helgeson and Birnie. Enter your precedence diagram, task times, and target cycle time to assign work elements into workstations.',
            style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          const _GuideCard(
            title: 'Key Terms',
            lines: <String>[
              'Node: A numbered work task in your assembly process (1, 2, 3, and so on).',
              'Tek: The time required to finish a single task, entered as zero or a positive number.',
              'Connection (From -> To): A precedence rule showing that the From task must finish before the To task can begin.',
              'Final Node: The last task at the end of the precedence diagram where all paths finish.',
              'Cycle Time: The maximum time allowed at each workstation to meet your production pace.',
              'RPW: A task weight equal to its own Tek plus the Tek of every task reachable downstream from it.',
              'Balance Delay: Percentage of idle time across all stations relative to total available station time.',
              'Production Rate: Output capacity calculated as 1 divided by the highest station load.',
            ],
          ),
          const SizedBox(height: 12),
          const _GuideCard(
            title: 'Using Guided Form Mode',
            lines: <String>[
              '1. Enter each arrow connection with From, To, and the From task Tek, then select Add.',
              '2. Enter the Final Node ID and its Tek value.',
              '3. Enter your target Cycle Time.',
              '4. Select Calculate to view summary metrics, workstation assignments, the sorted RPW table, and arrow chains.',
              '5. Activate any output card to copy that line, or select Copy Report for the full summary.',
            ],
          ),
          const SizedBox(height: 12),
          const _GuideCard(
            title: 'Using Quick Text Mode',
            lines: <String>[
              'Quick Text Mode lets you type space-separated numbers continuously with the keyboard:',
              'Step 1: Enter the total number of connections (for example: 6).',
              'Step 2: Enter each connection line as From To Tek (for example: 1 2 0.4).',
              'Step 3: Enter the Final Node ID and its Tek separated by a space (for example: 6 0.4).',
              'Step 4: Enter the Cycle Time (for example: 1.0). Results calculate automatically.',
            ],
          ),
          const SizedBox(height: 12),
          const _GuideCard(
            title: 'Worked 6-Node Example',
            lines: <String>[
              'Connections: 1->2 (0.4), 1->3 (0.4), 2->4 (0.6), 3->4 (0.3), 4->5 (0.5), 5->6 (0.2).',
              'Final Node: 6 with Tek 0.4. Cycle Time: 1.0.',
              'Result: 3 workstations (S1: N1, N2; S2: N3, N4, N5; S3: N6), 20% balance delay, and 80% line efficiency.',
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () {
                context.read<CalculatorViewModel>().loadSample(SamplePreset.classicSixNode);
                context.go(AppRouter.calculatorPath);
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Load 6-Node Example in Calculator'),
            ),
          ),
        ];

        return ListView.builder(
          padding: EdgeInsets.all(pad),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: SizedBox(width: double.infinity, child: items[index]),
              ),
            );
          },
        );
      },
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            for (final String line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(line, style: textTheme.bodyMedium),
              ),
          ],
        ),
      ),
    );
  }
}
