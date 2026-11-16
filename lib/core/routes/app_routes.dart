import 'package:flutter/material.dart';

import '../../features/auth/auth_gate.dart';
import '../../features/auth/check_inbox_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/reset_link_sent_screen.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/course/course_screen.dart';
import '../../features/dev/widget_gallery_screen.dart';
import '../../features/profile_setup/profile_intro_screen.dart';
import '../../features/shell/main_shell.dart';

/// Every screen's route name, in one place.
///
/// Open a screen with `Navigator.pushNamed(context, AppRoutes.login)`.
/// Screens that need data take it as arguments, for example
/// `Navigator.pushNamed(context, AppRoutes.course, arguments: 'CS 310')`.
abstract final class AppRoutes {
  /// The start: [AuthGate] shows the right first screen for the session.
  static const start = '/';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const checkInbox = '/check-inbox';
  static const forgotPassword = '/forgot-password';

  /// Takes the full email address as its argument.
  static const resetLinkSent = '/reset-link-sent';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  static const course = '/course';
  static const gallery = '/gallery';

  /// Screens opened by name with no arguments.
  static final Map<String, WidgetBuilder> table = {
    start: (_) => const AuthGate(),
    login: (_) => const LoginScreen(),
    signUp: (_) => const SignUpScreen(),
    checkInbox: (_) => const CheckInboxScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    profileSetup: (_) => const ProfileIntroScreen(),
    home: (_) => const MainShell(),
    gallery: (_) => const WidgetGalleryScreen(),
  };

  /// Clears the back stack and lets [AuthGate] pick the screen again.
  /// Use it after logging in, signing up, verifying or logging out.
  static Future<void> restart(BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(start, (_) => false);

  /// Screens that read their arguments.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == course) {
      final code = settings.arguments as String? ?? 'CS 310';
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => CourseScreen(courseCode: code),
      );
    }
    if (settings.name == resetLinkSent) {
      final email = settings.arguments as String? ?? 'your SU email';
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => ResetLinkSentScreen(email: email),
      );
    }
    return null;
  }
}
