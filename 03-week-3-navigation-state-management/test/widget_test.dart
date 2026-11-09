import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:week3_navigation_state/main.dart';

void main() {
  testWidgets('todo can be added', (tester) async {
    await tester.pumpWidget(const Week3App());
    expect(find.text('Pelajari GoRouter'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('Tugas baru'), findsOneWidget);
  });
}
