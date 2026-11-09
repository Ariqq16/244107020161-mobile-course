import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/fcm_service.dart';
import 'announcement_providers.dart';

class FcmTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final fcmTokenProvider =
    NotifierProvider<FcmTokenNotifier, String?>(FcmTokenNotifier.new);

final pushControllerProvider = Provider<FcmService>((ref) {
  final service = FcmService(
    onAnnouncement: (item) =>
        ref.read(announcementsProvider.notifier).add(item),
    onTokenChanged: (token) => ref.read(fcmTokenProvider.notifier).set(token),
  );
  ref.onDispose(service.dispose);
  return service;
});
