import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../firebase_options.dart';
import '../datasources/announcement_local_data_source.dart';
import '../models/announcement_model.dart';
import 'local_notifier.dart';

AnnouncementModel announcementFromRemote(RemoteMessage message) {
  return AnnouncementModel(
    id: message.messageId ??
        DateTime.now().microsecondsSinceEpoch.toString(),
    title: message.notification?.title ??
        message.data['title']?.toString() ??
        'Pengumuman',
    body: message.notification?.body ??
        message.data['body']?.toString() ??
        '',
    receivedAt: message.sentTime ?? DateTime.now(),
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final item = announcementFromRemote(message);
  await SharedPrefsAnnouncementDataSource().append(item);
  if (message.notification == null) {
    await LocalNotifier.init(handleTaps: false);
    await LocalNotifier.createChannel();
    await LocalNotifier.showItem(item);
  }
}
