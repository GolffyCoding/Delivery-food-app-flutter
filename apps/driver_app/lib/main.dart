import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:driver_app/app.dart';
import 'package:driver_app/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await configureDependencies();
  runApp(const DriverApp());
}
