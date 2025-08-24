import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000"; // Nếu chạy trên Android Emulator
  final storage = const FlutterSecureStorage();

 // Đăng ký
  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final url = Uri.parse("$baseUrl/api/auth/register");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username.trim(),
          "email": email.trim(),
          "password": password.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": "Đăng ký thành công"};
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        String errorMessage = "Đăng ký thất bại";

        if (body.containsKey("detail")) {
          final detail = body["detail"];

          if (detail is List) {
            // Chỉ lấy msg cho mỗi lỗi
            errorMessage = detail.map((e) {
              if (e is Map<String, dynamic>) {
                return e["msg"]?.toString() ?? "";
              } else {
                return e.toString();
              }
            }).join("\n");
          } else {
            errorMessage = detail.toString();
          }
        }

        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối server"};
    }
  }


  // Đăng nhập
  Future<bool> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/api/auth/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "access_token", value: data["access_token"]);
      return true;
    }
    return false;
  }

  // Lấy token
  Future<String?> getToken() async {
    return await storage.read(key: "access_token");
  }

  // Lấy thông tin user từ token
  Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse("$baseUrl/api/auth/me");
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await storage.delete(key: "access_token");
  }

  /// Gửi OTP về email
  Future<Map<String, dynamic>?> forgotPassword(String email) async {
    final url = Uri.parse("$baseUrl/api/auth/forgot-password");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    print("forgotPassword: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 400) {
      // Trả về JSON từ backend, có thể là message chung
      return jsonDecode(response.body);
    } else {
      // Trường hợp lỗi server
      return null;
    }
  }


  /// Xác thực OTP
  Future<bool> verifyOtp(String email, String otp) async {
    final url = Uri.parse("$baseUrl/api/auth/verify-otp");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    print("verifyOtp: ${response.statusCode} - ${response.body}");
    return response.statusCode == 200;
  }

  /// Đặt mật khẩu mới
  Future<bool> resetPassword(String email, String newPassword) async {
    final url = Uri.parse("$baseUrl/api/auth/reset-password");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "new_password": newPassword}),
    );

    print("resetPassword: ${response.statusCode} - ${response.body}");
    return response.statusCode == 200;
  }
}
