import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum_8/main.dart';

void main() {
  test('ID NIM dihitung sesuai ketentuan', () {
    expect(userIdFromNim, 1524);
    expect(adminIdFromNim, 817);
  });
}
