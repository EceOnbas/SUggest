import 'package:flutter/material.dart';

import '../../features/course/course_screen.dart';
import '../../features/dev/widget_gallery_screen.dart';
import '../../features/shell/main_shell.dart';

/// Every screen's route name, in one place.
///
/// Open a screen with `Navigator.pushNamed(context, AppRoutes.login)`.
/// Screens that need data take it as arguments, for example
/// `Navigator.pushNamed(context, AppRoutes.course, arguments: 'CS 310')`.
abstract final class AppRoutes {
  static const home = '/home';
  static const course = '/course';
  static const gallery = '/gallery';

  /// Screens opened by name with no arguments.
  static final Map<String, WidgetBuilder> table = {
    home: (_) => const MainShell(),
    gallery: (_) => const WidgetGalleryScreen(),
  };

  /// Screens that read their arguments.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == course) {
      final code = settings.arguments as String? ?? 'CS 310';
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => CourseScreen(courseCode: code),
      );
    }
    return null;
  }
}
