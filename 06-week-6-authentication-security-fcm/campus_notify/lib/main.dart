import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'notifications/local_notifier.dart';
import 'notifications/push_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase belum siap: $e');
  }

  await LocalNotifier.init();
  await LocalNotifier.createChannel();

  runApp(const ProviderScope(child: CampusApp()));
}
