import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/announcement_local_data_source.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/add_announcement.dart';
import '../../domain/usecases/get_announcements.dart';
import '../../domain/usecases/mark_announcement_read.dart';

final announcementLocalDataSourceProvider =
    Provider<AnnouncementLocalDataSource>(
  (ref) => SharedPrefsAnnouncementDataSource(),
);
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(
    ref.watch(announcementLocalDataSourceProvider),
  );
});
final getAnnouncementsUseCaseProvider = Provider(
  (ref) => GetAnnouncements(ref.watch(announcementRepositoryProvider)),
);
final addAnnouncementUseCaseProvider = Provider(
  (ref) => AddAnnouncement(ref.watch(announcementRepositoryProvider)),
);
final markAnnouncementReadUseCaseProvider = Provider(
  (ref) => MarkAnnouncementRead(ref.watch(announcementRepositoryProvider)),
);

class AnnouncementsNotifier extends AsyncNotifier<List<Announcement>> {
  @override
  Future<List<Announcement>> build() =>
      ref.read(getAnnouncementsUseCaseProvider)();

  Future<void> reload() async {
    await ref.read(announcementRepositoryProvider).reload();
    state = AsyncData(await ref.read(getAnnouncementsUseCaseProvider)());
  }

  Future<void> add(Announcement item) async {
    await ref.read(addAnnouncementUseCaseProvider)(item);
    state = AsyncData(await ref.read(getAnnouncementsUseCaseProvider)());
  }

  Future<void> markRead(String id) async {
    await ref.read(announcementRepositoryProvider).markRead(id);
    state = AsyncData(await ref.read(getAnnouncementsUseCaseProvider)());
  }

  Future<void> markAllRead() async {
    await ref.read(announcementRepositoryProvider).markAllRead();
    state = AsyncData(await ref.read(getAnnouncementsUseCaseProvider)());
  }
}

final announcementsProvider =
    AsyncNotifierProvider<AnnouncementsNotifier, List<Announcement>>(
  AnnouncementsNotifier.new,
);

final unreadAnnouncementsProvider = Provider<List<Announcement>>((ref) {
  return ref.watch(announcementsProvider).maybeWhen(
        data: (items) => items.where((item) => !item.isRead).toList(),
        orElse: () => const [],
      );
});
final unreadAnnouncementCountProvider = Provider<int>(
  (ref) => ref.watch(unreadAnnouncementsProvider).length,
);
