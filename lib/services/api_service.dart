import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000"; // Nếu chạy trên Android Emulator
  final storage = const FlutterSecureStorage();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Lưu token
  Future<void> saveToken(String token) async {
    await storage.write(key: "access_token", value: token);
  }

  // Lấy token
  Future<String?> getToken() async {
    return await storage.read(key: "access_token");
  }

  // Xóa token
  Future<void> clearToken() async {
    await storage.delete(key: "access_token");
  }

  // GET request với authorization header
  Future<http.Response> get(String endpoint, {bool requireAuth = false}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = <String, String>{"Content-Type": "application/json"};

    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return await http.get(url, headers: headers);
  }

  // POST request với authorization header
  Future<http.Response> post(String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = <String, String>{"Content-Type": "application/json"};

    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // PUT request với authorization header
  Future<http.Response> put(String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = <String, String>{"Content-Type": "application/json"};

    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return await http.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // DELETE request với authorization header
  Future<http.Response> delete(String endpoint, {bool requireAuth = false}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = <String, String>{"Content-Type": "application/json"};

    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return await http.delete(url, headers: headers);
  }

  Future<http.Response> getRequest(String path, {bool requireAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await storage.read(key: 'access_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }
}