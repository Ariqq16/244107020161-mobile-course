import 'package:flutter_test/flutter_test.dart';
import 'package:week2_responsive_dashboard/main.dart';

void main() {
  testWidgets('dashboard displays statistics', (tester) async {
    await tester.pumpWidget(const DashboardApp());
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('92%'), findsOneWidget);
  });
}
