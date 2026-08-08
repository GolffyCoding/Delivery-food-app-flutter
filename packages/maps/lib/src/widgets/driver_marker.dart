import 'package:flutter/material.dart';

/// Custom widget for driver marker on maps.
class DriverMarkerWidget extends StatelessWidget {
  final bool isOnline;

  const DriverMarkerWidget({super.key, this.isOnline = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? Colors.green : Colors.grey,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.delivery_dining, color: Colors.white, size: 20),
      ),
    );
  }
}
