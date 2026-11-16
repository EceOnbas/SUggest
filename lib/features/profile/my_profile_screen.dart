import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/widgets/secondary_button.dart';
import '../../services/auth_service.dart';
import '../shell/team_placeholder_screen.dart';

/// Profile tab: My Profile, account and academic editing, my reviews.
// TODO(Ece Önbaş): replace this placeholder with My Profile.
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TeamPlaceholderScreen(
      title: 'My Profile',
      owner: 'Ece Önbaş',
      description:
          'Account and academic details, my reviews, write, edit '
          'and delete a review.',
      actions: [
        SecondaryButton(
          label: 'Log out',
          onPressed: () async {
            await AuthScope.of(context).logOut();
            if (context.mounted) await AppRoutes.restart(context);
          },
        ),
      ],
    );
  }
}
