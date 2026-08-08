import 'package:flutter/material.dart';

/// Themed divider with optional label.
class AppDivider extends StatelessWidget {
  final String? label;
  final double? height;
  final double? indent;
  final double? endIndent;

  const AppDivider({super.key, this.label, this.height, this.indent, this.endIndent});

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return Row(
        children: [
          Expanded(child: Divider(indent: indent, endIndent: 8)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          Expanded(child: Divider(indent: 8, endIndent: endIndent)),
        ],
      );
    }

    return Divider(height: height, indent: indent, endIndent: endIndent);
  }
}
