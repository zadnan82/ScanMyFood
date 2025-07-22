// lib/utils/navigation_helper.dart - Utility for consistent navigation across iOS/Android
import 'package:flutter/material.dart';

class NavigationHelper {
  /// Check if the current route is the root route (can't go back)
  static bool isRootRoute(BuildContext context) {
    return !Navigator.of(context).canPop();
  }

  /// Check if navigation can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  /// Safely navigate back if possible
  static void safeBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Build a platform-appropriate back button
  static Widget buildBackButton(
    BuildContext context, {
    Color? color,
    VoidCallback? onPressed,
    double? size,
  }) {
    return IconButton(
      icon: Icon(
        Theme.of(context).platform == TargetPlatform.iOS
            ? Icons.arrow_back_ios
            : Icons.arrow_back,
        color: color ?? Colors.white,
        size: size ?? 24,
      ),
      onPressed: onPressed ?? () => safeBack(context),
    );
  }

  /// Check if we're currently in a bottom navigation context
  static bool isInBottomNavContext(BuildContext context) {
    // Get the current route name/settings
    final route = ModalRoute.of(context);
    if (route == null) return false;

    // Check if this is the first route (bottom nav root)
    return route.isFirst;
  }

  /// Build appropriate app bar based on context
  static Widget buildAppBar({
    required BuildContext context,
    required String title,
    String? subtitle,
    List<Widget>? actions,
    Widget? leading,
    bool forceShowBack = false,
    PreferredSizeWidget? bottom,
  }) {
    final bool shouldShowBack = forceShowBack || canGoBack(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: shouldShowBack ? (leading ?? buildBackButton(context)) : null,
      automaticallyImplyLeading: shouldShowBack,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  /// Show a confirmation dialog before sensitive actions
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    IconData? icon,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: confirmColor ?? const Color(0xFF6366F1),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    cancelText ?? 'Cancel',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor ?? const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    confirmText ?? 'Confirm',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Navigate to a page with proper transition
  static Future<T?> navigateTo<T extends Object?>(
    BuildContext context,
    Widget page, {
    bool replace = false,
    bool clearStack = false,
  }) async {
    if (clearStack) {
      return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => page),
        (route) => false,
      );
    } else if (replace) {
      return Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      return Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  /// Create a consistent SliverAppBar for pages
  static Widget buildSliverAppBar({
    required BuildContext context,
    required String title,
    String? subtitle,
    required double expandedHeight,
    Widget? leading,
    List<Widget>? actions,
    bool forceShowBack = false,
    Widget? backgroundWidget,
    List<Color>? gradientColors,
  }) {
    final bool shouldShowBack = forceShowBack || canGoBack(context);

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      leading: shouldShowBack ? (leading ?? buildBackButton(context)) : null,
      automaticallyImplyLeading: shouldShowBack,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        background: backgroundWidget ??
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors ??
                      [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                      ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

// Extension to add navigation context methods to BuildContext
extension NavigationContext on BuildContext {
  bool get canNavigateBack => NavigationHelper.canGoBack(this);
  bool get isRootRoute => NavigationHelper.isRootRoute(this);
  bool get isInBottomNav => NavigationHelper.isInBottomNavContext(this);

  void safeBack() => NavigationHelper.safeBack(this);

  Future<T?> navigateTo<T extends Object?>(
    Widget page, {
    bool replace = false,
    bool clearStack = false,
  }) =>
      NavigationHelper.navigateTo<T>(this, page,
          replace: replace, clearStack: clearStack);

  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    IconData? icon,
  }) =>
      NavigationHelper.showConfirmationDialog(
        context: this,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
      );
}
