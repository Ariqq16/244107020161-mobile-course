import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'notifications/local_notifier.dart';
import 'notifications/notifications_provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/notification_detail_page.dart';
import 'pages/splash_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final location = state.matchedLocation;

      if (auth.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }
      final loggedIn = auth.value != null;
      if (!loggedIn) {
        return location == AppRoutes.login ? null : AppRoutes.login;
      }
      if (location == AppRoutes.login || location == AppRoutes.splash) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.notificationPattern,
        builder: (_, state) =>
            NotificationDetailPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

class CampusApp extends ConsumerStatefulWidget {
  const CampusApp({super.key});

  @override
  ConsumerState<CampusApp> createState() => _CampusAppState();
}

class _CampusAppState extends ConsumerState<CampusApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocalNotifier.tappedRoute.addListener(_openTappedRoute);
  }

  @override
  void dispose() {
    LocalNotifier.tappedRoute.removeListener(_openTappedRoute);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationsProvider.notifier).reload();
    }
  }

  void _openTappedRoute() {
    final route = LocalNotifier.tappedRoute.value;
    if (route == null) return;
    if (ref.read(authStateProvider).value == null) return;
    LocalNotifier.tappedRoute.value = null;
    ref.read(routerProvider).push(route);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      if (next.value != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _openTappedRoute());
      }
    });

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
