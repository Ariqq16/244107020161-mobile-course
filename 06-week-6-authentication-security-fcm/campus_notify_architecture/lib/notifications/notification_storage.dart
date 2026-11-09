import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'notification_item.dart';

/// Penyimpanan daftar notifikasi. Dibuat abstrak agar bisa diganti versi
/// palsu (in-memory) saat testing.
abstract class NotificationStorage {
  Future<List<NotificationItem>> load();
  Future<void> save(List<NotificationItem> items);

  /// Menambah satu item (dipakai handler background di isolate terpisah).
  Future<void> append(NotificationItem item);
}

/// Memakai SharedPreferencesAsync, yang aman dipakai dari lebih dari satu
/// isolate (UI dan background handler FCM) karena tidak memakai cache lokal.
class PrefsNotificationStorage implements NotificationStorage {
  PrefsNotificationStorage() : _prefs = SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;
  static const _key = 'notifications_v1';

  @override
  Future<List<NotificationItem>> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(NotificationItem.fromJson)
          .where((n) => n.id.isNotEmpty)
          .toList();
    } catch (_) {
      return []; // data rusak: mulai dari kosong
    }
  }

  @override
  Future<void> save(List<NotificationItem> items) async {
    await _prefs.setString(
      _key,
      jsonEncode(items.map((n) => n.toJson()).toList()),
    );
  }

  @override
  Future<void> append(NotificationItem item) async {
    final items = await load();
    if (items.any((n) => n.id == item.id)) return;
    await save(mergeNotifications(items, [item]));
  }
}
