import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config.dart';
import '../routes.dart';
import 'local_notifier.dart';
import 'notification_item.dart';
import 'notification_storage.dart';
import 'notifications_provider.dart';

/// true jika Firebase.initializeApp berhasil (diisi di main.dart).
bool firebaseReady = false;

/// Mengubah pesan FCM menjadi item daftar. Mendukung pesan `notification`
/// maupun pesan data-only (title/body diambil dari `data`).
NotificationItem itemFromRemote(RemoteMessage message) {
  return NotificationItem(
    id: message.messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
    title: message.notification?.title ??
        message.data['title']?.toString() ??
        'Pengumuman',
    body: message.notification?.body ?? message.data['body']?.toString() ?? '',
    receivedAt: message.sentTime ?? DateTime.now(),
  );
}

/// Handler pesan saat app di background / terminated.
/// WAJIB fungsi top-level dan berjalan di isolate terpisah, jadi tidak boleh
/// memakai BuildContext atau Riverpod di sini.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } on FirebaseException catch (error) {
    debugPrint('Firebase belum siap di background: $error');
    return;
  }
  final item = itemFromRemote(message);
  await PrefsNotificationStorage().append(item);

  // Pesan `notification` sudah ditampilkan sistem (suara dari channel default
  // di AndroidManifest). Pesan data-only tidak, jadi tampilkan manual.
  if (message.notification == null) {
    await LocalNotifier.init(handleTaps: false);
    await LocalNotifier.createChannel();
    await LocalNotifier.showItem(item);
  }
}

class FcmTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? token) => state = token;
}

/// Token FCM perangkat ini (jangan di-log atau di-screenshot penuh).
final fcmTokenProvider =
    NotifierProvider<FcmTokenNotifier, String?>(FcmTokenNotifier.new);

class PushController {
  PushController(this._ref);

  final Ref _ref;
  final List<StreamSubscription<dynamic>> _subs = [];
  bool _started = false;
  int _simulationCount = 0;

  NotificationsNotifier get _notifications =>
      _ref.read(notificationsProvider.notifier);

  /// Dipanggil sekali setelah login (dari HomePage). Idempoten.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    await LocalNotifier.requestPermission();

    // App dibuka dari mati lewat ketukan notifikasi lokal.
    final launch = await LocalNotifier.launchPayload();
    if (launch != null && launch.isNotEmpty) {
      LocalNotifier.tappedRoute.value = AppRoutes.notification(launch);
    }

    if (!firebaseReady) {
      debugPrint('FCM dilewati: Firebase belum dikonfigurasi.');
      return;
    }

    try {
      final fm = FirebaseMessaging.instance;
      await fm.requestPermission();

      // ignore: deprecated_member_use
      final token = await fm.getToken();
      _ref.read(fcmTokenProvider.notifier).set(token);
      // TODO(backend): kirim token ke server Anda (mis. POST /devices).

      // ignore: deprecated_member_use
      _subs.add(fm.onTokenRefresh.listen((newToken) {
        _ref.read(fcmTokenProvider.notifier).set(newToken);
        // TODO(backend): kirim token baru ke server Anda.
      }));

      await fm.subscribeToTopic(kTopic);

      _subs.add(FirebaseMessaging.onMessage.listen(_onForeground));
      _subs.add(FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage));

      // App dibuka dari mati lewat ketukan notifikasi FCM.
      final initial = await fm.getInitialMessage();
      if (initial != null) await _openFromMessage(initial);
    } catch (e) {
      debugPrint('Gagal menyiapkan FCM: $e');
    }
  }

  /// Foreground: sistem TIDAK menampilkan banner, jadi masukkan ke daftar
  /// dan tampilkan banner lokal (bersuara) secara manual.
  Future<void> _onForeground(RemoteMessage message) async {
    final item = itemFromRemote(message);
    await _notifications.add(item);
    await LocalNotifier.showItem(item);
  }

  /// Notifikasi diketuk dari background/terminated: pastikan masuk daftar
  /// lalu buka detailnya (halaman detail yang menandainya sudah dibaca).
  Future<void> _openFromMessage(RemoteMessage message) async {
    final item = itemFromRemote(message);
    await _notifications.add(item);
    LocalNotifier.tappedRoute.value = AppRoutes.notification(item.id);
  }

  /// Tombol uji: membuat notifikasi lokal tanpa Firebase. Berguna untuk
  /// mendemokan daftar, badge, dan suara.
  Future<void> simulateIncoming() async {
    _simulationCount++;
    final item = NotificationItem(
      id: 'sim-${DateTime.now().microsecondsSinceEpoch}',
      title: 'Pengumuman uji #$_simulationCount',
      body: 'Ini notifikasi uji lokal. Ketuk untuk membaca, maka ia hilang dari daftar.',
      receivedAt: DateTime.now(),
    );
    await _notifications.add(item);
    await LocalNotifier.showItem(item);
  }

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }
}

final pushControllerProvider = Provider<PushController>((ref) {
  final controller = PushController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});
