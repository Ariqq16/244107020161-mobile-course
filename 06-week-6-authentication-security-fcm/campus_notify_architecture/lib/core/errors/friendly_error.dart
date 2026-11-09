import 'package:dio/dio.dart';

/// Mengubah exception teknis menjadi pesan yang bisa dibaca pengguna.
String friendlyError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 400) {
          return 'Permintaan ditolak (400). Periksa username dan password Anda.';
        }
        if (code == 401 || code == 403) {
          return 'Sesi tidak valid ($code). Silakan masuk lagi.';
        }
        if (code == 404) return 'Data tidak ditemukan (404).';
        return 'Server bermasalah ($code). Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  if (error is FormatException) {
    return 'Respons server tidak sesuai format yang diharapkan.';
  }
  return 'Terjadi kesalahan tak terduga.';
}
