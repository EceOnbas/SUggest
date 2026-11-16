import 'package:flutter/material.dart';

import '../shell/team_placeholder_screen.dart';

/// Profile tab: My Profile, account and academic editing, my reviews.
// TODO(Ece Önbaş): replace this placeholder with My Profile.
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamPlaceholderScreen(
      title: 'My Profile',
      owner: 'Ece Önbaş',
      description:
          'Account and academic details, my reviews, write, edit '
          'and delete a review.',
    );
  }
}
