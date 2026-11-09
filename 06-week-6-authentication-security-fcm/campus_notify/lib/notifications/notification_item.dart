class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;

  /// true = sudah dibaca. Notifikasi yang sudah dibaca tidak tampil di daftar
  /// dan tidak dihitung di badge ikon.
  final bool read;

  NotificationItem copyWith({bool? read}) => NotificationItem(
        id: id,
        title: title,
        body: body,
        receivedAt: receivedAt,
        read: read ?? this.read,
      );

  /// Aman null: field yang hilang tidak membuat aplikasi crash.
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      receivedAt: DateTime.tryParse(json['receivedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      read: json['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
        'read': read,
      };

  /// Contoh: 02/11/2026 03:15
  String get timeLabel {
    String two(int n) => n.toString().padLeft(2, '0');
    final t = receivedAt.toLocal();
    return '${two(t.day)}/${two(t.month)}/${t.year} ${two(t.hour)}:${two(t.minute)}';
  }
}

/// Menggabungkan dua daftar berdasarkan id. Jika item ada di keduanya,
/// status `read` = salah satunya sudah dibaca. Hasil diurutkan terbaru dulu
/// dan dibatasi [max] item.
List<NotificationItem> mergeNotifications(
  List<NotificationItem> a,
  List<NotificationItem> b, {
  int max = 100,
}) {
  final map = <String, NotificationItem>{};
  for (final n in [...a, ...b]) {
    final existing = map[n.id];
    map[n.id] =
        existing == null ? n : existing.copyWith(read: existing.read || n.read);
  }
  final list = map.values.toList()
    ..sort((x, y) => y.receivedAt.compareTo(x.receivedAt));
  return list.length > max ? list.sublist(0, max) : list;
}
