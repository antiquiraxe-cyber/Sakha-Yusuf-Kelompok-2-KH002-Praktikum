import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String nama;
  final String nim;
  final String hobi;
  final int skorAktivitas;

  const ProfileCard({
    super.key,
    required this.nama,
    required this.nim,
    required this.hobi,
    required this.skorAktivitas,
  });

  @override
  Widget build(BuildContext context) {
    // ─── Nilai Styling Berdasarkan NIM: 20240801052 ───────────────────────────
    // Digit terakhir          : 2
    // Digit ke-2 dari belakang: 5
    // 2 digit terakhir        : 52
    //
    // Lebar Kartu  : 320.0 + (5 × 5)   = 345.0
    // Sudut        : 12.0  + (2 × 1.5) = 15.0
    // Ukuran Logo  : 60.0  + (2 × 2)   = 64.0
    // Jarak Pemisah: 15.0  + 2          = 17.0
    // Skor Aktivitas: 52 + 50           = 102
    const double lebarKartu      = 345.0;   // 320 + (5 × 5)
    const double sudutMelengkung = 15.0;    // 12  + (2 × 1.5)
    const double ukuranLogo      = 64.0;    // 60  + (2 × 2)
    const double jarakPemisah    = 17.0;    // 15  + 2

    return Container(
      width: lebarKartu,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sudutMelengkung),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sisi Kiri – Logo Flutter dalam kotak berpojok bulat
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(sudutMelengkung),
                  border: Border.all(color: Colors.blue.shade100, width: 1.5),
                ),
                child: FlutterLogo(size: ukuranLogo),
              ),

              SizedBox(width: jarakPemisah),

              // Sisi Kanan – Judul & Nama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kartu Praktikum',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Pemisah ─────────────────────────────────────────────────────────
          const SizedBox(height: 16),
          const Divider(thickness: 1.5),
          const SizedBox(height: 12),

          // ── Bagian Detail Identitas ──────────────────────────────────────────
          _detailBaris('NIM', nim),
          const SizedBox(height: 8),
          _detailBaris('Hobi', hobi),
          const SizedBox(height: 8),
          _detailBaris('Skor Aktivitas', '$skorAktivitas'),
        ],
      ),
    );
  }

  /// Helper: baris label + nilai
  Widget _detailBaris(String label, String nilai) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(color: Colors.grey)),
        Expanded(
          child: Text(
            nilai,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
