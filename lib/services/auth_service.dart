import '../models/admin_profile_model.dart';
import 'api_client.dart';

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

  String? get currentRole => _currentUserRole ?? _currentAccount?.role;
  String? get currentTeacherName =>
      currentRole == 'guru' ? (_currentUserName ?? 'Guru Madrasah') : null;
  String? get currentStudentName =>
      currentRole == 'siswa' ? (_currentUserName ?? 'Siswa Madrasah') : null;

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
          ApiClient.instance.setTokens(
            accessToken: tokens['access_token'] ?? '',
            refreshToken: tokens['refresh_token'] ?? '',
          );
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
          _currentUserPhone = u['profile']['phone'] ?? u['profile']['no_hp'];
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

  Future<void> logout() async {
    try {
      if (ApiClient.instance.accessToken != null) {
        await ApiClient.instance.post('/auth/logout');
      }
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
