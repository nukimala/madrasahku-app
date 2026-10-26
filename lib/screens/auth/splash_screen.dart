
import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF219653);

    return Scaffold(
      backgroundColor: green,
      body: Stack(
        children: [
          // Lingkaran dekorasi kiri atas
          const Positioned(
            top: -35,
            left: -35,
            child: _CircleDecoration(
              size: 180,
              color: Color(0xFF43A875),
            ),
          ),

          // Lingkaran dekorasi kanan atas
          const Positioned(
            top: 35,
            right: -35,
            child: _CircleDecoration(
              size: 110,
              color: Color(0xFF16834A),
            ),
          ),

          // Lingkaran dekorasi kiri bawah
          const Positioned(
            bottom: 100,
            left: -55,
            child: _CircleDecoration(
              size: 160,
              color: Color(0xFF43A875),
            ),
          ),

          // Lingkaran dekorasi kanan bawah
          const Positioned(
            bottom: -55,
            right: -40,
            child: _CircleDecoration(
              size: 175,
              color: Color(0xFF16834A),
            ),
          ),

          // Logo dan nama aplikasi
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/image/LOGO_MTS.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Madrasahku',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'MTs Al-Huda Gondang',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleDecoration extends StatelessWidget {
  final double size;
  final Color color;

  const _CircleDecoration({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
