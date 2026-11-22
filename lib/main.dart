import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ranked_positional_method/app/di/service_locator.dart';
import 'package:ranked_positional_method/app/router/app_router.dart';
import 'package:ranked_positional_method/core/constants/app_constants.dart';
import 'package:ranked_positional_method/data/repositories/theme_repository.dart';
import 'package:ranked_positional_method/ui/core/theme/app_theme.dart';
import 'package:ranked_positional_method/ui/features/calculator/view_models/calculator_view_model.dart';

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  final ServiceLocator locator = ServiceLocator.instance;
  await locator.themeRepository.load();
  runApp(CalculateRpwApp(locator: locator));
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (kIsWeb) {
      return child;
    }
    return super.buildOverscrollIndicator(context, child, details);
  }
}

/// Root widget configuring providers, Material 3 themes, and declarative routing.
class CalculateRpwApp extends StatefulWidget {
  /// Creates the root application widget backed by [locator].
  const CalculateRpwApp({
    super.key,
    required this.locator,
  });

  /// Dependency container providing services, repositories, and solvers.
  final ServiceLocator locator;

  @override
  State<CalculateRpwApp> createState() => _CalculateRpwAppState();
}

class _CalculateRpwAppState extends State<CalculateRpwApp> {
  late final GoRouter _router = AppRouter.create();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ThemeRepository>.value(
          value: widget.locator.themeRepository,
        ),
        ChangeNotifierProvider<CalculatorViewModel>(
          create: (_) => CalculatorViewModel(
            validator: widget.locator.validator,
            solver: widget.locator.solver,
            composer: widget.locator.composer,
            clipboard: widget.locator.clipboard,
          ),
        ),
      ],
      child: Selector<ThemeRepository, ThemeMode>(
        selector: (_, ThemeRepository repo) => repo.themeMode,
        builder: (BuildContext context, ThemeMode themeMode, _) {
          return MaterialApp.router(
            title: AppConstants.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            highContrastTheme: AppTheme.highContrastLight(),
            highContrastDarkTheme: AppTheme.highContrastDark(),
            themeMode: themeMode,
            themeAnimationDuration: Duration.zero,
            scrollBehavior: const _AppScrollBehavior(),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
