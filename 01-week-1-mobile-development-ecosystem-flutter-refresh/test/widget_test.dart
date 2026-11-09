import 'package:flutter_test/flutter_test.dart';
import 'package:week1_flutter_refresh/main.dart';

void main() {
  testWidgets('student profile is displayed', (tester) async {
    await tester.pumpWidget(const Week1App());
    expect(find.text('Flutter Refresh'), findsOneWidget);
    expect(find.text('244107020161'), findsOneWidget);
  });
}
