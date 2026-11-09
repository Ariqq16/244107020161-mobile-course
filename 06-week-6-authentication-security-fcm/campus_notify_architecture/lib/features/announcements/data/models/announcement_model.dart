import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    required super.receivedAt,
    super.isRead,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        receivedAt: DateTime.tryParse(json['receivedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        isRead: json['read'] as bool? ?? false,
      );

  factory AnnouncementModel.fromEntity(Announcement value) =>
      AnnouncementModel(
        id: value.id,
        title: value.title,
        body: value.body,
        receivedAt: value.receivedAt,
        isRead: value.isRead,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
        'read': isRead,
      };

  Announcement toEntity() => Announcement(
        id: id,
        title: title,
        body: body,
        receivedAt: receivedAt,
        isRead: isRead,
      );
}
