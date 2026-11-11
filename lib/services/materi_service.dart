import 'api_client.dart';
import '../models/materi_model.dart';

class MateriService {
  MateriService._();
  static final MateriService instance = MateriService._();

  Future<List<MateriItem>> ambilDaftarMateri() async {
    final res = await ApiClient.instance.get('/materials');
    if (res.success && res.data != null && res.data['materials'] is List) {
      final list = res.data['materials'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => MateriItem.fromJson(e))
          .toList();
    }
    return [];
  }
}
