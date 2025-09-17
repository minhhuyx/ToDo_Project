import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ungdung_ghichu/page/setting_page.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widget/feedbackdialog.dart';

// Constants
class ProfileConstants {
  static const double avatarRadius = 60.0;
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
}

// Validation helper
class ProfileValidation {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$',
  );
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  static String? validateEmail(String email) {
    if (email.isEmpty) return null;
    if (!_emailRegex.hasMatch(email)) return 'Định dạng email không hợp lệ';
    return null;
  }

  static String? validateUsername(String username) {
    if (username.isEmpty) return null;
    if (username.length < ProfileConstants.minUsernameLength) {
      return 'Tên người dùng phải có ít nhất ${ProfileConstants.minUsernameLength} ký tự';
    }
    if (username.length > ProfileConstants.maxUsernameLength) {
      return 'Tên người dùng không được quá ${ProfileConstants.maxUsernameLength} ký tự';
    }
    if (!_usernameRegex.hasMatch(username))
      return 'Tên người dùng chỉ được chứa chữ cái, số và dấu gạch dưới';
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return null;
    if (!_passwordRegex.hasMatch(password)) {
      return 'Mật khẩu phải có ít nhất ${ProfileConstants.minPasswordLength} ký tự, bao gồm chữ hoa, chữ thường và số';
    }
    return null;
  }

  static String? validatePasswordMatch(String password, String confirm) {
    if (password.isEmpty) return null;
    if (password != confirm) return 'Mật khẩu xác nhận không khớp';
    return null;
  }

  static ProfileUpdateValidationResult validateProfileUpdate({
    required String username,
    required String email,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required String originalUsername,
    required String originalEmail,
  }) {
    final errors = <String>[];
    final isUsernameChanged = username != originalUsername;
    final isEmailChanged = email != originalEmail;
    final isPasswordChanged = newPassword.isNotEmpty;

    final usernameError = validateUsername(username);
    final emailError = validateEmail(email);
    if (usernameError != null) errors.add(usernameError);
    if (emailError != null) errors.add(emailError);

    if (isPasswordChanged) {
      final passwordError = validatePassword(newPassword);
      final confirmError = validatePasswordMatch(newPassword, confirmPassword);
      if (passwordError != null) errors.add(passwordError);
      if (confirmError != null) errors.add(confirmError);
    }

    final needsCurrentPassword = isEmailChanged || isPasswordChanged;
    if (needsCurrentPassword && currentPassword.isEmpty) {
      errors.add('Vui lòng nhập mật khẩu hiện tại để xác nhận thay đổi');
    }

    return ProfileUpdateValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      hasChanges: isUsernameChanged || isEmailChanged || isPasswordChanged,
      needsCurrentPassword: needsCurrentPassword,
    );
  }
}

class ProfileUpdateValidationResult {
  final bool isValid;
  final List<String> errors;
  final bool hasChanges;
  final bool needsCurrentPassword;

  ProfileUpdateValidationResult({
    required this.isValid,
    required this.errors,
    required this.hasChanges,
    required this.needsCurrentPassword,
  });
}

class ProfileUpdateData {
  final String username;
  final String email;
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final File? avatar;

