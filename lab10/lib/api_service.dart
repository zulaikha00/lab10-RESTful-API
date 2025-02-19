import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Register User
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Login User
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      var data = _handleResponse(response);
      await storage.write(key: 'token', value: data['token']);
      return data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Get User Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      String? token = await storage.read(key: 'token');
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<void> updateUser(int userId, String name, String email,
      {String? oldPassword,
      String? newPassword,
      String? confirmNewPassword}) async {
    String? token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found');
    }

    final Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
    };

    if (oldPassword != null &&
        newPassword != null &&
        confirmNewPassword != null) {
      requestBody['oldPassword'] = oldPassword;
      requestBody['newPassword'] = newPassword;
      requestBody['newPassword_confirmation'] = confirmNewPassword;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      print('User updated successfully');
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // Delete User Profile
  Future<void> deleteProfile(int id) async {
    try {
      String? token = await storage.read(key: 'token');
      if (token == null) throw Exception('No token found');

      final response = await http.delete(
        Uri.parse('$baseUrl/user/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }

  // Logout User
  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  // Response Handling
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}
