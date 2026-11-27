import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/admin.dart';

class AdminService {
  static const _base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
  static const _baseUrl = '$_base/admins';
  final http.Client _client;

  AdminService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Admin>> getAdmins() async {
    final response = await _client.get(Uri.parse(_baseUrl));
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Admin.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Admin> getAdmin(int id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/$id'));
    _ensureSuccess(response);
    return Admin.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteAdmin(int id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/$id'));
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
