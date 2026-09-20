import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = borderColor != null
        ? BorderSide(color: borderColor!, width: 1.2)
        : (theme.cardTheme.shape as RoundedRectangleBorder?)?.side ?? BorderSide.none;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: border,
    );

    final content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    return Material(
      color: backgroundColor ?? theme.cardTheme.color,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: content,
            )
          : content,
    );
  }
}
