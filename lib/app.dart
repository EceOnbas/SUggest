import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

class SUggestApp extends StatelessWidget {
  const SUggestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUggest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.table,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
