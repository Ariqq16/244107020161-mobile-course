import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/routes.dart';
import '../../domain/entities/announcement.dart';
import 'fcm_background_handler.dart';
import 'local_notifier.dart';

bool firebaseReady = false;

class FcmService {
  FcmService({
    required this.onAnnouncement,
    required this.onTokenChanged,
  });

  final Future<void> Function(Announcement item) onAnnouncement;
  final void Function(String? token) onTokenChanged;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _started = false;
  int _simulationCount = 0;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await LocalNotifier.requestPermission();
    final launch = await LocalNotifier.launchPayload();
    if (launch != null && launch.isNotEmpty) {
      LocalNotifier.tappedRoute.value = AppRoutes.notification(launch);
    }
    if (!firebaseReady) {
      debugPrint('FCM dilewati: Firebase belum dikonfigurasi.');
      return;
    }
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      onTokenChanged(await messaging.getToken());
      _subscriptions.add(
        messaging.onTokenRefresh.listen(onTokenChanged),
      );
      await messaging.subscribeToTopic(kTopic);
      _subscriptions.add(FirebaseMessaging.onMessage.listen(_onForeground));
      _subscriptions.add(
        FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage),
      );
      final initial = await messaging.getInitialMessage();
      if (initial != null) await _openFromMessage(initial);
    } catch (error) {
      debugPrint('Gagal menyiapkan FCM: $error');
    }
  }

  Future<void> _onForeground(RemoteMessage message) async {
    final item = announcementFromRemote(message);
    await onAnnouncement(item);
    await LocalNotifier.showItem(item);
  }

  Future<void> _openFromMessage(RemoteMessage message) async {
    final item = announcementFromRemote(message);
    await onAnnouncement(item);
    LocalNotifier.tappedRoute.value = AppRoutes.notification(item.id);
  }

  Future<void> simulateIncoming() async {
    _simulationCount++;
    final item = Announcement(
      id: 'sim-${DateTime.now().microsecondsSinceEpoch}',
      title: 'Pengumuman uji #$_simulationCount',
      body: 'Ini notifikasi uji lokal. Ketuk untuk membaca, maka ia hilang dari daftar.',
      receivedAt: DateTime.now(),
    );
    await onAnnouncement(item);
    await LocalNotifier.showItem(item);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
