import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/widgets/secondary_button.dart';
import '../shell/team_placeholder_screen.dart';

/// Courses tab: Home, catalog and search.
// TODO(Emine Sena Cesur): replace this placeholder with the Home screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TeamPlaceholderScreen(
      title: 'Courses',
      owner: 'Emine Sena Cesur',
      description:
          'Home, catalog and search. A course row opens the '
          'course page with Navigator.pushNamed(context, AppRoutes.course, '
          "arguments: 'CS 310').",
      actions: [
        SecondaryButton(
          label: 'Open CS 310',
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.course,
            arguments: 'CS 310',
          ),
        ),
        SecondaryButton(
          label: 'Widget gallery',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.gallery),
        ),
      ],
    );
  }
}
