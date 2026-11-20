import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  static const _storage = FlutterSecureStorage();
  static String? access;   // dipakai langsung di header
  static String? refresh;

  static Future<void> save(String a, String r) async {
    access = a;
    refresh = r;
    await _storage.write(key: 'access', value: a);
    await _storage.write(key: 'refresh', value: r);
  }

  // panggil sekali saat app dibuka
  static Future<void> load() async {
    access = await _storage.read(key: 'access');
    refresh = await _storage.read(key: 'refresh');
  }

  static Future<void> clear() async {
    access = null;
    refresh = null;
    await _storage.deleteAll();
  }
}