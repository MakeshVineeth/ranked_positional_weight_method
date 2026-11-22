import 'dart:math' as math;

/// Formats numeric values cleanly without floating-point noise.
abstract final class NumberFormatter {
  /// Formats [value] with up to [maxDecimals] places, trimming trailing zeros.
  static String format(double value, {int maxDecimals = 4}) {
    if (!value.isFinite) {
      return '0';
    }
    final double normalized = value.abs() < 1e-12 ? 0.0 : value;
    final double factor = math.pow(10, maxDecimals).toDouble();
    final double rounded = (normalized * factor).round() / factor;
    if (rounded == rounded.truncateToDouble()) {
      return rounded.toInt().toString();
    }
    final String fixed = rounded.toStringAsFixed(maxDecimals);
    return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  /// Formats a ratio in `[0, 1]` as a percentage string.
  static String formatPercent(double ratio, {int decimals = 1}) {
    final double clamped = ratio.isFinite ? ratio.clamp(0.0, 1.0) * 100 : 0.0;
    return '${format(clamped, maxDecimals: decimals)}%';
  }
}
