import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_item.dart';
import 'notification_storage.dart';

final notificationStorageProvider = Provider<NotificationStorage>(
  (ref) => PrefsNotificationStorage(),
);

/// Semua notifikasi (sudah dibaca maupun belum). State selalu dibuat list baru
/// (immutable) agar Riverpod mendeteksi perubahan.
class NotificationsNotifier extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() {
    Future.microtask(reload);
    return const [];
  }

  NotificationStorage get _storage => ref.read(notificationStorageProvider);

  /// Muat dari penyimpanan lalu gabungkan dengan state saat ini. Dipanggil saat
  /// start dan saat app kembali ke foreground, karena handler background FCM
  /// menulis ke penyimpanan dari isolate lain.
  Future<void> reload() async {
    final stored = await _storage.load();
    state = mergeNotifications(state, stored);
  }

  Future<void> add(NotificationItem item) async {
    if (state.any((n) => n.id == item.id)) return;
    state = mergeNotifications(state, [item]);
    await _persist();
  }

  /// Tandai sudah dibaca -> hilang dari daftar dan badge.
  Future<void> markRead(String id) async {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(read: true) else n,
    ];
    await _persist();
  }

  Future<void> markAllRead() async {
    state = [for (final n in state) n.copyWith(read: true)];
    await _persist();
  }

  Future<void> _persist() async {
    // Gabung dulu dengan isi penyimpanan supaya item yang ditulis handler
    // background tidak tertimpa.
    final stored = await _storage.load();
    state = mergeNotifications(state, stored);
    await _storage.save(state);
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<NotificationItem>>(
  NotificationsNotifier.new,
);

/// Hanya yang belum dibaca. Inilah isi daftar di layar utama.
final unreadNotificationsProvider = Provider<List<NotificationItem>>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.read).toList();
});

/// Angka pada badge ikon lonceng.
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(unreadNotificationsProvider).length;
});
