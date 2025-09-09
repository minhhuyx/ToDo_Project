import 'dart:io';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lấy thông tin user từ server
  Future<void> fetchUserInfo() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.getUserInfo();
      if (result["success"] == true) {
        _user = result["user"];
        _errorMessage = null;
      } else {
        _errorMessage = result["message"];
      }
    } catch (e) {
      _errorMessage = "Lỗi không xác định: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật tài khoản (username/email/password)
  Future<bool> updateAccount({
    String? username,
    String? email,
    String? currentPassword,
    String? newPassword,
    File? avatar, // ✅ thêm avatar
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.updateAccount(
      username: username,
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
      avatar: avatar, // ✅ truyền xuống service
    );

    _isLoading = false;

    if (result["success"] == true) {
      if (result["user"] != null) {
        _user = result["user"];
      } else {
        await fetchUserInfo();
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result["message"];
      notifyListeners();
      return false;
    }
  }


  /// Xóa tài khoản
  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.deleteAccount();
    _isLoading = false;

    if (result["success"] == true) {
      _user = null; // clear user local
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result["message"];
      notifyListeners();
      return false;
    }
  }

  /// Đăng ký tài khoản mới
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(username, email, password);
    _isLoading = false;

    if (result["success"] == true) {
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result["message"];
      notifyListeners();
      return false;
    }
  }
}
