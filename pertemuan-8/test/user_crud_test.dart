import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:praktikum_8/main.dart';
import 'package:praktikum_8/services/admin_service.dart';
import 'package:praktikum_8/services/api_service.dart';

const _userJson = {
  'id': 1,
  'name': 'Sakha',
  'email': 'sakha@example.com',
  'city': 'Bandung',
};

const _adminJson = {
  'id': 1,
  'name': 'Admin Sakha',
  'email': 'admin@example.com',
  'department': 'IT',
};

void main() {
  late List<http.Request> requests;

  Widget buildApp() {
    final client = MockClient((request) async {
      requests.add(request);
      final path = request.url.path;
      if (request.method == 'GET' && path == '/users') {
        return http.Response(jsonEncode([_userJson]), 200);
      }
      if (request.method == 'GET' && path == '/admins') {
        return http.Response(jsonEncode([_adminJson]), 200);
      }
      if (path.startsWith('/admins/')) {
        return http.Response(jsonEncode(_adminJson), 200);
      }
      if (path.startsWith('/users/')) {
        return http.Response(jsonEncode(_userJson), 200);
      }
      return http.Response(jsonEncode(_userJson), 201);
    });
    return PraktikumApp(apiService: ApiService(client: client), adminService: AdminService(client: client));
  }

  setUp(() {
    requests = [];
  });

  testWidgets('GET detail User berdasarkan ID tidak crash', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cari detail berdasarkan ID'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '1');
    await tester.tap(find.text('Tampilkan'));
    await tester.pumpAndSettle();

    expect(find.text('Detail User #1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('POST User mengirim POST /users', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    requests.clear();

    await tester.tap(find.text('POST User'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Budi');
    await tester.enterText(find.byType(TextFormField).at(1), 'budi@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'POST'));
    await tester.pumpAndSettle();

    final request = requests.singleWhere((r) => r.method == 'POST');
    expect(request.url.path, '/users');
    expect(jsonDecode(request.body)['id'], userIdFromNim);
  });

  testWidgets('PUT User mengirim nama dan email', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    requests.clear();

    await tester.tap(find.text('PUT User'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tampilkan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Nama Baru');
    await tester.enterText(find.byType(TextFormField).at(1), 'baru@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'PUT'));
    await tester.pumpAndSettle();

    final request = requests.singleWhere((r) => r.method == 'PUT');
    expect(request.url.path, '/users/$userIdFromNim');
    final body = jsonDecode(request.body);
    expect(body['name'], 'Nama Baru');
    expect(body['email'], 'baru@example.com');
  });

  testWidgets('PATCH User menambah " - Flutter Developer"', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    requests.clear();

    await tester.tap(find.text('PATCH User'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tampilkan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Budi');
    await tester.tap(find.widgetWithText(FilledButton, 'PATCH'));
    await tester.pumpAndSettle();

    final request = requests.singleWhere((r) => r.method == 'PATCH');
    expect(request.url.path, '/users/$userIdFromNim');
    expect(jsonDecode(request.body)['name'], 'Budi - Flutter Developer');
  });

  testWidgets('DELETE User mengirim DELETE /users/{id}', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    requests.clear();

    await tester.tap(find.text('DELETE User'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tampilkan'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Ya'));
    await tester.pumpAndSettle();

    final request = requests.singleWhere((r) => r.method == 'DELETE');
    expect(request.url.path, '/users/$userIdFromNim');
  });
}
