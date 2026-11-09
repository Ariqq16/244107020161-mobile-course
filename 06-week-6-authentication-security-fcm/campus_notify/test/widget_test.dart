import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/app.dart';
import 'package:campus_notify/data/user_profile.dart';
import 'package:campus_notify/providers/auth_provider.dart';

class _UnauthenticatedNotifier extends AuthNotifier {
  @override
  Future<UserProfile?> build() async => null;
}

void main() {
  testWidgets('CampusApp menampilkan halaman login saat belum terautentikasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_UnauthenticatedNotifier.new),
        ],
        child: const CampusApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.textContaining('Masuk untuk menerima pengumuman kampus'),
      findsOneWidget,
    );
  });
}
