class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool isRead;

  Announcement copyWith({bool? isRead}) => Announcement(
        id: id,
        title: title,
        body: body,
        receivedAt: receivedAt,
        isRead: isRead ?? this.isRead,
      );

  String get timeLabel {
    String two(int n) => n.toString().padLeft(2, '0');
    final value = receivedAt.toLocal();
    return '${two(value.day)}/${two(value.month)}/${value.year} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}

List<Announcement> mergeAnnouncements(
  List<Announcement> first,
  List<Announcement> second, {
  int max = 100,
}) {
  final map = <String, Announcement>{};
  for (final item in [...first, ...second]) {
    final old = map[item.id];
    map[item.id] = old == null
        ? item
        : old.copyWith(isRead: old.isRead || item.isRead);
  }
  final result = map.values.toList()
    ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
  return result.length > max ? result.sublist(0, max) : result;
}
