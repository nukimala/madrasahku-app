import '../models/admin_profile_model.dart';

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

  String? get currentRole => _currentAccount?.role;
  String? get currentTeacherName =>
      _currentAccount?.role == 'guru' ? 'Siti Nurhaliza' : null;

  AdminProfile get adminProfile => AdminProfile(
    namaLengkap: _adminAccount.namaLengkap,
    email: _adminAccount.email,
    username: _adminAccount.username,
    nomorTelepon: _adminAccount.nomorTelepon,
  );

  bool login(String identifier, String password) {
    final normalizedIdentifier = identifier.trim().toLowerCase();
    if ((_adminAccount.email.toLowerCase() == normalizedIdentifier ||
            _adminAccount.username.toLowerCase() == normalizedIdentifier) &&
        _adminAccount.password == password) {
      _currentAccount = _adminAccount;
      return true;
    }

    return false;
  }

  void startDemoSession(String role) {
    if (role == 'admin') {
      _currentAccount = _adminAccount;
      return;
    }

    for (final account in _otherAccounts) {
      if (account.role == role) {
        _currentAccount = account;
        return;
      }
    }

    _currentAccount = null;
  }

  bool updateAdminProfile(AdminProfile profile) {
    if (_currentAccount != _adminAccount) return false;

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

  void logout() {
    _currentAccount = null;
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
