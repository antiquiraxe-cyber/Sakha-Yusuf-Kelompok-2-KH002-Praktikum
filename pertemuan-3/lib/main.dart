import 'package:flutter/material.dart';

import 'profile_card.dart';

// ─── Data Praktikan ──────────────────────────────────────────────────────────
// NIM: 20240801052
//   Digit terakhir           = 2  → GENAP → scaffoldBackgroundColor = Amber[100]
//   Digit ke-2 dari belakang = 5
//   2 digit terakhir         = 52 → skorAktivitas = 52 + 50 = 102
const String _nama = 'Sakha Yusuf Pasha';
const String _nim = '20240801052';
const String _hobi = 'Mancing';
const int _skorAktivitas = 102; // (52) + 50

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Layout Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Digit terakhir NIM = 2 (genap) → warna pastel kuning/oranye muda
        scaffoldBackgroundColor: Colors.amber[100],
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Praktikan'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Column + spaceEvenly → kartu berada di tengah layar
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Praktikum 3 — Layout Flutter',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          ProfileCard(
            nama: _nama,
            nim: _nim,
            hobi: _hobi,
            skorAktivitas: _skorAktivitas,
          ),
          const Text(
            'NIM 20240801052 — Sakha Yusuf Pasha',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
