import 'api_client.dart';
import '../models/tugas_model.dart';
import '../models/siswa_model.dart';
import 'siswa_service.dart';

class TugasService {
  TugasService._();
  static final TugasService instance = TugasService._();

  // Ambil daftar tugas dari server API `/assignments`
  Future<List<TugasItem>> ambilDaftarTugas({int? classId, int? classSubjectId}) async {
    final params = <String, String>{};
    if (classId != null && classId > 0) {
      params['class_id'] = classId.toString();
    }
    if (classSubjectId != null && classSubjectId > 0) {
      params['class_subject_id'] = classSubjectId.toString();
    }

    final res = await ApiClient.instance.get('/assignments', queryParams: params.isNotEmpty ? params : null);
    if (res.success && res.data != null && res.data['assignments'] is List) {
      final list = res.data['assignments'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => TugasItem.fromJson(e))
          .toList();
    }
    return [];
  }

  /// Ambil detail pengumpulan tugas untuk Guru (semua siswa di kelas + status submit)
  /// GET /assignments/{id}/submissions atau /teacher/assignments/{id}/submissions
  Future<Map<String, dynamic>> ambilDetailPengumpulanTugas(int assignmentId) async {
    // Coba endpoint teacher dulu, fallback ke assignments
    var res = await ApiClient.instance.get('/teacher/assignments/$assignmentId/submissions');
    if (!res.success) {
      res = await ApiClient.instance.get('/assignments/$assignmentId/submissions');
    }
    
    if (res.success && res.data != null) {
      return {
        'success': true,
        'data': res.data,
      };
    }
    return {
      'success': false,
      'message': res.errorMessage ?? 'Gagal memuat data pengumpulan tugas',
    };
  }

  /// Buat tugas baru (guru) - POST /teacher/assignments atau /assignments
  Future<Map<String, dynamic>> buatTugas({
    required int classSubjectId,
    required String title,
    required String description,
    required DateTime deadline,
    int? topikId,
    String? fileUrl,
    String? filePath,
  }) async {
    // Format deadline ke YYYY-MM-DD HH:MM:SS atau ISO8601
    final deadlineStr = deadline.toIso8601String();

    var res = (filePath != null && filePath.isNotEmpty)
        ? await ApiClient.instance.postMultipart(
            '/teacher/assignments',
            fields: {
              'class_subject_id': classSubjectId.toString(),
              if (topikId != null && topikId > 0) 'topik_id': topikId.toString(),
              'title': title,
              'description': description,
              'deadline': deadlineStr,
            },
            fileField: 'file',
            filePath: filePath,
          )
        : await ApiClient.instance.post(
            '/teacher/assignments',
            body: {
              'class_subject_id': classSubjectId,
              if (topikId != null && topikId > 0) 'topik_id': topikId,
              'title': title,
              'description': description,
              'deadline': deadlineStr,
              if (fileUrl != null && fileUrl.isNotEmpty) 'file_url': fileUrl,
            },
          );
    if (!res.success) {
      res = await ApiClient.instance.post(
        '/assignments',
        body: {
          'class_subject_id': classSubjectId,
          if (topikId != null && topikId > 0) 'topik_id': topikId,
          'title': title,
          'description': description,
          'deadline': deadlineStr,
          if (fileUrl != null && fileUrl.isNotEmpty) 'file_url': fileUrl,
        },
      );
    }

    return {
      'success': res.success,
      'data': res.success ? res.data : null,
      'message': res.success
          ? 'Tugas berhasil dibuat'
          : (res.errorMessage ?? 'Gagal membuat tugas'),
    };
  }

  Future<Map<String, dynamic>> updateTugas({
    required int assignmentId,
    required String title,
    required String description,
    required DateTime deadline,
  }) async {
    final deadlineStr = deadline.toIso8601String();
    var res = await ApiClient.instance.put(
      '/teacher/assignments/$assignmentId',
      body: {
        'title': title,
        'description': description,
        'deadline': deadlineStr,
      },
    );
    if (!res.success) {
      res = await ApiClient.instance.put(
        '/assignments/$assignmentId',
        body: {
          'title': title,
          'description': description,
          'deadline': deadlineStr,
        },
      );
    }
    return {
      'success': res.success,
      'message': res.success
          ? 'Tugas berhasil diperbarui'
          : (res.errorMessage ?? 'Gagal memperbarui tugas'),
    };
  }

  Future<Map<String, dynamic>> hapusTugas(int assignmentId) async {
    var res = await ApiClient.instance.delete('/teacher/assignments/$assignmentId');
    if (!res.success) {
      res = await ApiClient.instance.delete('/assignments/$assignmentId');
    }
    return {
      'success': res.success,
      'message': res.success
          ? 'Tugas berhasil dihapus'
          : (res.errorMessage ?? 'Gagal menghapus tugas'),
    };
  }

  /// Kumpulkan tugas PR siswa via `/assignments/{publicId}/submit`
  Future<Map<String, dynamic>> kumpulkanTugas({
    required String publicId,
    required String fileUrl,
    String? filePath,
    String? note,
  }) async {
    final res = (filePath != null && filePath.isNotEmpty)
        ? await ApiClient.instance.postMultipart(
            '/assignments/$publicId/submit',
            fields: {
              if (note != null && note.isNotEmpty) 'note': note,
            },
            fileField: 'file',
            filePath: filePath,
          )
        : await ApiClient.instance.post(
            '/assignments/$publicId/submit',
            body: {
              'file_url': fileUrl,
              if (note != null && note.isNotEmpty) 'note': note,
            },
          );

    return {
      'success': res.success,
      'message': res.success
          ? 'Tugas berhasil dikumpulkan!'
          : (res.errorMessage ?? 'Gagal mengumpulkan tugas.'),
    };
  }

  /// Ambil daftar siswa berdasarkan kelas (untuk guru lihat siapa saja siswa di kelas tugas)
  Future<List<SiswaItem>> ambilSiswaKelas(int kelasId) async {
    return await SiswaService().fetchAll(kelasId: kelasId);
  }
}
