import 'package:flutter/material.dart';

import 'config/app_router.dart';
import 'core/theme/app_theme.dart';

class SetsiApp extends StatelessWidget {
  const SetsiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "SET'SI SA MBAAR",

      theme: AppTheme.lightTheme,

      routerConfig: appRouter,
    );
  }
}