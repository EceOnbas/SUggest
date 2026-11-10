import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dev/widget_gallery_screen.dart';

class SUggestApp extends StatelessWidget {
  const SUggestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUggest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Temporary start screen until the routes are added.
      home: const WidgetGalleryScreen(),
    );
  }
}
