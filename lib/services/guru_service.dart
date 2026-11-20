import '../models/guru_model.dart';
import 'api_client.dart';

class GuruService {
  Future<List<GuruItem>> fetchAll({String? keyword, String? mapel}) async {
    final queryParams = <String, String>{};
    if (keyword != null && keyword.trim().isNotEmpty) {
      queryParams['q'] = keyword.trim();
    }
    if (mapel != null && mapel.trim().isNotEmpty) {
      queryParams['bidang_studi'] = mapel.trim();
    }

    final res = await ApiClient.instance.get(
      '/guru',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal memuat data guru');
    }

    final data = res.data;
    if (data is List) {
      return data
          .map((e) => GuruItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else if (data is Map && data['guru'] is List) {
      return (data['guru'] as List)
          .map((e) => GuruItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  Future<GuruItem> create(GuruItem g) async {
    final res = await ApiClient.instance.post('/guru', body: g.toJson());
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal menambahkan data guru');
    }
    if (res.data is Map) {
      return GuruItem.fromJson(Map<String, dynamic>.from(res.data as Map));
    }
    return g;
  }

  Future<GuruItem> update(int id, GuruItem g) async {
    final res = await ApiClient.instance.put('/guru/$id', body: g.toJson());
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal memperbarui data guru');
    }
    if (res.data is Map) {
      return GuruItem.fromJson(Map<String, dynamic>.from(res.data as Map));
    }
    return g;
  }

  Future<void> delete(int id) async {
    final res = await ApiClient.instance.delete('/guru/$id');
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal menghapus data guru');
    }
  }

  Future<List<String>> fetchMapel() async {
    try {
      final res = await ApiClient.instance.get('/mata-pelajaran');
      if (!res.success) {
        return _fallbackMapel;
      }
      final data = res.data;
      if (data is List) {
        final list = data
            .map((e) => ((e is Map ? (e['name'] ?? e['nama_mapel']) : e) ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toList();
        return list.isNotEmpty ? list : _fallbackMapel;
      }
      return _fallbackMapel;
    } catch (_) {
      return _fallbackMapel;
    }
  }

  static const List<String> _fallbackMapel = [
    'Matematika',
    'Bahasa Indonesia',
    'Bahasa Inggris',
    'IPA',
    'IPS',
    'PAI',
    'Al-Qur\'an Hadis',
    'Akidah Akhlak',
    'Fikih',
    'SKI',
    'Bahasa Arab',
    'PJOK',
    'Seni Budaya',
    'Prakarya',
    'Informatika',
  ];
}
