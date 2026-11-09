import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'user_profile.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _profileKey = 'user_profile';

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<String?> readAccess() => _storage.read(key: _accessKey);
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  Future<void> saveProfile(UserProfile profile) =>
      _storage.write(key: _profileKey, value: jsonEncode(profile.toJson()));

  Future<UserProfile?> readProfile() async {
    final raw = await _storage.read(key: _profileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return UserProfile.fromJson(decoded);
    } catch (_) {
      
    }
    return null;
  }

  Future<void> clear() => _storage.deleteAll();
}
