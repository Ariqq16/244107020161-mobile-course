import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config.dart';
import '../routes.dart';
import 'notification_item.dart';

class LocalNotifier {
  LocalNotifier._();

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static final ValueNotifier<String?> tappedRoute = ValueNotifier<String?>(
    null,
  );

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
      settings: const InitializationSettings(
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

  static Future<void> createChannel() async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_channel);
  }

  static Future<void> requestPermission() async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
  }

  static Future<void> showItem(NotificationItem item) async {
    await plugin.show(
      id: item.id.hashCode & 0x7fffffff,
      title: item.title,
      body: item.body,
      notificationDetails: _details,
      payload: item.id,
    );
  }

  static Future<String?> launchPayload() async {
    final details = await plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }
}
