/// Konfigurasi terpusat. Ganti nilai di sini jika API dari dosen berbeda.
///
/// Default memakai DummyJSON (https://dummyjson.com/docs/auth):
///   POST /auth/login   -> accessToken + refreshToken + profil user
///   POST /auth/refresh -> accessToken baru
///   GET  /auth/me      -> profil user (butuh header Bearer)
const String kApiBaseUrl = 'https://dummyjson.com';

/// Umur access token (menit) yang diminta saat login/refresh.
const int kAccessTokenMinutes = 30;

/// Akun demo DummyJSON (hanya untuk mengisi form otomatis).
const String kDemoUsername = 'emilys';
const String kDemoPassword = 'emilyspass';

/// Topik FCM untuk broadcast pengumuman kampus.
const String kTopic = 'pengumuman-kampus';

/// Channel notifikasi Android (bersuara). Suara channel tidak bisa diubah
/// setelah dibuat, jadi naikkan versi id (v2, v3, ...) jika ingin ganti suara.
const String kChannelId = 'campus_alerts_v1';
const String kChannelName = 'Pengumuman Kampus';
const String kChannelDescription = 'Notifikasi pengumuman kampus (bersuara)';

/// Nama file suara di android/app/src/main/res/raw (tanpa ekstensi).
const String kSoundResource = 'notif_sound';
