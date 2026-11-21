import 'package:flutter/material.dart';

import '../../features/auth/auth_gate.dart';
import '../../features/auth/check_inbox_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/reset_link_sent_screen.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/course/course_screen.dart';
import '../../features/dev/widget_gallery_screen.dart';
import '../../features/profile/edit_academic_screen.dart';
import '../../features/profile/models/my_review.dart';
import '../../features/profile/models/profile_details.dart';
import '../../features/profile/my_courses_screen.dart';
import '../../features/profile/write_review_screen.dart';
import '../../features/profile_setup/profile_setup_flow.dart';
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

  /// Takes the [MyReview] to edit as its argument, a course code such as
  /// 'CS 310' to start with that course, or nothing. Returns the saved
  /// review.
  static const writeReview = '/write-review';

  /// The student's courses taken. Takes an optional course code to start
  /// the add form with.
  static const myCourses = '/my-courses';

  /// Takes [EditAcademicArgs] as its argument. Returns the saved
  /// [AcademicDetails].
  static const editAcademic = '/edit-academic';

  /// Screens opened by name with no arguments.
  static final Map<String, WidgetBuilder> table = {
    start: (_) => const AuthGate(),
    login: (_) => const LoginScreen(),
    signUp: (_) => const SignUpScreen(),
    checkInbox: (_) => const CheckInboxScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    profileSetup: (_) => const ProfileSetupFlow(),
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
    if (settings.name == writeReview) {
      return MaterialPageRoute<MyReview>(
        settings: settings,
        fullscreenDialog: true,
        builder: (_) => switch (settings.arguments) {
          final MyReview review => WriteReviewScreen(existing: review),
          final String code => WriteReviewScreen(courseCode: code),
          _ => const WriteReviewScreen(),
        },
      );
    }
    if (settings.name == myCourses) {
      return MaterialPageRoute<bool>(
        settings: settings,
        builder: (_) =>
            MyCoursesScreen(preselectedCode: settings.arguments as String?),
      );
    }
    if (settings.name == editAcademic) {
      final args =
          settings.arguments as EditAcademicArgs? ??
          const EditAcademicArgs(AcademicDetails());
      return MaterialPageRoute<AcademicDetails>(
        settings: settings,
        builder: (_) => EditAcademicScreen(args: args),
      );
    }
    return null;
  }
}
