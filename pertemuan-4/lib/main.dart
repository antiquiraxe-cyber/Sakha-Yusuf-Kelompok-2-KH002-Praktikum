import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'widgets/app_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Digit terakhir NIM 20240801052 -> d = 2
    // Padding card       : 16 + 2 = 18
    // Rounded card       : 8 + 2  = 10
    // Tinggi tombol      : 40 + 2 = 42
    // Rounded tombol     : 4 + 2  = 6
    // Ukuran avatar      : 40 + (2 * 2) = 44
    // Jarak nama dan NIM : 8 + 2  = 10

    const double cardPadding = 18.0;
    const double cardRadius = 10.0;
    const double buttonHeight = 42.0;
    const double buttonRadius = 6.0;
    const double avatarSize = 44.0;
    const double gapNamaNim = 10.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: avatarSize / 2,
                    child: const Icon(Icons.person, size: 28),
                  ),
                  const SizedBox(height: 16),
                  const Text('Nama Mahasiswa'),
                  SizedBox(height: gapNamaNim),
                  const Text('20240801052'),
                  const SizedBox(height: 8),
                  const Text('Teknik Informatika'),
                  const SizedBox(height: 12),
                  const Text(
                    'Mahasiswa yang sedang mempelajari pengembangan aplikasi mobile menggunakan Flutter.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const AppButton(
                    label: 'Kunjungi GitHub Saya',
                    icon: Icons.code,
                    url: 'https://github.com/antiquiraxe-cyber',
                    height: buttonHeight,
                    borderRadius: buttonRadius,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}