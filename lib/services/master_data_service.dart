import '../models/kelas_model.dart';
import '../models/mapel_model.dart';
import 'api_client.dart';

class MasterDataService {
  MasterDataService._();
  static final MasterDataService instance = MasterDataService._();

  Future<List<KelasItem>> fetchKelas() async {
    final res = await ApiClient.instance.get('/kelas');
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal memuat data kelas');
    }
    if (res.data is List) {
      return (res.data as List)
          .whereType<Map>()
          .map((e) => KelasItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<KelasItem> createKelas(KelasItem k) async {
    final res = await ApiClient.instance.post('/kelas', body: k.toJson());
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal menambahkan kelas');
    }
    if (res.data is Map) {
      return KelasItem.fromJson(Map<String, dynamic>.from(res.data as Map));
    }
    return k;
  }

  Future<KelasItem> updateKelas(int id, KelasItem k) async {
    final res = await ApiClient.instance.put('/kelas/$id', body: k.toJson());
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal memperbarui kelas');
    }
    if (res.data is Map) {
      return KelasItem.fromJson(Map<String, dynamic>.from(res.data as Map));
    }
    return k;
  }

  Future<void> deleteKelas(int id) async {
    final res = await ApiClient.instance.delete('/kelas/$id');
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal menghapus kelas');
    }
  }

  Future<List<MapelItem>> fetchMapel() async {
    final res = await ApiClient.instance.get('/mata-pelajaran');
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal memuat mata pelajaran');
    }
    if (res.data is List) {
      return (res.data as List)
          .whereType<Map>()
          .map((e) => MapelItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<MapelItem> createMapel(MapelItem m) async {
    final res = await ApiClient.instance.post('/mata-pelajaran', body: m.toJson());
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal menambahkan mata pelajaran');
    }
    if (res.data is Map) {
      return MapelItem.fromJson(Map<String, dynamic>.from(res.data as Map));
    }
    return m;
  }

  Future<MapelItem> updateMapel(int id, MapelItem m) async {
    final res = await ApiClient.instance.put('/mata-pelajaran/$id', body: m.toJson());
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal memperbarui mata pelajaran');
    }
    if (res.data is Map) {
      return MapelItem.fromJson(Map<String, dynamic>.from(res.data as Map));
    }
    return m;
  }

  Future<void> deleteMapel(int id) async {
    final res = await ApiClient.instance.delete('/mata-pelajaran/$id');
    if (!res.success) {
      throw Exception(res.errorMessage ?? 'Gagal menghapus mata pelajaran');
    }
  }
}