  ProfileUpdateData({
    required this.username,
    required this.email,
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
    this.avatar,
  });
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  bool _isUpdatingProfile = false;
  String _version = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().fetchUserInfo());
    _loadAppVersion();
  }

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse(
      "https://www.termsfeed.com/live/c80aeecf-d3f8-41e4-8c0e-931623377e32",
    );
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // mở bằng Chrome
      );
      if (!launched) {
        // fallback nếu Chrome không mở được → dùng in-app webview
        await launchUrl(url, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      debugPrint("❌ Không mở được $url: $e");
    }
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = "${info.version}+${info.buildNumber}";
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final result = await showDialog<ProfileUpdateData>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => EditProfileDialog(
            username: user['username'] ?? '',
            email: user['email'] ?? '',
          ),
    );

    if (result != null) {
      await _handleProfileUpdate(result, user);
    }
  }

  Future<void> _handleProfileUpdate(
    ProfileUpdateData updateData,
    Map<String, dynamic> currentUser,
  ) async {
    setState(() => _isUpdatingProfile = true);
    try {
      // 1. Validation
      final validation = ProfileValidation.validateProfileUpdate(
        username: updateData.username,
        email: updateData.email,
        currentPassword: updateData.currentPassword,
        newPassword: updateData.newPassword,
        confirmPassword: updateData.confirmPassword,
        originalUsername: currentUser['username'] ?? '',
        originalEmail: currentUser['email'] ?? '',
      );

      if (!validation.isValid) {
        _showSnackBar(validation.errors.first, isError: true);
        return;
      }

      // Nếu không có thay đổi nào và không có avatar → dừng
      if (!validation.hasChanges && updateData.avatar == null) {
        _showSnackBar('Không có thay đổi nào để lưu');
        return;
      }

      // 2. Gọi provider update
      final success = await context.read<UserProvider>().updateAccount(
        username:
            updateData.username != (currentUser['username'] ?? '')
                ? updateData.username
                : null,
        email:
            updateData.email != (currentUser['email'] ?? '')
                ? updateData.email
                : null,
        currentPassword:
            validation.needsCurrentPassword ? updateData.currentPassword : null,
        newPassword:
            updateData.newPassword.isNotEmpty ? updateData.newPassword : null,
        avatar: updateData.avatar, // ✅ gửi file ảnh lên API
      );

      // 3. Hiển thị kết quả
      if (success) {
        _showSnackBar('Cập nhật thông tin thành công');
      } else {
        final error =
            context.read<UserProvider>().errorMessage ?? 'Cập nhật thất bại';
        _showSnackBar(error, isError: true);
      }
    } finally {
      setState(() => _isUpdatingProfile = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await _showConfirmDialog(
      title: 'Xác nhận xóa',
      content:
          'Bạn có chắc chắn muốn xóa tài khoản? Điều này sẽ xóa tất cả dữ liệu của bạn.',
      actionText: 'Xóa',
      isDestructive: true,
    );
    if (confirm == true) {
      final success = await context.read<UserProvider>().deleteAccount();
      if (success) {
        _showSnackBar('Xóa tài khoản thành công');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final error =
            context.read<UserProvider>().errorMessage ?? 'Xóa thất bại';
        _showSnackBar(error, isError: true);
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await _showConfirmDialog(
      title: 'Đăng xuất',
      content: 'Bạn có chắc chắn muốn đăng xuất?',
      actionText: 'Đăng xuất',
      isDestructive: true,
    );
    if (confirm == true) {
      await _authService.logout();
      var settingsBox = await Hive.openBox('settingsBox');
      await settingsBox.put('isLoggedIn', false);
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String actionText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? Colors.red : null,
                  foregroundColor: isDestructive ? Colors.white : null,
                ),
                child: Text(actionText),
              ),
            ],
          ),
    );
  }

  void _showFeatureNotImplemented(String feature) =>
      _showSnackBar('Tính năng $feature chưa được triển khai');

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading)
          return const Center(child: CircularProgressIndicator());
        final user = userProvider.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildUserAvatar(userProvider.user),
              const SizedBox(height: 20),
              _buildUserInfo(user),
              const SizedBox(height: 30),
              _buildMenuCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic>? user) {
    final avatarUrl = user?['avatar'];
    return CircleAvatar(
      radius: ProfileConstants.avatarRadius,
      backgroundColor: Colors.teal,
      backgroundImage:
          avatarUrl != null && avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
      child:
          avatarUrl == null || avatarUrl.isEmpty
              ? Icon(
                Icons.person,
                size: ProfileConstants.avatarRadius,
                color: Colors.white,
              )
              : null,
    );
  }

  Widget _buildUserInfo(Map<String, dynamic>? user) => Column(
    children: [
      Text(
        user?['username'] ?? 'Người dùng không xác định',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        user?['email'] ?? 'Không có email',
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),

    ],
  );

  Widget _buildMenuCard(BuildContext context) => Card(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
      side: const BorderSide(color: Colors.grey, width: 1),
    ),
    child: Column(
      children: [
        ProfileMenuItem(
          icon: Icons.edit,
          text: "Chỉnh sửa thông tin",
          onTap: () => _showEditProfileDialog(context),
        ),
        ProfileMenuItem(
          icon: Icons.settings,
          text: "Cài đặt",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingPage()),
            );
          },
        ),
        ProfileMenuItem(
          icon: Icons.privacy_tip,
          text: "Chính sách bảo mật",
          onTap: _openPrivacyPolicy,
        ),
        ProfileMenuItem(
          icon: Icons.delete,
          text: "Xóa tài khoản",
          onTap: _handleDeleteAccount,
        ),
        ProfileMenuItem(
          icon: Icons.message,
          text: "Phản hồi",
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const FeedbackDialog(),
            );
          },
        ),
        ProfileMenuItem(
          icon: Icons.logout,
          text: "Đăng xuất",
          iconColor: Colors.red,
          textColor: Colors.red,
          showDivider: false,
          onTap: () => _handleLogout(context),
        ),
        ProfileMenuItem(
          icon: Icons.info,
          text: "Phiên bản",
          trailing: Text(
            _version.isNotEmpty ? _version : "Đang tải...",
            style: const TextStyle(color: Colors.grey),
          ),
          showDivider: false,
        ),
      ],
    ),
  );
}

