import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ranked_positional_method/app/di/service_locator.dart';
import 'package:ranked_positional_method/core/constants/app_constants.dart';
import 'package:ranked_positional_method/data/repositories/theme_repository.dart';
import 'package:ranked_positional_method/data/services/clipboard_service.dart';
import 'package:ranked_positional_method/data/services/preferences_storage_service.dart';
import 'package:ranked_positional_method/data/services/url_launcher_service.dart';
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

class _InMemoryUrlLauncher implements UrlLauncherAdapter {
  final List<Uri> launchedUris = <Uri>[];
  bool shouldSucceed = true;

  @override
  Future<bool> openExternalUrl(Uri uri) async {
    launchedUris.add(uri);
    return shouldSucceed;
  }
}

void main() {
  late _InMemoryClipboard fakeClipboard;
  late _InMemoryUrlLauncher fakeUrlLauncher;

  setUp(() {
    fakeClipboard = _InMemoryClipboard();
    fakeUrlLauncher = _InMemoryUrlLauncher();
    final _InMemoryStorage storage = _InMemoryStorage();
    ServiceLocator.configure(
      storage: storage,
      clipboard: fakeClipboard,
      urlLauncher: fakeUrlLauncher,
      themeRepository: ThemeRepository(storage: storage),
    );
  });

  tearDown(ServiceLocator.reset);

  testWidgets(
    'Phone viewport shows inline errors, auto-scrolls to results on solve, and jumps back cleanly',
    (WidgetTester tester) async {
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

        // Scroll to Calculate button and verify empty submission shows inline error nearby.
        await tester.ensureVisible(find.text('Calculate'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Calculate'));
        await tester.pumpAndSettle();
        expect(find.text('Add at least one node connection before calculating.'), findsOneWidget);

        // Scroll back to top and enter a real manual problem, then tap Calculate.
        await tester.scrollUntilVisible(
          find.widgetWithText(TextField, 'From'),
          -200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(find.widgetWithText(TextField, 'From'), '1');
        await tester.enterText(find.widgetWithText(TextField, 'To'), '2');
        await tester.enterText(find.widgetWithText(TextField, 'Tek'), '0.4');
        await tester.ensureVisible(find.text('Add'));
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.widgetWithText(TextField, 'Final Node'));
        await tester.enterText(find.widgetWithText(TextField, 'Final Node'), '2');
        await tester.enterText(find.widgetWithText(TextField, 'Final Tek'), '0.5');
        await tester.enterText(find.widgetWithText(TextField, 'Cycle Time'), '1.0');

        await tester.ensureVisible(find.text('Calculate'));
        await tester.tap(find.text('Calculate'));
        await tester.pumpAndSettle();

        // Results header and actions must automatically scroll into view after Calculate.
        expect(find.text('Calculated Results'), findsOneWidget);
        expect(find.text('Edit Inputs'), findsOneWidget);
        expect(find.text('Copy Report'), findsOneWidget);

        await tester.tap(find.text('Copy Report'));
        await tester.pump();
        expect(fakeClipboard.copiedText, contains('Workstations: 1'));
        expect(find.text('Copied full RPW report to clipboard.'), findsOneWidget);

        // Jump back up to Edit Inputs cleanly in one tap.
        await tester.tap(find.text('Edit Inputs'));
        await tester.pumpAndSettle();

        // Tapping Quick Example also auto-scrolls straight to results.
        await tester.tap(find.text('6-Node Classic Line'));
        await tester.pumpAndSettle();
        expect(find.text('Calculated Results'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Production Rate'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Production Rate'), findsOneWidget);
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        await tester.scrollUntilVisible(
          find.text('Edit Inputs'),
          -200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Edit Inputs'));
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
    },
  );

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

  testWidgets(
    'Privacy screen displays accessible clickable hyperlinks for privacy policy and project URLs',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(CalculateRpwApp(locator: ServiceLocator.instance));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Privacy'));
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        final Finder scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text(AppConstants.privacyPolicyUrl),
          150,
          scrollable: scrollable,
        );
        await tester.ensureVisible(find.text(AppConstants.privacyPolicyUrl));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppConstants.privacyPolicyUrl));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text(AppConstants.projectUrl),
          150,
          scrollable: scrollable,
        );
        await tester.ensureVisible(find.text(AppConstants.projectUrl));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppConstants.projectUrl));
        await tester.pumpAndSettle();

        expect(
          fakeUrlLauncher.launchedUris,
          equals(<Uri>[
            Uri.parse(AppConstants.privacyPolicyUrl),
            Uri.parse(AppConstants.projectUrl),
          ]),
        );

        fakeUrlLauncher.shouldSucceed = false;
        await tester.tap(find.text(AppConstants.projectUrl));
        await tester.pumpAndSettle();

        expect(
          find.text('Could not open project page. Use the copy button to copy the link.'),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    },
  );
}
