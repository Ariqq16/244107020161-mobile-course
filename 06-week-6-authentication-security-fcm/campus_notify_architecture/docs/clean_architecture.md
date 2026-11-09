# Refactoring Campus Notify ke Clean Architecture

## Ringkasan fitur yang dipertahankan

- Login menggunakan DummyJSON (`POST /auth/login`).
- Access token dan refresh token disimpan melalui `flutter_secure_storage`.
- Refresh token otomatis ketika endpoint terproteksi mengembalikan 401/403.
- Guard route: pengguna yang belum login diarahkan ke login.
- Inbox pengumuman/notifikasi lokal, badge jumlah belum dibaca, tandai dibaca, dan detail.
- Firebase Cloud Messaging untuk foreground, background, dan terminated.
- Notifikasi lokal dengan channel Android bersuara.
- Tombol Uji Notifikasi untuk demonstrasi tanpa mengirim FCM sungguhan.

## Pemetaan file lama ke struktur baru

| File lama | File/lokasi baru |
|---|---|
| `lib/config.dart` | `lib/core/config/app_config.dart` |
| `lib/data/api_errors.dart` | `lib/core/errors/friendly_error.dart` |
| `lib/data/user_profile.dart` | `features/auth/domain/entities/user.dart` + `data/models/user_model.dart` |
| `lib/data/auth_repository.dart` | `features/auth/data/datasources/auth_remote_data_source.dart` + `data/repositories/auth_repository_impl.dart` |
| `lib/data/token_store.dart` | `features/auth/data/datasources/token_local_data_source.dart` |
| `lib/data/api_client.dart` | Wiring Dio terautentikasi di `auth/presentation/providers/auth_providers.dart` |
| `lib/providers/auth_provider.dart` | `features/auth/presentation/providers/auth_providers.dart` |
| `lib/notifications/notification_item.dart` | `features/announcements/domain/entities/announcement.dart` + `data/models/announcement_model.dart` |
| `lib/notifications/notification_storage.dart` | `features/announcements/data/datasources/announcement_local_data_source.dart` |
| `lib/notifications/notifications_provider.dart` | `features/announcements/presentation/providers/announcement_providers.dart` |
| `lib/notifications/local_notifier.dart` | `features/announcements/data/services/local_notifier.dart` |
| `lib/notifications/push_controller.dart` | `features/announcements/data/services/fcm_service.dart` + `data/services/fcm_background_handler.dart`, DI provider di `presentation/providers/push_controller.dart` |
| `lib/pages/login_page.dart` | `features/auth/presentation/pages/login_page.dart` |
| `lib/pages/home_page.dart` | `features/announcements/presentation/pages/home_page.dart` |
| `lib/pages/notification_detail_page.dart` | `features/announcements/presentation/pages/announcement_detail_page.dart` |
| `lib/pages/splash_page.dart` | `features/auth/presentation/pages/splash_page.dart` |
| `lib/app.dart`, `lib/routes.dart` | `lib/app/app.dart`, `lib/app/routes.dart` |

## Aturan dependensi

- Presentation boleh mengenal Domain dan Flutter/Riverpod.
- Domain hanya Dart murni; tidak mengimpor Flutter, Dio, Firebase, atau SharedPreferences.
- Data mengimplementasikan kontrak Repository yang didefinisikan Domain.
- Widget tidak membuat Repository, Dio, atau storage secara langsung.
- Provider menjadi composition root / dependency injection.

## Catatan keputusan desain

1. Fitur inbox lama dinamai `announcements` karena secara fungsi merupakan daftar pengumuman kampus.
2. Use case dibuat untuk operasi utama (login, logout, mengambil pengumuman, menambah pengumuman, menandai dibaca). Tidak dibuat use case untuk setiap operasi kecil tanpa kebutuhan bisnis.
3. FCM dan local notification adalah detail infrastruktur, sehingga diletakkan di Data.
4. FCM background handler tetap fungsi top-level karena Firebase menjalankannya pada isolate terpisah.
5. `firebase_options.dart` tetap dihasilkan oleh `flutterfire configure` dan tidak disertakan dalam paket refactor ini.

## Verifikasi yang harus dijalankan di project asli

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Kemudian lakukan uji manual login, logout, inbox, badge, suara, serta FCM pada foreground/background/terminated.