// --------------------- Dialog và MenuItem ---------------------

class EditProfileDialog extends StatefulWidget {
  final String username;
  final String email;

  const EditProfileDialog({
    Key? key,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _usernameError;
  String? _emailError;
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Chụp ảnh"),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Chọn từ thư viện"),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSave() {
    setState(() {
      // Reset errors
      _usernameError = ProfileValidation.validateUsername(_usernameController.text.trim());
      _emailError = ProfileValidation.validateEmail(_emailController.text.trim());
      _newPasswordError = ProfileValidation.validatePassword(_newPasswordController.text);
      _confirmPasswordError = ProfileValidation.validatePasswordMatch(
          _newPasswordController.text, _confirmPasswordController.text);

      final isEmailOrPasswordChanged = (_emailController.text.trim() != widget.email) ||
          _newPasswordController.text.isNotEmpty;

      if (isEmailOrPasswordChanged && _currentPasswordController.text.isEmpty) {
        _currentPasswordError = 'Vui lòng nhập mật khẩu hiện tại để xác nhận thay đổi';
      } else {
        _currentPasswordError = null;
      }
    });

    // Nếu không có lỗi thì return dữ liệu
    if (_usernameError == null &&
        _emailError == null &&
        _currentPasswordError == null &&
        _newPasswordError == null &&
        _confirmPasswordError == null) {
      final updateData = ProfileUpdateData(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
        avatar: _imageFile, // ✅ avatar đã chọn từ ImagePicker
      );
      Navigator.of(context).pop(updateData);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [theme.colorScheme.surface, theme.colorScheme.surfaceVariant]
                : [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.black26,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Icon(Icons.person,
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    "Chỉnh sửa thông tin",
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _usernameController,
                label: 'Tên người dùng',
                errorText: _usernameError,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                theme: theme,
              ),
              const SizedBox(height: 24),

              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Mật khẩu hiện tại',
                isVisible: _isCurrentPasswordVisible,
                onToggleVisibility: () =>
                    setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
                errorText: _currentPasswordError,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'Mật khẩu mới',
                isVisible: _isNewPasswordVisible,
                onToggleVisibility: () =>
                    setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                errorText: _newPasswordError,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu mới',
                isVisible: _isConfirmPasswordVisible,
                onToggleVisibility: () =>
                    setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                errorText: _confirmPasswordError,
                theme: theme,
              ),
              const SizedBox(height: 24),

              Center(
                child: Column(
                  children: [
                    _imageFile != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imageFile!,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                        : CircleAvatar(
                      radius: 48,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      child: Icon(Icons.person,
                          size: 48, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text("Chụp / Tải ảnh"),
                      onPressed: _showPickerOptions,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Hủy"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Lưu"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required ThemeData theme,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: theme.colorScheme.surface,
        errorText: errorText,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required ThemeData theme,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: theme.colorScheme.surface,
        errorText: errorText,
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showDivider;
  final Widget? trailing; // thêm

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.showDivider = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: iconColor ?? (isDark ? Colors.white : Colors.black),
          ),
          title: Text(
            text,
            style: TextStyle(
              color: textColor ?? (isDark ? Colors.white : Colors.black),
            ),
          ),
          trailing: trailing ??
              (onTap != null
                  ? Icon(Icons.arrow_forward_ios,
                  size: 16, color: isDark ? Colors.white70 : Colors.black54)
                  : null),
          tileColor: isDark ? Colors.grey[900] : Colors.white,
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
      ],
    );
  }
}

