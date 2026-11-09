import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/notification_item.dart';
import '../notifications/notifications_provider.dart';

class NotificationDetailPage extends ConsumerStatefulWidget {
  const NotificationDetailPage({required this.id, super.key});

  final String id;

  @override
  ConsumerState<NotificationDetailPage> createState() =>
      _NotificationDetailPageState();
}

class _NotificationDetailPageState
    extends ConsumerState<NotificationDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).markRead(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(notificationsProvider);
    NotificationItem? item;
    for (final n in all) {
      if (n.id == widget.id) {
        item = n;
        break;
      }
    }
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: item == null
          ? const Center(child: Text('Notifikasi tidak ditemukan.'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(item.timeLabel, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 20),
                  Text(item.body, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
    );
  }
}
