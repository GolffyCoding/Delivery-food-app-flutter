import 'package:flutter/material.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';

/// A bordered "- N +" stepper for adjusting a quantity, used in the cart and
/// before adding an item to it. Fully controlled: the caller owns [value]
/// and receives changes via [onChanged], so it works the same whether the
/// backing state lives in a bloc or local widget state.
class AppQuantityStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const AppQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: context.colorScheme.outlineVariant), borderRadius: AppRadius.smBorder),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove, onTap: value > min ? () => onChanged(value - 1) : null),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text('$value', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          _StepButton(icon: Icons.add, onTap: value < max ? () => onChanged(value + 1) : null),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fullBorder,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: onTap == null ? context.colorScheme.outlineVariant : null),
      ),
    );
  }
}
