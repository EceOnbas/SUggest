import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/core/widgets/app_card.dart';
import 'package:suggest/core/widgets/app_text_field.dart';
import 'package:suggest/features/profile/my_profile_screen.dart';
import 'package:suggest/features/profile/my_profile_store.dart';
import 'package:suggest/features/profile/widgets/my_review_card.dart';
import 'package:suggest/features/profile/widgets/rating_row.dart';
import 'package:suggest/models/review_topic.dart';
import 'package:suggest/models/user_profile.dart';
import 'package:suggest/services/auth_service.dart';
import 'package:suggest/services/fake_auth_service.dart';

/// Opens My Profile signed in. By default it is the showcase account,
/// which has a full profile, six courses and two reviews. With
/// [showcase] false it is the empty demo account. [profile] replaces the
/// profile setup answers; for the empty account, null means setup was
/// never finished.
Future<FakeAuthService> openProfile(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  bool showcase = true,
  UserProfile? profile,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  if (textScale != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  // Each test starts from the account's starting data.
  MyProfileStore.instance.reset();
  addTearDown(MyProfileStore.instance.reset);
  final auth = FakeAuthService(delay: Duration.zero);
  final name = showcase
      ? FakeAuthService.showcaseAccount
      : FakeAuthService.demoAccounts.keys.first;
  await auth.logIn(
    localPart: name,
    password: FakeAuthService.demoAccounts[name]!,
  );
  if (profile != null) await auth.saveProfile(profile);
  await tester.pumpWidget(
    AuthScope(
      service: auth,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const MyProfileScreen(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

/// Opens [route] on top of My Profile, as another screen would.
Future<void> pushRoute(
  WidgetTester tester,
  String route, {
  Object? arguments,
}) async {
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .pushNamed(route, arguments: arguments);
  await tester.pumpAndSettle();
}

/// Scrolls [finder] into view and taps it.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) =>
    tapOn(tester, find.text(text).last);

/// Opens the dropdown under [label] and picks [option].
Future<void> pickFromDropdown(
  WidgetTester tester,
  String label,
  String option,
) async {
  final field = find.descendant(
    of: find
        .ancestor(of: find.text(label), matching: find.byType(Column))
        .first,
    matching: find.byType(DropdownButton<String>),
  );
  await tapOn(tester, field);
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

/// Taps [score] on the 1–5 picker of [topic].
Future<void> rate(WidgetTester tester, ReviewTopic topic, int score) async {
  final row = find.byWidgetPredicate((w) => w is RatingRow && w.topic == topic);
  await tapOn(tester, find.descendant(of: row, matching: find.text('$score')));
}

/// The text field labelled [label]. The last match is used, because
/// the profile page under a sheet may show the same words.
Finder fieldLabelled(String label) => find.descendant(
  of: find
      .ancestor(of: find.text(label).last, matching: find.byType(Column))
      .first,
  matching: find.byType(TextField),
);

/// The "Edit" link of the account card and of the academic card.
final editAccountLink = find.text('Edit').first;
final editAcademicLink = find.text('Edit').at(1);

/// The "Manage" link of the Courses Taken card.
final manageCoursesLink = find.text('Manage');

/// The card on My Courses for [label], for example
/// "CS 310 · Mobile Application Development".
Finder courseTile(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(AppCard)).first;

/// [text] inside the My Courses card for [label].
Finder inCourseTile(String label, Finder finder) =>
    find.descendant(of: courseTile(label), matching: finder);

/// The text in the locked field labelled [label], such as "Term Taken".
String lockedValue(WidgetTester tester, String label) =>
    tester.widget<TextField>(lockedField(label)).controller!.text;

/// The read-only field labelled [label] on Write Review.
Finder lockedField(String label) => find.descendant(
  of: find
      .ancestor(of: find.text(label).first, matching: find.byType(AppTextField))
      .first,
  matching: find.byType(TextField),
);

/// [text] on one of the My Reviews cards (the Courses Taken card may
/// show the same course name).
Finder inReviews(String text) =>
    find.descendant(of: find.byType(MyReviewCard), matching: find.text(text));
