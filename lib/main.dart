import 'package:flutter/material.dart';

import 'services/jadwal_service.dart';
import 'screens/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JadwalService.instance.load();
  runApp(const MadrasahkuApp());
}

class MadrasahkuApp extends StatelessWidget {
  const MadrasahkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madrasahku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF219653)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
