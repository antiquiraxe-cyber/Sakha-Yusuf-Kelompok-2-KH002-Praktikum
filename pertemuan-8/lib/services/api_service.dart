import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';

class ApiService {
  static const _base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
  static const _baseUrl = '$_base/users';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<User>> getUsers() async {
    final response = await _client.get(Uri.parse(_baseUrl));
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<User> getUser(int id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/$id'));
    _ensureSuccess(response);
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<User> createUser(User user) async {
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    _ensureSuccess(response);
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<User> updateUser(int id, {required String name, required String email}) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email}),
    );
    _ensureSuccess(response);
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<User> patchUser(int id, {required String name}) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': '$name - Flutter Developer'}),
    );
    _ensureSuccess(response);
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/$id'));
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
