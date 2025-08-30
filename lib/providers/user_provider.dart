import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? _username;
  String? _email;

  String? get username => _username;
  String? get email => _email;

  Map<String, dynamic>? get user {
    if (_username == null && _email == null) return null;
    return {
      "username": _username,
      "email": _email,
    };
  }

  /// Gán user từ API (/me, update_account)
  void setUser(Map<String, dynamic>? userData) {
    _username = userData?['username'];
    _email = userData?['email'];
    notifyListeners();
  }

  /// Cập nhật trực tiếp khi chỉ đổi 1 vài field
  void updateUser({String? username, String? email}) {
    if (username != null) _username = username;
    if (email != null) _email = email;
    notifyListeners();
  }

  /// Xoá thông tin user (logout)
  void clearUser() {
    _username = null;
    _email = null;
    notifyListeners();
  }
}
