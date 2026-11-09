import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/routes.dart';
import '../../domain/entities/announcement.dart';

/// SEMUA pemanggilan flutter_local_notifications ada di file ini.
///
/// Ditulis untuk flutter_local_notifications ^19 (initialize dan show memakai
/// parameter posisi). Jika Anda memakai versi 20 ke atas, cukup sesuaikan tiga
/// panggilan: `initialize(...)`, `show(...)`, dan `getNotificationAppLaunchDetails()`
/// mengikuti README/changelog paketnya.
class LocalNotifier {
  LocalNotifier._();

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  /// Diisi saat notifikasi diketuk. Root app mendengarkan nilai ini lalu
  /// membuka halaman detailnya.
  static final ValueNotifier<String?> tappedRoute = ValueNotifier<String?>(null);

  static bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    kChannelId,
    kChannelName,
    description: kChannelDescription,
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(kSoundResource),
    enableVibration: true,
  );

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      kChannelId,
      kChannelName,
      channelDescription: kChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(kSoundResource),
      enableVibration: true,
    ),
  );

  static Future<void> init({bool handleTaps = true}) async {
    if (_initialized) return;
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: handleTaps
          ? (NotificationResponse response) {
              final payload = response.payload;
              if (payload != null && payload.isNotEmpty) {
                tappedRoute.value = AppRoutes.notification(payload);
              }
            }
          : null,
    );
    _initialized = true;
  }

  /// Membuat channel bersuara (Android 8+). Aman dipanggil berulang.
  static Future<void> createChannel() async {
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
  }

  /// Izin notifikasi runtime untuk Android 13+.
  static Future<void> requestPermission() async {
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  /// Menampilkan banner + suara untuk [item]. Payload = id item.
  static Future<void> showItem(Announcement item) async {
    await plugin.show(
      item.id.hashCode & 0x7fffffff,
      item.title,
      item.body,
      _details,
      payload: item.id,
    );
  }

  /// Payload jika app dibuka dari keadaan mati lewat ketukan notifikasi lokal.
  static Future<String?> launchPayload() async {
    final details = await plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }
}
