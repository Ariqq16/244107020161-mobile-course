/// Semua path rute di satu tempat, dipakai GoRouter dan penanganan klik notifikasi.
class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const notificationPattern = '/notifikasi/:id';

  /// ID dari FCM bisa mengandung karakter seperti ':' atau '%', jadi di-encode.
  static String notification(String id) =>
      '/notifikasi/${Uri.encodeComponent(id)}';
}
