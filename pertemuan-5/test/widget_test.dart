import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum_tugas/main.dart';

void main() {
  testWidgets('App renders StokBarangPage', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Pencatatan Stok Barang'), findsOneWidget);
    expect(find.text('Simpan Barang'), findsOneWidget);
  });
}