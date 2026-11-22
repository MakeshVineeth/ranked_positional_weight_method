import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:ranked_positional_method/domain/models/result_node.dart';
import 'package:ranked_positional_method/ui/core/theme/app_theme.dart';
import 'package:ranked_positional_method/ui/core/widgets/copyable_result_card.dart';
import 'package:ranked_positional_method/ui/features/privacy/views/privacy_screen.dart';

/// Custom preview wrapper applying light and dark Material 3 themes.
final class AppBrightnessPreview extends MultiPreview {
  /// Creates a light and dark preview pair titled [name].
  const AppBrightnessPreview({required this.name});

  /// Display title shown in the widget previewer.
  final String name;

  @override
  List<Preview> get previews => const <Preview>[
    Preview(brightness: Brightness.light),
    Preview(brightness: Brightness.dark),
  ];

  @override
  List<Preview> transform() {
    final List<Preview> base = super.transform();
    return base.map((Preview preview) {
      final PreviewBuilder builder = preview.toBuilder()
        ..group = 'Calculate RPW'
        ..name = '$name (${preview.brightness!.name})';
      return builder.build();
    }).toList();
  }
}

/// Interactive preview of [CopyableResultCard].
@AppBrightnessPreview(name: 'Copyable Result Card')
Widget copyableResultCardPreview() {
  return MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CopyableResultCard(
          item: const ResultItem(
            title: 'Station 1',
            value: 'N1, N2',
            subtitle: 'Load: 1 | Idle: 0',
            isHighlighted: true,
          ),
          onCopy: (_) async {},
        ),
      ),
    ),
  );
}

/// Interactive preview of [PrivacyScreen].
@Preview(name: 'Privacy Screen', group: 'Calculate RPW', size: Size(412, 700))
Widget privacyScreenPreview() {
  return MaterialApp(
    theme: AppTheme.light(),
    home: const Scaffold(
      body: PrivacyScreen(),
    ),
  );
}
