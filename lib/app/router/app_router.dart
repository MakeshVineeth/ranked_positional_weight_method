import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:ranked_positional_method/ui/core/widgets/adaptive_shell.dart';
import 'package:ranked_positional_method/ui/features/calculator/views/calculator_screen.dart';
import 'package:ranked_positional_method/ui/features/help/views/help_guide_screen.dart';
import 'package:ranked_positional_method/ui/features/privacy/views/privacy_screen.dart';

/// Declarative application router configuration.
abstract final class AppRouter {
  /// Route path for the RPW calculator workspace.
  static const String calculatorPath = '/';

  /// Route path for the in-app Help Guide.
  static const String helpPath = '/help';

  /// Route path for the Privacy Policy and About page.
  static const String privacyPath = '/privacy';

  /// Creates the [GoRouter] managing stateful shell navigation.
  static GoRouter create({String initialLocation = calculatorPath}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder:
              (
                BuildContext context,
                GoRouterState state,
                StatefulNavigationShell navigationShell,
              ) {
                return AdaptiveShell(navigationShell: navigationShell);
              },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: calculatorPath,
                  name: 'calculator',
                  builder: (BuildContext context, GoRouterState state) => const CalculatorScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: helpPath,
                  name: 'help',
                  builder: (BuildContext context, GoRouterState state) => const HelpGuideScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: privacyPath,
                  name: 'privacy',
                  builder: (BuildContext context, GoRouterState state) => const PrivacyScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (BuildContext context, GoRouterState state) => const Scaffold(
        body: Center(child: Text('Page not found.')),
      ),
    );
  }
}
