import 'dart:convert';

import 'api_service.dart';


class AuthService {
  final ApiService _apiService = ApiService();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Đăng ký
  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      final response = await _apiService.post(
        "/api/auth/register",
        body: {
          "username": username.trim(),
          "email": email.trim(),
          "password": password.trim(),
        },
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
    try {
      final response = await _apiService.post(
        "/api/auth/login",
        body: {
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _apiService.saveToken(data["access_token"]);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Lấy thông tin user từ token
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final response = await _apiService.get(
        "/api/auth/me",
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.clearToken();
  }

  // Kiểm tra user đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }

  // Gửi OTP về email (Forgot password)
  Future<Map<String, dynamic>?> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        "/api/auth/forgot-password",
        body: {"email": email},
      );

      print("forgotPassword: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 400) {
        // Trả về JSON từ backend, có thể là message chung
        return jsonDecode(response.body);
      } else {
        // Trường hợp lỗi server
        return null;
      }
    } catch (e) {
      print("Error in forgotPassword: $e");
      return null;
    }
  }

  // Xác thực OTP
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiService.post(
        "/api/auth/verify-otp",
        body: {"email": email, "otp": otp},
      );

      print("verifyOtp: ${response.statusCode} - ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Error in verifyOtp: $e");
      return false;
    }
  }

  // Đặt mật khẩu mới
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await _apiService.post(
        "/api/auth/reset-password",
        body: {"email": email, "new_password": newPassword},
      );

      print("resetPassword: ${response.statusCode} - ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Error in resetPassword: $e");
      return false;
    }
  }

  // Đổi mật khẩu (khi đã đăng nhập)
  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final response = await _apiService.post(
        "/api/auth/change-password",
        body: {
          "current_password": currentPassword,
          "new_password": newPassword,
        },
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Đổi mật khẩu thành công"};
      } else {
        final body = jsonDecode(response.body);
        return {
          "success": false,
          "message": body["detail"] ?? "Đổi mật khẩu thất bại"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối server"};
    }
  }

  // Cập nhật thông tin profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(
        "/api/auth/profile",
        body: data,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Cập nhật thành công"};
      } else {
        final body = jsonDecode(response.body);
        return {
          "success": false,
          "message": body["detail"] ?? "Cập nhật thất bại"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối server"};
    }
  }
}