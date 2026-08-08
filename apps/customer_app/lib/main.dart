import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:customer_app/app.dart';
import 'package:customer_app/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await configureDependencies();

  runApp(const CustomerApp());
}
