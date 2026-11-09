import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/friendly_error.dart';
import '../providers/announcement_providers.dart';
import '../providers/push_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/routes.dart';

/// Layar utama:
///  - Tugas 2: daftar notifikasi belum dibaca (hilang setelah dibaca)
///  - Tugas 3: badge angka di ikon lonceng
///  - Tugas 4: suara ada di channel notifikasi (lihat local_notifier.dart)
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Mulai FCM setelah login (izin notifikasi, token, listener).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pushControllerProvider).start();
    });
  }

  Future<void> _copyToken() async {
    final token = ref.read(fcmTokenProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (token == null || token.isEmpty) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Token FCM belum tersedia. Cek Firebase dan izin notifikasi.'),
      ));
      return;
    }
    await Clipboard.setData(ClipboardData(text: token));
    final preview = token.length > 12 ? '${token.substring(0, 12)}...' : token;
    messenger.showSnackBar(SnackBar(
      content: Text('Token disalin ($preview). Jangan dibagikan atau di-screenshot penuh.'),
    ));
  }

  void _showSummary(int count) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                count == 0
                    ? 'Tidak ada notifikasi baru'
                    : '$count notifikasi belum dibaca',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: count == 0
                    ? null
                    : () {
                        ref.read(announcementsProvider.notifier).markAllRead();
                        Navigator.of(sheetContext).pop();
                      },
                icon: const Icon(Icons.done_all),
                label: const Text('Tandai semua dibaca'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadAnnouncementsProvider);
    final count = unread.length;
    final profile = ref.watch(authStateProvider).value;
    final me = ref.watch(meProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Kampus'),
        actions: [
          IconButton(
            tooltip: 'Notifikasi belum dibaca: $count',
            onPressed: () => _showSummary(count),
            icon: Badge(
              label: Text(count > 99 ? '99+' : '$count'),
              isLabelVisible: count > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'token') _copyToken();
              if (value == 'logout') {
                ref.read(authStateProvider.notifier).logout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'token', child: Text('Salin token FCM')),
              PopupMenuItem(value: 'logout', child: Text('Keluar')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.read(pushControllerProvider).simulateIncoming(),
        icon: const Icon(Icons.add_alert),
        label: const Text('Uji notifikasi'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('Halo, ${profile?.displayName ?? '-'}'),
              subtitle: Text(me.when(
                data: (u) => 'Sesi aktif • ${u.email}',
                loading: () => 'Memeriksa sesi...',
                error: (e, _) => friendlyError(e),
              )),
            ),
          ),
          Expanded(
            child: unread.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Belum ada notifikasi baru.\nTekan "Uji notifikasi" atau kirim dari Firebase.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: unread.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = unread[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        background: Container(
                          color: theme.colorScheme.primaryContainer,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.done),
                        ),
                        onDismissed: (_) => ref
                            .read(announcementsProvider.notifier)
                            .markRead(item.id),
                        child: ListTile(
                          leading: const Icon(Icons.mark_email_unread_outlined),
                          title: Text(item.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(item.body,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Text(item.timeLabel,
                              style: theme.textTheme.bodySmall),
                          // Halaman detail menandai notifikasi sebagai dibaca,
                          // sehingga ia hilang dari daftar ini.
                          onTap: () =>
                              context.push(AppRoutes.notification(item.id)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
