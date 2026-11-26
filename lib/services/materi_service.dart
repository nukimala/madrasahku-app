import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'auth_service.dart';
import '../models/materi_model.dart';

class MateriService {
  MateriService._();
  static final MateriService instance = MateriService._();

  String get _completedKey {
    final user = AuthService.instance.adminProfile.username;
    return 'completed_materials_${user.isNotEmpty ? user : 'default'}';
  }

  Future<Set<int>> ambilMateriSelesai() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_completedKey) ?? const [];
      return list.map((e) => int.tryParse(e)).whereType<int>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> tandaiMateriSelesai(int materialId) async {
    if (materialId <= 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await ambilMateriSelesai();
      current.add(materialId);
      await prefs.setStringList(
        _completedKey,
        current.map((e) => e.toString()).toList(),
      );
    } catch (_) {}
  }

  Future<List<MateriItem>> ambilDaftarMateri({int? classId, int? classSubjectId}) async {
    final params = <String, String>{};
    if (classId != null && classId > 0) {
      params['class_id'] = classId.toString();
    }
    if (classSubjectId != null && classSubjectId > 0) {
      params['class_subject_id'] = classSubjectId.toString();
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

  Future<List<Map<String, dynamic>>> ambilTopikGuru(int classSubjectId) async {
    final res = await ApiClient.instance.get(
      '/teacher/topics',
      queryParams: {'class_subject_id': classSubjectId.toString()},
    );
    if (res.success && res.data is Map && res.data['topics'] is List) {
      return (res.data['topics'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> buatTopik({
    required int classSubjectId,
    required int minggu,
    required String nama,
    String? deskripsi,
  }) async {
    final res = await ApiClient.instance.post(
      '/teacher/topics',
      body: {
        'class_subject_id': classSubjectId,
        'minggu': minggu,
        'nama': nama,
        if (deskripsi != null && deskripsi.isNotEmpty) 'deskripsi': deskripsi,
      },
    );
    return {
      'success': res.success,
      'data': res.success ? res.data : null,
      'message': res.success
          ? 'Topik berhasil disimpan'
          : (res.errorMessage ?? 'Gagal menyimpan topik'),
    };
  }

  /// Buat materi baru (guru) - POST /teacher/materials atau /materials
  Future<Map<String, dynamic>> buatMateri({
    required int classSubjectId,
    required String title,
    required String description,
    int? topikId,
    String? fileUrl,
    String? filePath,
  }) async {
    final res = (filePath != null && filePath.isNotEmpty)
        ? await ApiClient.instance.postMultipart(
            '/teacher/materials',
            fields: {
              'class_subject_id': classSubjectId.toString(),
              if (topikId != null && topikId > 0) 'topik_id': topikId.toString(),
              'title': title,
              'description': description,
            },
            fileField: 'file',
            filePath: filePath,
          )
        : await ApiClient.instance.post(
            '/teacher/materials',
            body: {
              'class_subject_id': classSubjectId,
              if (topikId != null && topikId > 0) 'topik_id': topikId,
              'title': title,
              'description': description,
              if (fileUrl != null && fileUrl.isNotEmpty) 'file_url': fileUrl,
            },
          );
    return {
      'success': res.success,
      'data': res.success ? res.data : null,
      'message': res.success
          ? 'Materi berhasil dibuat'
          : (res.errorMessage ?? 'Gagal membuat materi'),
    };
  }

  /// Update materi (guru) - PUT /teacher/materials/{id} atau /materials/{id}
  Future<Map<String, dynamic>> updateMateri({
    required int materialId,
    required String title,
    required String description,
    String? fileUrl,
  }) async {
    var res = await ApiClient.instance.put(
      '/teacher/materials/$materialId',
      body: {
        'title': title,
        'description': description,
        if (fileUrl != null && fileUrl.isNotEmpty) 'file_url': fileUrl,
      },
    );
    if (!res.success) {
      // Fallback ke endpoint non-teacher
      res = await ApiClient.instance.put(
        '/materials/$materialId',
        body: {
          'title': title,
          'description': description,
          if (fileUrl != null && fileUrl.isNotEmpty) 'file_url': fileUrl,
        },
      );
    }
    return {
      'success': res.success,
      'message': res.success
          ? 'Materi berhasil diperbarui'
          : (res.errorMessage ?? 'Gagal memperbarui materi'),
    };
  }

  Future<Map<String, dynamic>> hapusTopik(int topicId) async {
    final res = await ApiClient.instance.delete('/teacher/topics/$topicId');
    return {
      'success': res.success,
      'message': res.success
          ? 'Topik berhasil dihapus'
          : (res.errorMessage ?? 'Gagal menghapus topik'),
    };
  }

  /// Hapus materi (guru) - DELETE /teacher/materials/{id} atau /materials/{id}
  Future<Map<String, dynamic>> hapusMateri(int materialId) async {
    var res = await ApiClient.instance.delete('/teacher/materials/$materialId');
    if (!res.success) {
      res = await ApiClient.instance.delete('/materials/$materialId');
    }
    return {
      'success': res.success,
      'message': res.success
          ? 'Materi berhasil dihapus'
          : (res.errorMessage ?? 'Gagal menghapus materi'),
    };
  }

  /// Daftar kelas dan mapel yang diampu guru yang sedang login
 
  Future<List<GuruKelasMapel>> ambilKelasMapelGuru() async {
    final res = await ApiClient.instance.get('/teacher/assignments');

    if (res.success) {
      final data = res.data;
      if (data is Map && data['assignments'] is List) {
        final list = (data['assignments'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => GuruKelasMapel.fromJson(e))
            .toList();
        // Debug log
        for (var item in list) {
          debugPrint('MateriService: assignment -> classSubjectId=${item.classSubjectId}, className=${item.className}, subjectName=${item.subjectName}');
        }
        return list;
      }
      return [];
    }

    if (res.statusCode != 404) {
      throw Exception(
        '${res.errorMessage ?? 'Gagal memuat kelas & mapel'} '
        '(kode ${res.statusCode})',
      );
    }

    // Fallback: try to get class_subject_id from another endpoint if available
    // For now, return empty list to force using real API data
    debugPrint('MateriService: /teacher/assignments returned 404, falling back to schedules (classSubjectId will be 0)');
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

      // Try to get class_subject_id from schedule if available
      final classSubjectId = _toInt(e['class_subject_id']) ?? _toInt(e['classSubjectId']) ?? 0;

      unik['$namaKelas|$namaMapel'] = GuruKelasMapel(
        classSubjectId: classSubjectId,
        classId: _toInt(kelas['id']) ?? 0,
        className: namaKelas,
        subjectId: _toInt(mapel['id']) ?? 0,
        subjectName: namaMapel,
      );
    }

    final hasil = unik.values.toList()
      ..sort((a, b) {
        final k = a.className.compareTo(b.className);
        return k != 0 ? k : a.subjectName.compareTo(b.subjectName);
      });

    debugPrint('MateriService: _dariJadwal returned ${hasil.length} items');
    for (var item in hasil) {
      debugPrint('MateriService: jadwal -> classSubjectId=${item.classSubjectId}, className=${item.className}, subjectName=${item.subjectName}');
    }

    return hasil;
  }

  static int? _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '');
}