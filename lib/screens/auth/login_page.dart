
import 'package:flutter/material.dart';
import '../admin/admin_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final Map<String, Map<String, String>> _demoUsers = {
    'admin@madrasahku.sch.id': {
      'password': 'admin123',
      'role': 'admin',
    },
    'guru@madrasahku.sch.id': {
      'password': 'guru123',
      'role': 'guru',
    },
    'siswa@madrasahku.sch.id': {
      'password': 'siswa123',
      'role': 'siswa',
    },
  };

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Username/email dan password wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    final user = _demoUsers[email];

    if (user == null || user['password'] != password) {
      setState(() => _isLoading = false);
      _showMessage('Username/email atau password salah.');
      return;
    }

    setState(() => _isLoading = false);

    switch (user['role']) {
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminHomePage(),
          ),
        );
        break;

      case 'guru':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const _RoleHomePage(role: 'Guru'),
          ),
        );
        break;

      case 'siswa':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const _RoleHomePage(role: 'Siswa'),
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF219653);
    const darkGreen = Color(0xFF104D38);
    const muted = Color(0xFF8A9B91);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),

                        // Logo aplikasi
                        Image.asset(
                          'assets/image/LOGO_MTS.png',
                          height: 145,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.school_rounded,
                              size: 120,
                              color: green,
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Nama aplikasi
                        const Text(
                          'Madrasahku',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'MTs Al-Huda Gondang',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: darkGreen,
                          ),
                        ),

                        const SizedBox(height: 45),

                        // Sambutan
                        const Text(
                          'Selamat datang',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Masuk Ke Akun Anda Untuk Melanjutkan\n'
                          'Ke Aplikasi Madrasahku',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: muted,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Input email
                        _buildInput(
                          controller: _emailController,
                          hint: 'Username / Email',
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 22),

                        // Input password
                        _buildInput(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                          onSubmitted: (_) => _login(),
                        ),

                        // Lupa password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _showMessage(
                                'Fitur lupa password akan dibuat '
                                'setelah Firebase terhubung.',
                              );
                            },
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(
                                color: green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tombol masuk
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: green,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Pendaftaran akun
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text(
                              'Belum Punya Akun? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showMessage(
                                  'Pendaftaran akun akan dibuat '
                                  'setelah sistem akun siap.',
                                );
                              },
                              child: const Text(
                                'Daftar Sekarang',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget untuk input email dan password
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 13,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF8A9B91),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFCACACA),
            size: 21,
          ),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 19,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: Color(0xFF219653),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// Halaman sementara untuk Guru dan Siswa
class _RoleHomePage extends StatelessWidget {
  final String role;

  const _RoleHomePage({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda $role'),
        backgroundColor: const Color(0xFF219653),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Selamat datang di Beranda $role'),
      ),
    );
  }
}
