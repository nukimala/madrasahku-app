import 'api_client.dart';
import '../models/tugas_model.dart';

class TugasService {
  TugasService._();
  static final TugasService instance = TugasService._();

  /// Ambil daftar tugas dari server API `/assignments`
  Future<List<TugasItem>> ambilDaftarTugas({bool hanyaBelumTenggat = false}) async {
    final params = <String, String>{};
    if (hanyaBelumTenggat) params['open'] = '1';

    final res = await ApiClient.instance.get('/assignments', queryParams: params);
    if (res.success && res.data != null && res.data['assignments'] is List) {
      final list = res.data['assignments'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => TugasItem.fromJson(e))
          .toList();
    }
    return [];
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
}
