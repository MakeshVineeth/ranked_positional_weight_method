import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/app/di/service_locator.dart';
import 'package:ranked_positional_method/data/repositories/theme_repository.dart';
import 'package:ranked_positional_method/data/services/clipboard_service.dart';
import 'package:ranked_positional_method/data/services/preferences_storage_service.dart';
import 'package:ranked_positional_method/main.dart';

class _InMemoryStorage implements KeyValueStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> readString(String key) async => _values[key];

  @override
  Future<void> writeString(String key, String value) async {
    _values[key] = value;
  }
}

class _InMemoryClipboard implements ClipboardAdapter {
  String? copiedText;

  @override
  Future<void> copyText(String text) async {
    copiedText = text;
  }
}

void main() {
  late _InMemoryClipboard fakeClipboard;

  setUp(() {
    fakeClipboard = _InMemoryClipboard();
    final _InMemoryStorage storage = _InMemoryStorage();
    ServiceLocator.configure(
      storage: storage,
      clipboard: fakeClipboard,
      themeRepository: ThemeRepository(storage: storage),
    );
  });

  tearDown(ServiceLocator.reset);

  testWidgets('Phone viewport solves 6-node sample, copies result, and meets a11y guidelines', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(CalculateRpwApp(locator: ServiceLocator.instance));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('6-Node Classic Line'), findsOneWidget);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      await tester.tap(find.text('6-Node Classic Line'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Copy Report'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Calculated Results'), findsOneWidget);

      await tester.tap(find.text('Copy Report'));
      await tester.pump();
      expect(fakeClipboard.copiedText, contains('Workstations: 3'));
      expect(find.text('Copied full RPW report to clipboard.'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Production Rate'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Production Rate'), findsOneWidget);
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      await tester.scrollUntilVisible(
        find.text('Quick Text'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quick Text'));
      await tester.pumpAndSettle();
      expect(find.text('Quick Text Entry'), findsOneWidget);

      await tester.tap(find.text('Help'));
      await tester.pumpAndSettle();
      expect(find.text('How to Use Calculate RPW'), findsOneWidget);

      await tester.tap(find.text('Privacy'));
      await tester.pumpAndSettle();
      expect(find.text('Privacy Policy and About'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('Theme toggle cycles System, Light, and Dark cleanly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(CalculateRpwApp(locator: ServiceLocator.instance));
    await tester.pumpAndSettle();

    final ThemeRepository repo = ServiceLocator.instance.themeRepository;
    expect(repo.themeMode, equals(ThemeMode.system));

    await tester.tap(find.byTooltip('Switch theme, currently System'));
    await tester.pump();
    expect(repo.themeMode, equals(ThemeMode.light));

    await tester.tap(find.byTooltip('Switch theme, currently Light'));
    await tester.pump();
    expect(repo.themeMode, equals(ThemeMode.dark));

    await tester.tap(find.byTooltip('Switch theme, currently Dark'));
    await tester.pump();
    expect(repo.themeMode, equals(ThemeMode.system));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tablet and desktop viewport renders NavigationRail and split pane', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(CalculateRpwApp(locator: ServiceLocator.instance));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Ready to Balance Your Assembly Line'), findsOneWidget);
  });

  testWidgets('Wear OS viewport renders compact layout cleanly without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(240, 240);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(CalculateRpwApp(locator: ServiceLocator.instance));
    await tester.pumpAndSettle();

    expect(find.text('RPW Quick Solve'), findsOneWidget);
    await tester.tap(find.text('6-Node Classic Line'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('3 Stations'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('3 Stations'), findsOneWidget);
  });

  testWidgets('Large text scaling renders cleanly without layout errors', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          textScaler: TextScaler.linear(1.8),
        ),
        child: CalculateRpwApp(locator: ServiceLocator.instance),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('6-Node Classic Line'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
