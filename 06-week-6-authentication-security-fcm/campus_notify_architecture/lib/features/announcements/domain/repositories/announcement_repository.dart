import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<List<Announcement>> getAll();
  Future<void> add(Announcement announcement);
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> reload();
}
