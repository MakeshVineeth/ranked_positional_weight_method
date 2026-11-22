/// Material 3 adaptive layout size classes derived from available window width.
enum WindowSizeClass {
  /// Ultra-compact surfaces such as Wear OS watches (under 300 logical pixels).
  wear,

  /// Phones in portrait and narrow split windows (300 to 599 logical pixels).
  compact,

  /// Small tablets, foldables unfolded, and medium windows (600 to 839 logical pixels).
  medium,

  /// Large tablets and desktop split views (840 to 1199 logical pixels).
  expanded,

  /// Wide desktop and external monitor windows (1200 logical pixels and above).
  large;

  /// Resolves the [WindowSizeClass] from [width] in logical pixels.
  static WindowSizeClass fromWidth(double width) {
    if (width < 300) {
      return WindowSizeClass.wear;
    }
    if (width < 600) {
      return WindowSizeClass.compact;
    }
    if (width < 840) {
      return WindowSizeClass.medium;
    }
    if (width < 1200) {
      return WindowSizeClass.expanded;
    }
    return WindowSizeClass.large;
  }

  /// Whether the layout has enough horizontal room for a side-by-side split pane.
  bool get supportsSplitPane => switch (this) {
    WindowSizeClass.wear || WindowSizeClass.compact => false,
    WindowSizeClass.medium || WindowSizeClass.expanded || WindowSizeClass.large => true,
  };

  /// Whether navigation should use a side rail instead of a bottom bar.
  bool get usesNavigationRail => switch (this) {
    WindowSizeClass.wear || WindowSizeClass.compact => false,
    WindowSizeClass.medium || WindowSizeClass.expanded || WindowSizeClass.large => true,
  };
}
