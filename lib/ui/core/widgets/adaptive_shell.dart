import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:ranked_positional_method/core/constants/app_constants.dart';
import 'package:ranked_positional_method/core/layout/window_size_class.dart';
import 'package:ranked_positional_method/data/repositories/theme_repository.dart';

/// Top-level adaptive navigation shell handling Wear, Phone, Tablet, and Desktop layouts.
class AdaptiveShell extends StatelessWidget {
  /// Creates an [AdaptiveShell] wrapping [navigationShell].
  const AdaptiveShell({
    super.key,
    required this.navigationShell,
  });

  /// Active stateful navigation shell managed by `go_router`.
  final StatefulNavigationShell navigationShell;

  static const List<({String label, IconData icon, IconData selectedIcon})> _destinations =
      <({String label, IconData icon, IconData selectedIcon})>[
        (
          label: 'Calculator',
          icon: Icons.calculate_outlined,
          selectedIcon: Icons.calculate,
        ),
        (
          label: 'Help',
          icon: Icons.help_outline_rounded,
          selectedIcon: Icons.help_rounded,
        ),
        (
          label: 'Privacy',
          icon: Icons.privacy_tip_outlined,
          selectedIcon: Icons.privacy_tip_rounded,
        ),
      ];

  void _selectBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeRepository themeRepo = context.watch<ThemeRepository>();
    final (IconData themeIcon, String themeLabel) = switch (themeRepo.themeMode) {
      ThemeMode.light => (Icons.light_mode_rounded, 'Switch theme, currently Light'),
      ThemeMode.dark => (Icons.dark_mode_rounded, 'Switch theme, currently Dark'),
      ThemeMode.system => (Icons.brightness_auto_rounded, 'Switch theme, currently System'),
    };

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final WindowSizeClass sizeClass = WindowSizeClass.fromWidth(constraints.maxWidth);

        if (sizeClass == WindowSizeClass.wear) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        for (int i = 0; i < _destinations.length; i++)
                          IconButton(
                            onPressed: () => _selectBranch(i),
                            tooltip: _destinations[i].label,
                            isSelected: navigationShell.currentIndex == i,
                            iconSize: 18,
                            icon: Icon(
                              navigationShell.currentIndex == i
                                  ? _destinations[i].selectedIcon
                                  : _destinations[i].icon,
                            ),
                          ),
                        IconButton(
                          onPressed: themeRepo.cycleThemeMode,
                          tooltip: themeLabel,
                          iconSize: 18,
                          icon: Icon(themeIcon),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
          );
        }

        final AppBar appBar = AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/logo.png',
                width: 26,
                height: 26,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: 10),
              const Flexible(
                child: Text(
                  AppConstants.appTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              onPressed: themeRepo.cycleThemeMode,
              tooltip: themeLabel,
              icon: Icon(themeIcon),
            ),
            const SizedBox(width: 4),
          ],
        );

        if (!sizeClass.usesNavigationRail) {
          return Scaffold(
            appBar: appBar,
            body: SafeArea(
              top: false,
              child: navigationShell,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _selectBranch,
              destinations: _destinations
                  .map(
                    (dest) => NavigationDestination(
                      icon: Icon(dest.icon),
                      selectedIcon: Icon(dest.selectedIcon),
                      label: dest.label,
                    ),
                  )
                  .toList(growable: false),
            ),
          );
        }

        return Scaffold(
          appBar: appBar,
          body: SafeArea(
            top: false,
            child: Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _selectBranch,
                  extended: sizeClass == WindowSizeClass.large,
                  labelType: sizeClass == WindowSizeClass.large
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  destinations: _destinations
                      .map(
                        (dest) => NavigationRailDestination(
                          icon: Icon(dest.icon),
                          selectedIcon: Icon(dest.selectedIcon),
                          label: Text(dest.label),
                        ),
                      )
                      .toList(growable: false),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          ),
        );
      },
    );
  }
}
