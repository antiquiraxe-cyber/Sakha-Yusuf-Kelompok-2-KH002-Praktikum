import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';

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
      home: const StokBarangPage(),
    );
  }
}

class StokBarangPage extends StatefulWidget {
  const StokBarangPage({super.key});

  @override
  State<StokBarangPage> createState() => _StokBarangPageState();
}

class _StokBarangPageState extends State<StokBarangPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _tglMasukController = TextEditingController();
  final _tglKeluarController = TextEditingController();
  final _kodeBarangController = TextEditingController();
  final _jumlahStokController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _tglMasukController.dispose();
    _tglKeluarController.dispose();
    _kodeBarangController.dispose();
    _jumlahStokController.dispose();
    super.dispose();
  }

  Future<void> _simpanBarang() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final kodeBarang = int.parse(_kodeBarangController.text);
      final jumlahStok = int.parse(_jumlahStokController.text);

      await FirebaseFirestore.instance.collection('stok_barang').add({
        'nama_barang': _namaController.text,
        'tanggal_masuk': _tglMasukController.text,
        'tanggal_keluar': _tglKeluarController.text,
        'kode_barang': kodeBarang,
        'jumlah_stok': jumlahStok,
        'waktu': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil disimpan'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Reset form
      _namaController.clear();
      _tglMasukController.clear();
      _tglKeluarController.clear();
      _kodeBarangController.clear();
      _jumlahStokController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateNama(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama Barang wajib diisi';
    }
    if (!value.toUpperCase().startsWith('S')) {
      return 'Nama Barang harus diawali huruf S';
    }
    return null;
  }

  String? _validateTgl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tanggal wajib diisi';
    }
    return null;
  }

  String? _validateKodeBarang(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kode Barang wajib diisi';
    }
    if (value.length < 6) {
      return 'Kode Barang minimal 6 digit';
    }
    if (!value.endsWith('52')) {
      return 'Kode Barang harus berakhiran 52';
    }
    if (int.tryParse(value) == null) {
      return 'Kode Barang harus berupa angka';
    }
    return null;
  }

  String? _validateStok(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jumlah Stok wajib diisi';
    }
    final stok = int.tryParse(value);
    if (stok == null) {
      return 'Jumlah Stok harus berupa angka';
    }
    if (stok < 0) {
      return 'Jumlah Stok tidak boleh negatif';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatatan Stok Barang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pertemuan 5 — Stok Barang Firebase',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Nama Barang
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Barang',
                  hintText: 'Contoh: Sapu Lidi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: _validateNama,
              ),
              const SizedBox(height: 16),

              // Tanggal Masuk
              TextFormField(
                controller: _tglMasukController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Masuk',
                  hintText: '2026-10-16',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: _validateTgl,
              ),
              const SizedBox(height: 16),

              // Tanggal Keluar
              TextFormField(
                controller: _tglKeluarController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Keluar',
                  hintText: '2026-10-20',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: _validateTgl,
              ),
              const SizedBox(height: 16),

              // Kode Barang
              TextFormField(
                controller: _kodeBarangController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kode Barang',
                  hintText: '100052 (min 6 digit, akhiran 52)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: _validateKodeBarang,
              ),
              const SizedBox(height: 16),

              // Jumlah Stok
              TextFormField(
                controller: _jumlahStokController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Stok',
                  hintText: '50',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: _validateStok,
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isLoading ? null : _simpanBarang,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Barang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
