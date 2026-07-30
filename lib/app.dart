import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],

      locale: const Locale('fr', 'FR'),
    );
  }
}