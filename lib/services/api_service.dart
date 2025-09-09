import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "https://02dd79dadd56.ngrok-free.app"; // Android Emulator
  final storage = const FlutterSecureStorage();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Lưu access + refresh token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await storage.write(key: "access_token", value: accessToken);
    await storage.write(key: "refresh_token", value: refreshToken);
  }

  // Lấy access token
  Future<String?> getAccessToken() async {
    return await storage.read(key: "access_token");
  }

  // Lấy refresh token
  Future<String?> getRefreshToken() async {
    return await storage.read(key: "refresh_token");
  }

  // Xóa token (logout)
  Future<void> clearTokens() async {
    await storage.delete(key: "access_token");
    await storage.delete(key: "refresh_token");
  }

  // Gọi API chung (tự động refresh token nếu 401)
  Future<http.Response> _request(
      String method,
      String endpoint, {
        Map<String, dynamic>? body,
        bool requireAuth = false,
      }) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = <String, String>{"Content-Type": "application/json"};

    if (requireAuth) {
      final token = await getAccessToken();
      if (token != null) headers["Authorization"] = "Bearer $token";
    }

    late http.Response response;
    switch (method.toUpperCase()) {
      case "GET":
        response = await http.get(url, headers: headers);
        break;
      case "POST":
        response = await http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case "PUT":
        response = await http.put(url, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case "DELETE":
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw Exception("Unsupported HTTP method: $method");
    }

    // Nếu 401 → thử refresh token
    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        // Gọi lại API với token mới
        final newToken = await getAccessToken();
        if (newToken != null) headers["Authorization"] = "Bearer $newToken";

        switch (method.toUpperCase()) {
          case "GET":
            response = await http.get(url, headers: headers);
            break;
          case "POST":
            response = await http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
            break;
          case "PUT":
            response = await http.put(url, headers: headers, body: body != null ? jsonEncode(body) : null);
            break;
          case "DELETE":
            response = await http.delete(url, headers: headers);
            break;
        }
      }
    }

    return response;
  }

  // Hàm refresh access token
  Future<bool> _refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/refresh"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh_token": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccess = data["access_token"];
      final newRefresh = data["refresh_token"] ?? refreshToken; // nếu backend trả refresh token mới
      await saveTokens(accessToken: newAccess, refreshToken: newRefresh);
      return true;
    } else {
      // Refresh token hết hạn → cần login lại
      await clearTokens();
      return false;
    }
  }

  // Public GET/POST/PUT/DELETE
  Future<http.Response> get(String endpoint, {bool requireAuth = false}) =>
      _request("GET", endpoint, requireAuth: requireAuth);

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, bool requireAuth = false}) =>
      _request("POST", endpoint, body: body, requireAuth: requireAuth);

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body, bool requireAuth = false}) =>
      _request("PUT", endpoint, body: body, requireAuth: requireAuth);

  Future<http.Response> delete(String endpoint, {bool requireAuth = false}) =>
      _request("DELETE", endpoint, requireAuth: requireAuth);
}
