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
        await _apiService.saveTokens(
          accessToken: data["access_token"],
          refreshToken: data["refresh_token"],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Lấy thông tin user từ token
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _apiService.get(
        "/api/auth/me",
        requireAuth: true,
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "user": body};
      } else {
        return {
          "success": false,
          "message": body["detail"] ?? "Không thể lấy thông tin người dùng",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Lỗi kết nối server: ${e.toString()}",
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.clearTokens();
  }

  // Kiểm tra user đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await _apiService..getRefreshToken();
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

  Future<Map<String, dynamic>> updateAccount({
    String? username,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    final Map<String, dynamic> body = {};
    if (username != null && username.isNotEmpty) body['username'] = username;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (newPassword != null && newPassword.isNotEmpty) {
      if (currentPassword == null || currentPassword.isEmpty) {
        return {
          "success": false,
          "message": "Cần nhập mật khẩu hiện tại để đổi mật khẩu"
        };
      }
      body['current_password'] = currentPassword;
      body['new_password'] = newPassword;
    }

    if (body.isEmpty) {
      return {"success": false, "message": "Không có dữ liệu để cập nhật"};
    }

    try {
      final response = await _apiService.put(
        "/api/auth/update_account",
        body: body,
        requireAuth: true,
      );

      final bodyResp = jsonDecode(response.body);

      if (response.statusCode == 200 && bodyResp['success'] == true) {
        // Nếu server trả về access token mới thì lưu lại
        final newAccess = bodyResp['access_token'];
        String? existingRefresh = await _apiService.getRefreshToken();

        if (newAccess != null) {
          await _apiService.saveTokens(
            accessToken: newAccess,
            refreshToken: existingRefresh ?? "", // giữ refresh token cũ
          );
        }

        return {
          "success": true,
          "message": bodyResp['message'],
          "user": bodyResp['user'], // username/email
          "access_token": newAccess, // token mới (nếu có)
        };
      } else {
        return {
          "success": false,
          "message": bodyResp['message'] ?? "Cập nhật thất bại"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối server"};
    }
  }





  /// Xóa tài khoản hiện tại
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _apiService.delete(
        "/api/auth/delete_account",
        requireAuth: true, // token tự động gửi
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          "success": true,
          "message": body["detail"] ?? "Account deleted",
          "tasksDeleted": body["tasks_deleted"] ?? 0,
          "userDeleted": body["user_deleted"] ?? 0,
        };
      } else {
        final body = jsonDecode(response.body);
        return {
          "success": false,
          "message": body["detail"] ?? "Delete failed",
        };
      }
    } catch (e) {
      print('Lỗi khi gọi API deleteAccount: $e');
      return {"success": false, "message": "Error connecting to server"};
    }
  }




}