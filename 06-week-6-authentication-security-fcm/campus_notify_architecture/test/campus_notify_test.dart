import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/notifications/notification_item.dart';
import 'package:campus_notify/notifications/notification_storage.dart';
import 'package:campus_notify/notifications/notifications_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Penyimpanan palsu (in-memory): test tidak menyentuh SharedPreferences.
class FakeStorage implements NotificationStorage {
  List<NotificationItem> items = [];

  @override
  Future<List<NotificationItem>> load() async => List.of(items);

  @override
  Future<void> save(List<NotificationItem> list) async => items = List.of(list);

  @override
  Future<void> append(NotificationItem item) async {
    if (!items.any((n) => n.id == item.id)) items = [...items, item];
  }
}

NotificationItem makeItem(String id) => NotificationItem(
      id: id,
      title: 'Judul $id',
      body: 'Isi $id',
      receivedAt: DateTime(2026, 11, 2, 3, 0),
    );

ProviderContainer makeContainer(FakeStorage storage) {
  final container = ProviderContainer(overrides: [
    notificationStorageProvider.overrideWithValue(storage),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('NotificationItem.fromJson aman terhadap field yang hilang', () {
    final item = NotificationItem.fromJson({'id': 'x'});
    expect(item.id, 'x');
    expect(item.title, '');
    expect(item.read, isFalse);
  });

  test('notifikasi masuk list, badge naik; dibaca -> hilang dari list', () async {
    final container = makeContainer(FakeStorage());
    final notifier = container.read(notificationsProvider.notifier);
    await Future<void>.delayed(Duration.zero); // biarkan reload awal selesai

    await notifier.add(makeItem('a'));
    await notifier.add(makeItem('b'));
    expect(container.read(unreadCountProvider), 2);

    await notifier.markRead('a');
    expect(container.read(unreadCountProvider), 1);
    expect(container.read(unreadNotificationsProvider).single.id, 'b');
    // Tetap ada di data lengkap (dipakai halaman detail).
    expect(container.read(notificationsProvider).length, 2);
  });

  test('id yang sama tidak ditambahkan dua kali', () async {
    final container = makeContainer(FakeStorage());
    final notifier = container.read(notificationsProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await notifier.add(makeItem('a'));
    await notifier.add(makeItem('a'));
    expect(container.read(notificationsProvider).length, 1);
  });

  test('friendlyError memetakan error jaringan dan login salah', () {
    final offline = DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      type: DioExceptionType.connectionError,
    );
    expect(friendlyError(offline), contains('terhubung'));

    final wrong = DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 400,
      ),
    );
    expect(friendlyError(wrong), contains('400'));
  });
}
