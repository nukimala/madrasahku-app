import '../models/siswa_model.dart';
import 'api_client.dart';

class KelasOption {
  final int id;
  final String name;
  final int level;

  const KelasOption({
    required this.id,
    required this.name,
    required this.level,
  });

  factory KelasOption.fromJson(Map<String, dynamic> j) => KelasOption(
        id: j['id'] is int ? j['id'] as int : int.tryParse(j['id']?.toString() ?? '') ?? 0,
        name: (j['name'] ?? j['nama_kelas'] ?? '').toString(),
        level: j['level'] is int ? j['level'] as int : int.tryParse(j['level']?.toString() ?? '') ?? 7,
      );
}

class SiswaService {
  Future<List<SiswaItem>> fetchAll({String? keyword, int? kelasId}) async {
    final queryParams = <String, String>{};
    if (keyword != null && keyword.trim().isNotEmpty) {
      queryParams['q'] = keyword.trim();
    }
    if (kelasId != null && kelasId > 0) {
      queryParams['kelas_id'] = kelasId.toString();
    }

    final res = await ApiClient.instance.get(
      '/siswa',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal memuat data siswa');
    }

    final data = res.data;
    if (data is List) {
      return data
          .map((e) => SiswaItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else if (data is Map && data['siswa'] is List) {
      return (data['siswa'] as List)
          .map((e) => SiswaItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  Future<SiswaItem> create(SiswaItem s) async {
    final res = await ApiClient.instance.post('/siswa', body: s.toJson());
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal menambahkan data siswa');
    }
    if (res.data is Map) {
      return SiswaItem.fromJson(Map<String, dynamic>.from(res.data as Map));
    }
    return s;
  }

  Future<SiswaItem> update(int id, SiswaItem s) async {
    final res = await ApiClient.instance.put('/siswa/$id', body: s.toJson());
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal memperbarui data siswa');
    }
    if (res.data is Map) {
      return SiswaItem.fromJson(Map<String, dynamic>.from(res.data as Map));
    }
    return s;
  }

  Future<void> delete(int id) async {
    final res = await ApiClient.instance.delete('/siswa/$id');
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal menghapus data siswa');
    }
  }

  Future<List<KelasOption>> fetchKelas() async {
    try {
      final res = await ApiClient.instance.get('/kelas');
      if (!res.success) {
        return _fallbackKelas;
      }
      final data = res.data;
      if (data is List) {
        final list = data
            .map((e) => KelasOption.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return list.isNotEmpty ? list : _fallbackKelas;
      }
      return _fallbackKelas;
    } catch (_) {
      return _fallbackKelas;
    }
  }

  static const List<KelasOption> _fallbackKelas = [
    KelasOption(id: 1, name: 'VII A', level: 7),
    KelasOption(id: 2, name: 'VII B', level: 7),
    KelasOption(id: 3, name: 'VIII A', level: 8),
    KelasOption(id: 4, name: 'VIII B', level: 8),
    KelasOption(id: 5, name: 'IX A', level: 9),
    KelasOption(id: 6, name: 'IX B', level: 9),
  ];
}
