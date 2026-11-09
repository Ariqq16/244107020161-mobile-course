import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class AddAnnouncement {
  const AddAnnouncement(this.repository);
  final AnnouncementRepository repository;

  Future<void> call(Announcement value) => repository.add(value);
}
