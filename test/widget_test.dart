import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:suggest/app.dart';

void main() {
  // Tests run offline, so do not let google_fonts download the font.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const SUggestApp());
    expect(find.text('SUggest'), findsOneWidget);
  });
}
