import '../models/admin_profile_model.dart';
import 'api_client.dart';
import 'token_store.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final _adminAccount = _DemoAccount(
    email: 'admin@madrasahku.sch.id',
    username: 'admin_madrasah',
    password: 'admin123',
    role: 'admin',
    namaLengkap: 'Admin Madrasah',
    nomorTelepon: '08xxxxxxxxxx',
  );

  final List<_DemoAccount> _otherAccounts = [
    _DemoAccount(
      email: 'guru@madrasahku.sch.id',
      username: 'guru',
      password: 'guru123',
      role: 'guru',
      namaLengkap: 'Guru Madrasah',
      nomorTelepon: '',
    ),
    _DemoAccount(
      email: 'siswa@madrasahku.sch.id',
      username: 'siswa',
      password: 'siswa123',
      role: 'siswa',
      namaLengkap: 'Siswa Madrasah',
      nomorTelepon: '',
    ),
  ];

  _DemoAccount? _currentAccount;

  // Data pengguna aktif dari API
  String? _currentUserRole;
  String? _currentUserName;
  String? _currentUserEmail;
  String? _currentUsername;
  String? _currentUserPhone;

  // Student class info (dari /me endpoint)
  int? _currentStudentClassId;
  String? _currentStudentClassName;
  Map<String, dynamic> _currentProfile = {};

  String? get currentRole => _currentUserRole ?? _currentAccount?.role;
  String? get currentTeacherName =>
      currentRole == 'guru' ? (_currentUserName ?? 'Guru Madrasah') : null;
  String? get currentStudentName =>
      currentRole == 'siswa' ? (_currentUserName ?? 'Siswa Madrasah') : null;
  String get currentEmail => _currentUserEmail ?? '';
  String get currentNip => (_currentProfile['nip'] ?? _currentProfile['nuptk'] ?? '').toString();
  String get currentSubjectSpecialty => (_currentProfile['bidang_studi'] ?? '').toString();
  String get currentAddress => (_currentProfile['alamat'] ?? '').toString();
  String get currentHomeroomClass => (_currentProfile['wali_kelas'] ?? '').toString();
  String get currentNisn => (_currentProfile['nisn'] ?? _currentProfile['nis'] ?? '').toString();
  String get currentWaliKelas => (_currentProfile['wali_kelas'] ?? '').toString();

  // Getters untuk kelas siswa
  int? get currentStudentClassId => _currentStudentClassId;
  String? get currentStudentClassName => _currentStudentClassName;

  AdminProfile get adminProfile => AdminProfile(
    namaLengkap: _currentUserName ?? _adminAccount.namaLengkap,
    email: _currentUserEmail ?? _adminAccount.email,
    username: _currentUsername ?? _adminAccount.username,
    nomorTelepon: _currentUserPhone ?? _adminAccount.nomorTelepon,
  );

  /// Login fleksibel: Coba REST API live dulu, fallback ke demo in-memory jika offline
  Future<bool> login(String identifier, String password) async {
    final normalized = identifier.trim().toLowerCase();

    // 1. Panggil REST API live /auth/login
    try {
      final res = await ApiClient.instance.post(
        '/auth/login',
        body: {
          'identifier': identifier.trim(),
          'password': password,
          'device_name': 'Aplikasi Madrasahku Mobile',
          'platform': 'android',
        },
      );

      if (res.success && res.data != null) {
        final tokens = res.data['tokens'];
        final userData = res.data['user'];

        if (tokens != null) {
          final acc = (tokens['access_token'] ?? '').toString();
          final ref = (tokens['refresh_token'] ?? '').toString();
          ApiClient.instance.setTokens(
            accessToken: acc,
            refreshToken: ref,
          );
          try {
            await TokenStore.save(acc, ref);
          } catch (_) {}
        }

        if (userData != null) {
          _currentUserRole = (userData['role'] ?? '').toString().toLowerCase();
          _currentUserName = userData['name'] ?? '';
          _currentUserEmail = userData['email'] ?? '';
          _currentUsername = userData['username'] ?? '';
        }

        // Sinkronisasi data detail profil /me
        await fetchMe();
        return true;
      }
    } catch (_) {}

    // 2. Fallback akun demo offline jika API tidak terjangkau
    if ((_adminAccount.email.toLowerCase() == normalized ||
            _adminAccount.username.toLowerCase() == normalized) &&
        _adminAccount.password == password) {
      _currentAccount = _adminAccount;
      _currentUserRole = 'admin';
      _currentUserName = _adminAccount.namaLengkap;
      return true;
    }

    for (final account in _otherAccounts) {
      if ((account.email.toLowerCase() == normalized ||
              account.username.toLowerCase() == normalized) &&
          account.password == password) {
        _currentAccount = account;
        _currentUserRole = account.role;
        _currentUserName = account.namaLengkap;
        return true;
      }
    }

    return false;
  }

  /// Ambil profil detail pengguna dari /me
  Future<bool> fetchMe() async {
    try {
      final res = await ApiClient.instance.get('/me');
      if (res.success && res.data != null && res.data['user'] != null) {
        final u = res.data['user'];
        _currentUserRole = (u['role'] ?? _currentUserRole ?? '').toString().toLowerCase();
        _currentUserName = u['name'] ?? _currentUserName;
        _currentUserEmail = u['email'] ?? _currentUserEmail;
        _currentUsername = u['username'] ?? _currentUsername;
        if (u['profile'] is Map) {
          _currentProfile = Map<String, dynamic>.from(u['profile'] as Map);
          _currentUserPhone = _currentProfile['phone']?.toString() ?? _currentProfile['no_hp']?.toString();
        } else {
          _currentProfile = {};
        }

        // Extract student class info if role is siswa
        if (_currentUserRole == 'siswa' && _currentProfile.isNotEmpty) {
          final rawClassId = _currentProfile['kelas_id'] ?? _currentProfile['class_id'];
          _currentStudentClassId = rawClassId is int
              ? rawClassId
              : int.tryParse(rawClassId?.toString() ?? '');
          _currentStudentClassName = (_currentProfile['kelas'] ?? _currentProfile['class_name'] ?? _currentProfile['nama_kelas'] ?? '').toString();
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> updateProfile({String? email, String? alamat, String? noHp}) async {
    try {
      final res = await ApiClient.instance.put(
        '/me',
        body: {
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          if (alamat != null && alamat.trim().isNotEmpty) 'alamat': alamat.trim(),
          if (noHp != null && noHp.trim().isNotEmpty) 'no_hp': noHp.trim(),
        },
      );
      if (res.success && res.data != null && res.data['user'] != null) {
        final u = res.data['user'];
        _currentUserEmail = u['email'] ?? _currentUserEmail;
        if (u['profile'] is Map) {
          _currentProfile = Map<String, dynamic>.from(u['profile'] as Map);
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  void startDemoSession(String role) {
    _currentUserRole = role;
    if (role == 'admin') {
      _currentAccount = _adminAccount;
      _currentUserName = _adminAccount.namaLengkap;
      return;
    }

    for (final account in _otherAccounts) {
      if (account.role == role) {
        _currentAccount = account;
        _currentUserName = account.namaLengkap;
        return;
      }
    }

    _currentAccount = null;
  }

  bool updateAdminProfile(AdminProfile profile) {
    if (currentRole != 'admin') return false;

    final email = profile.email.trim().toLowerCase();
    final username = profile.username.trim().toLowerCase();
    final hasDuplicate = _otherAccounts.any(
      (account) =>
          account.email.toLowerCase() == email ||
          account.username.toLowerCase() == username ||
          account.username.toLowerCase() == email ||
          account.email.toLowerCase() == username,
    );
    if (hasDuplicate) return false;

    _adminAccount
      ..email = email
      ..username = username
      ..namaLengkap = profile.namaLengkap.trim()
      ..nomorTelepon = profile.nomorTelepon.trim();

    _currentUserName = profile.namaLengkap.trim();
    _currentUserEmail = email;
    _currentUsername = username;
    _currentUserPhone = profile.nomorTelepon.trim();
    return true;
  }

  bool changeAdminPassword({
    required String currentPassword,
    required String newPassword,
  }) {
    if (_currentAccount != _adminAccount ||
        _adminAccount.password != currentPassword) {
      return false;
    }
    _adminAccount.password = newPassword;
    return true;
  }

  /// Pulihkan sesi login tersimpan saat aplikasi dibuka (auto-login)
  Future<String?> restoreSession() async {
    try {
      await TokenStore.load();
      final acc = TokenStore.access;
      final ref = TokenStore.refresh;
      if (acc == null || acc.isEmpty) return null;
      ApiClient.instance.setTokens(accessToken: acc, refreshToken: ref);
      final ok = await fetchMe();
      if (ok && _currentUserRole != null && _currentUserRole!.isNotEmpty) {
        return _currentUserRole;
      }
      await TokenStore.clear();
      ApiClient.instance.clearTokens();
    } catch (_) {}
    return null;
  }

  /// Ubah password akun yang sedang login ke database server
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await ApiClient.instance.post(
      '/auth/change-password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    return {
      'success': res.success,
      'message': res.success
          ? 'Password berhasil diubah.'
          : (res.errorMessage ?? 'Gagal mengubah password.'),
    };
  }

  Future<void> logout() async {
    try {
      if (ApiClient.instance.accessToken != null) {
        await ApiClient.instance.post('/auth/logout');
      }
    } catch (_) {}
    try {
      await TokenStore.clear();
    } catch (_) {}
    _currentAccount = null;
    _currentUserRole = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _currentUsername = null;
    _currentUserPhone = null;
    ApiClient.instance.clearTokens();
  }
}

class _DemoAccount {
  String email;
  String username;
  String password;
  final String role;
  String namaLengkap;
  String nomorTelepon;

  _DemoAccount({
    required this.email,
    required this.username,
    required this.password,
    required this.role,
    required this.namaLengkap,
    required this.nomorTelepon,
  });
}
