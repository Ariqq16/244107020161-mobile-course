import '../repositories/announcement_repository.dart';

class MarkAnnouncementRead {
  const MarkAnnouncementRead(this.repository);
  final AnnouncementRepository repository;

  Future<void> call(String id) => repository.markRead(id);
}
