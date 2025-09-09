import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';



class AuthService {
  final ApiService _apiService = ApiService();
  final storage = const FlutterSecureStorage();

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
        final user = body;

        // ✅ lưu userId vào secure storage
        if (user["_id"] != null) {
          await storage.write(key: "userId", value: user["_id"].toString());
        }

        return {"success": true, "user": user};
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



  Future<Map<String, dynamic>> updateAccount({
    String? username,
    String? email,
    String? currentPassword,
    String? newPassword,
    File? avatar, // thêm để upload avatar
  }) async {
    try {
      final request = http.MultipartRequest(
        "PUT",
        Uri.parse("${ApiService.baseUrl}/api/auth/update_account"), // ✅ dùng class chứ không dùng instance
      );

      // Gắn access token
      final accessToken = await _apiService.getAccessToken();
      if (accessToken == null) {
        return {"success": false, "message": "Bạn chưa đăng nhập"};
      }
      request.headers['Authorization'] = "Bearer $accessToken";

      // Thêm field
      if (username != null && username.isNotEmpty) {
        request.fields['username'] = username;
      }

      if (email != null && email.isNotEmpty) {
        if (currentPassword == null || currentPassword.isEmpty) {
          return {
            "success": false,
            "message": "Cần nhập mật khẩu hiện tại để đổi email"
          };
        }
        request.fields['email'] = email;
        request.fields['current_password'] = currentPassword;
      }

      if (newPassword != null && newPassword.isNotEmpty) {
        if (currentPassword == null || currentPassword.isEmpty) {
          return {
            "success": false,
            "message": "Cần nhập mật khẩu hiện tại để đổi mật khẩu"
          };
        }
        request.fields['new_password'] = newPassword;
        request.fields['current_password'] = currentPassword;
      }

      if (avatar != null) {
        final stream = http.ByteStream(avatar.openRead());
        final length = await avatar.length();
        final multipartFile = http.MultipartFile(
          'avatar',
          stream,
          length,
          filename: avatar.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Gửi request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final bodyResp = jsonDecode(response.body);

      if (response.statusCode == 200 && bodyResp['success'] == true) {
        final newAccess = bodyResp['access_token'];
        String? existingRefresh = await _apiService.getRefreshToken();

        if (newAccess != null) {
          await _apiService.saveTokens(
            accessToken: newAccess,
            refreshToken: existingRefresh ?? "",
          );
        }

        return {
          "success": true,
          "message": bodyResp['message'],
          "avatar_url": bodyResp['avatar_url'],
          "access_token": newAccess,
        };
      } else {
        return {
          "success": false,
          "message": bodyResp['detail'] ?? bodyResp['message'] ?? "Cập nhật thất bại"
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
}