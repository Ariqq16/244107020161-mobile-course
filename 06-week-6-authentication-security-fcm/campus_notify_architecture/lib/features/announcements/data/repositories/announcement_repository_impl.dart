import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_local_data_source.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl(this.local);
  final AnnouncementLocalDataSource local;

  @override
  Future<List<Announcement>> getAll() async {
    final values = await local.load();
    return values.map((item) => item.toEntity()).toList();
  }

  @override
  Future<void> add(Announcement announcement) async {
    final current = await local.load();
    if (current.any((item) => item.id == announcement.id)) return;
    final merged = mergeAnnouncements(
      current.map((item) => item.toEntity()).toList(),
      [announcement],
    );
    await local.save(
      merged.map(AnnouncementModel.fromEntity).toList(),
    );
  }

  @override
  Future<void> markRead(String id) async {
    final current = await local.load();
    await local.save([
      for (final item in current)
        if (item.id == id)
          AnnouncementModel.fromEntity(item.toEntity().copyWith(isRead: true))
        else
          item,
    ]);
  }

  @override
  Future<void> markAllRead() async {
    final current = await local.load();
    await local.save([
      for (final item in current)
        AnnouncementModel.fromEntity(item.toEntity().copyWith(isRead: true)),
    ]);
  }

  @override
  Future<void> reload() async {
    // SharedPreferencesAsync reads current persisted values, including writes
    // performed by the FCM background isolate.
    await local.load();
  }
}
