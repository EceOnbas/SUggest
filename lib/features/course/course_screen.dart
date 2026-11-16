import 'package:flutter/material.dart';

import '../shell/team_placeholder_screen.dart';

/// The course page: Overview, Sections and Reviews tabs.
class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key, required this.courseCode});

  final String courseCode;

  @override
  Widget build(BuildContext context) {
    return TeamPlaceholderScreen(
      title: courseCode,
      owner: 'Beren Güler',
      description: 'Course page with Overview, Sections and Reviews tabs.',
      showBackButton: true,
    );
  }
}
