import 'api_client.dart';

class KontenService {
  KontenService._();
  static final KontenService instance = KontenService._();

  /// Ambil berita madrasah
  Future<List<dynamic>> ambilBerita({int page = 1, int perPage = 10}) async {
    final res = await ApiClient.instance.get(
      '/posts',
      queryParams: {'page': page.toString(), 'per_page': perPage.toString()},
    );
    if (res.success && res.data != null && res.data['posts'] is List) {
      return res.data['posts'];
    }
    return [];
  }

  /// Ambil pengumuman madrasah
  Future<List<dynamic>> ambilPengumuman() async {
    final res = await ApiClient.instance.get('/announcements');
    if (res.success && res.data != null && res.data['announcements'] is List) {
      return res.data['announcements'];
    }
    return [];
  }

  /// Ambil agenda madrasah
  Future<List<dynamic>> ambilAgenda() async {
    final res = await ApiClient.instance.get('/agendas');
    if (res.success && res.data != null && res.data['agendas'] is List) {
      return res.data['agendas'];
    }
    return [];
  }

  /// Ambil fasilitas madrasah
  Future<List<dynamic>> ambilFasilitas() async {
    final res = await ApiClient.instance.get('/facilities');
    if (res.success && res.data != null && res.data['facilities'] is List) {
      return res.data['facilities'];
    }
    return [];
  }

  /// Ambil galeri kegiatan madrasah
  Future<List<dynamic>> ambilGaleri() async {
    final res = await ApiClient.instance.get('/galleries');
    if (res.success && res.data != null && res.data['galleries'] is List) {
      return res.data['galleries'];
    }
    return [];
  }
}
