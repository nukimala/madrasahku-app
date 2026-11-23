import 'api_client.dart';
import '../models/materi_model.dart';

class MateriService {
  MateriService._();
  static final MateriService instance = MateriService._();

  Future<List<MateriItem>> ambilDaftarMateri({int? classId}) async {
    final params = <String, String>{};
    if (classId != null && classId > 0) {
      params['class_id'] = classId.toString();
    }

    final res = await ApiClient.instance.get(
      '/materials',
      queryParams: params.isNotEmpty ? params : null,
    );
    if (res.success && res.data != null && res.data['materials'] is List) {
      final list = res.data['materials'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => MateriItem.fromJson(e))
          .toList();
    }
    return [];
  }

  /// Daftar kelas dan mapel yang diampu guru yang sedang login
 
  Future<List<GuruKelasMapel>> ambilKelasMapelGuru() async {
    final res = await ApiClient.instance.get('/teacher/assignments');

    if (res.success) {
      final data = res.data;
      if (data is Map && data['assignments'] is List) {
        return (data['assignments'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => GuruKelasMapel.fromJson(e))
            .toList();
      }
      return [];
    }

    if (res.statusCode != 404) {
      throw Exception(
        '${res.errorMessage ?? 'Gagal memuat kelas & mapel'} '
        '(kode ${res.statusCode})',
      );
    }

    return _dariJadwal();
  }

  Future<List<GuruKelasMapel>> _dariJadwal() async {
    final res = await ApiClient.instance.get('/schedules');

    if (!res.success) {
      throw Exception(
        '${res.errorMessage ?? 'Gagal memuat jadwal'} '
        '(kode ${res.statusCode})',
      );
    }

    final data = res.data;
    if (data is! Map || data['schedules'] is! List) return [];

    final unik = <String, GuruKelasMapel>{};

    for (final e in (data['schedules'] as List).whereType<Map>()) {
      final kelas = e['class'];
      final mapel = e['subject'];
      if (kelas is! Map || mapel is! Map) continue;

      final namaKelas = (kelas['name'] ?? '').toString();
      final namaMapel = (mapel['name'] ?? '').toString();
      if (namaKelas.isEmpty || namaMapel.isEmpty) continue;

      unik['$namaKelas|$namaMapel'] = GuruKelasMapel(
        classSubjectId: 0,
        classId: int.tryParse(kelas['id'].toString()) ?? 0,
        className: namaKelas,
        subjectId: 0,
        subjectName: namaMapel,
      );
    }

    final hasil = unik.values.toList()
      ..sort((a, b) {
        final k = a.className.compareTo(b.className);
        return k != 0 ? k : a.subjectName.compareTo(b.subjectName);
      });

    return hasil;
  }
}