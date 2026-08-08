import 'package:flutter/material.dart';

/// Custom application app bar with consistent styling.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPress;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;

  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.showBackButton = false,
    this.onBackPress,
    this.leading,
    this.centerTitle = false,
    this.elevation,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBackPress ?? () => Navigator.of(context).maybePop(),
            )
          : leading,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      scrolledUnderElevation: 1,
    );
  }
}
