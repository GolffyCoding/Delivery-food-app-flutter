import 'package:flutter/material.dart';

/// Lets code outside the widget tree (DI setup, background services like
/// [SyncManager]) surface a SnackBar without needing a BuildContext.
final GlobalKey<ScaffoldMessengerState> appMessengerKey = GlobalKey<ScaffoldMessengerState>();
