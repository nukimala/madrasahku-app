import 'api_client.dart';
import '../models/tugas_model.dart';
import '../models/siswa_model.dart';
import 'siswa_service.dart';

class TugasService {
  TugasService._();
  static final TugasService instance = TugasService._();

  // Ambil daftar tugas dari server API `/assignments`
  Future<List<TugasItem>> ambilDaftarTugas({int? classId}) async {
    final params = <String, String>{};
    if (classId != null && classId > 0) {
      params['class_id'] = classId.toString();
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

  /// Kumpulkan tugas PR siswa via `/assignments/{publicId}/submit`
  Future<Map<String, dynamic>> kumpulkanTugas({
    required String publicId,
    required String fileUrl,
    String? note,
  }) async {
    final res = await ApiClient.instance.post(
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
