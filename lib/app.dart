import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';

class SUggestApp extends StatelessWidget {
  const SUggestApp({super.key, required this.auth});

  /// Sign-in for the whole app: FakeAuthService in Step 2, Firebase in
  /// Step 3.
  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      service: auth,
      child: MaterialApp(
        title: 'SUggest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.start,
        routes: AppRoutes.table,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
