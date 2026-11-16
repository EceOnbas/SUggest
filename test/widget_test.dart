import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/app.dart';
import 'package:suggest/features/auth/welcome_screen.dart';
import 'package:suggest/services/fake_auth_service.dart';

void main() {
  testWidgets('app starts on Welcome when no one is signed in', (tester) async {
    await tester.pumpWidget(
      SUggestApp(auth: FakeAuthService(delay: Duration.zero)),
    );
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
