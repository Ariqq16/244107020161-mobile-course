import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/announcement_model.dart';

abstract class AnnouncementLocalDataSource {
  Future<List<AnnouncementModel>> load();
  Future<void> save(List<AnnouncementModel> items);
  Future<void> append(AnnouncementModel item);
}

class SharedPrefsAnnouncementDataSource
    implements AnnouncementLocalDataSource {
  SharedPrefsAnnouncementDataSource() : _prefs = SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;
  static const _key = 'notifications_v1';

  @override
  Future<List<AnnouncementModel>> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(AnnouncementModel.fromJson)
          .where((item) => item.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<AnnouncementModel> items) async {
    await _prefs.setString(
      _key,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<void> append(AnnouncementModel item) async {
    final items = await load();
    if (items.any((value) => value.id == item.id)) return;
    await save([...items, item]);
  }
}
