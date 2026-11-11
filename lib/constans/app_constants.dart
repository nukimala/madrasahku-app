class AppConstants {
  // URL Server Online (Production)
  static const String liveUrl = 'https://mts-alhuda.shulkhimaulana.my.id/api/v1';

  // URL Server Lokal (Laragon / LAN)
  // Ganti IP dengan IP komputer jika diuji via HP di WiFi yang sama
  static const String localUrl = 'http://192.168.1.100/mts-alhuda-website/api/v1';

  // Base URL aktif
  static const String baseUrl = liveUrl;

  // Timeout koneksi
  static const Duration connectTimeout = Duration(seconds: 15);
}
