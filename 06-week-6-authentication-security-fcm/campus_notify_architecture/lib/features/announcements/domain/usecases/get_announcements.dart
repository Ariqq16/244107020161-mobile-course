import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncements {
  const GetAnnouncements(this.repository);
  final AnnouncementRepository repository;

  Future<List<Announcement>> call() => repository.getAll();
}
