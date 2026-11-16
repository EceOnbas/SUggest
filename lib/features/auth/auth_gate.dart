import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../profile_setup/profile_intro_screen.dart';
import '../shell/main_shell.dart';
import 'check_inbox_screen.dart';
import 'welcome_screen.dart';

/// Picks the first screen from the session, as in the design:
///
/// | Session                        | First screen     |
/// |--------------------------------|------------------|
/// | Not signed in                  | Welcome          |
/// | Signed in, email not verified  | Check your inbox |
/// | Verified, no profile yet       | Profile intro    |
/// | Verified, profile exists       | Home             |
///
/// It rebuilds whenever the auth status changes. After logging in or
/// out, screens return here with [AppRoutes.restart].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (AuthScope.of(context).status) {
      AuthStatus.signedOut => const WelcomeScreen(),
      AuthStatus.unverified => const CheckInboxScreen(),
      AuthStatus.needsProfile => const ProfileIntroScreen(),
      AuthStatus.ready => const MainShell(),
    };
  }
}
