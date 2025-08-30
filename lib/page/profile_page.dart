import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'dart:async';

// Constants
class ProfileConstants {
  static const double avatarRadius = 60.0;
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const Duration updateDebounce = Duration(milliseconds: 500);
}

// Validation helper class
class ProfileValidation {
  static final RegExp _emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );

  static final RegExp _passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$'
  );

  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  static String? validateEmail(String email) {
    if (email.isEmpty) return null;
    if (!_emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validateUsername(String username) {
    if (username.isEmpty) return null;
    if (username.length < ProfileConstants.minUsernameLength) {
      return 'Username must be at least ${ProfileConstants.minUsernameLength} characters';
    }
    if (username.length > ProfileConstants.maxUsernameLength) {
      return 'Username must be less than ${ProfileConstants.maxUsernameLength} characters';
    }
    if (!_usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return null;
    if (!_passwordRegex.hasMatch(password)) {
      return 'Password must be at least ${ProfileConstants.minPasswordLength} chars, include uppercase, lowercase, and number';
    }
    return null;
  }

  static String? validatePasswordMatch(String password, String confirm) {
    if (password.isEmpty) return null;
    if (password != confirm) {
      return 'Passwords do not match';
    }
    return null;
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Timer? _updateTimer;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final data = await AuthService().getUserInfo();

      if (!mounted) return;

      if (data['success'] == true && data['user'] != null) {
        final userData = data['user'] as Map<String, dynamic>;
        userProvider.setUser(userData);
      } else {
        userProvider.clearUser();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Không thể tải thông tin người dùng'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu người dùng: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final controllers = <TextEditingController>[];

    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _EditProfileDialog(),
      );

      if (result == true) {
        _loadUser(); // Refresh user data after successful update
      }
    } finally {
      // Controllers sẽ được dispose trong dialog
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await _showConfirmDialog(
      context,
      'Confirm Delete',
      'Are you sure you want to delete your account? This will remove all your tasks too.',
      'Delete',
    );

    if (confirm != true || !mounted) return;

    try {
      final result = await AuthService().deleteAccount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ??
              (result['success'] == true ? 'Account deleted' : 'Delete failed')),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await _showConfirmDialog(
      context,
      'Logout',
      'Are you sure you want to logout?',
      'Logout',
    );

    if (confirm != true || !mounted) return;

    try {
      await AuthService().logout();
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).clearUser();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog(
      BuildContext context,
      String title,
      String content,
      String actionText
      ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 30),
              _buildUserAvatar(),
              SizedBox(height: 20),
              _buildUserInfo(userProvider),
              SizedBox(height: 30),
              _buildMenuCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: ProfileConstants.avatarRadius,
      backgroundColor: Colors.teal,
      child: Icon(
        Icons.person,
        size: ProfileConstants.avatarRadius,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUserInfo(UserProvider userProvider) {
    final user = userProvider.user;
    return Column(
      children: [
        Text(
          user != null ? user['username'] ?? 'Unknown User' : 'Unknown User',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text(
          user != null ? user['email'] ?? 'No email' : 'No email',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(color: Colors.grey, width: 1),
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.edit,
            text: "Edit Profile",
            onTap: () => _showEditProfileDialog(context),
          ),
          ProfileMenuItem(
            icon: Icons.settings,
            text: "Settings",
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Settings chưa được triển khai')),
            ),
          ),
          ProfileMenuItem(
            icon: Icons.help,
            text: "Help & Support",
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Help & Support chưa được triển khai')),
            ),
          ),
          ProfileMenuItem(
            icon: Icons.delete,
            text: "Delete Account",
            onTap: _handleDeleteAccount,
          ),
          ProfileMenuItem(
            icon: Icons.logout,
            text: "Logout",
            iconColor: Colors.red,
            textColor: Colors.red,
            showDivider: false,
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }
}

// Tách EditProfileDialog thành widget riêng để dễ quản lý
class _EditProfileDialog extends StatefulWidget {
  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmController;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _formError;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _usernameController = TextEditingController(text: userProvider.username ?? '');
    _emailController = TextEditingController(text: userProvider.email ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_isUpdating) return;

    setState(() {
      _formError = null;
      _isUpdating = true;
    });

    try {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      final confirm = _confirmController.text.trim();

      final validationError = _validateForm(username, email, currentPassword, newPassword, confirm);
      if (validationError != null) {
        setState(() => _formError = validationError);
        return;
      }

      if (!mounted) return;

      final result = await AuthService().updateAccount(
        username: username.isNotEmpty ? username : null,
        email: email.isNotEmpty ? email : null,
        currentPassword: currentPassword.isNotEmpty ? currentPassword : null,
        newPassword: newPassword.isNotEmpty ? newPassword : null,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final me = await AuthService().getUserInfo();
        if (me['success'] == true && me['user'] != null) {
          Provider.of<UserProvider>(context, listen: false).setUser(me['user']);
        }

        if (mounted) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(result['message'] ?? "Update successful"),
              backgroundColor: Colors.green,
            ));
          Navigator.pop(context, true);
        }
      } else {
        setState(() => _formError = result['message'] ?? "Update failed");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _formError = 'Network error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }




  String? _validateForm(String username, String email, String currentPassword, String newPassword, String confirm) {
    // Check if any field has content
    if (username.isEmpty && email.isEmpty && newPassword.isEmpty) {
      return "No data to update";
    }

    // Validate individual fields
    final usernameError = ProfileValidation.validateUsername(username);
    if (usernameError != null) return usernameError;

    final emailError = ProfileValidation.validateEmail(email);
    if (emailError != null) return emailError;

    final passwordError = ProfileValidation.validatePassword(newPassword);
    if (passwordError != null) return passwordError;

    final passwordMatchError = ProfileValidation.validatePasswordMatch(newPassword, confirm);
    if (passwordMatchError != null) return passwordMatchError;

    // Check if current password is provided when needed
    if ((username.isNotEmpty || email.isNotEmpty || newPassword.isNotEmpty) && currentPassword.isEmpty) {
      return "Please enter current password to update account";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Profile"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: _usernameController,
              label: "Username",
              hint: "Enter new username (optional)",
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: "Email",
              hint: "Enter new email (optional)",
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),
            _buildPasswordField(
              controller: _currentPasswordController,
              label: "Current Password",
              hint: "Enter current password if changing anything",
              isVisible: _showCurrentPassword,
              onVisibilityToggle: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
            ),
            SizedBox(height: 12),
            _buildPasswordField(
              controller: _newPasswordController,
              label: "New Password",
              hint: "At least 6 chars, include uppercase, lowercase, number",
              isVisible: _showNewPassword,
              onVisibilityToggle: () => setState(() => _showNewPassword = !_showNewPassword),
            ),
            SizedBox(height: 12),
            _buildPasswordField(
              controller: _confirmController,
              label: "Confirm Password",
              hint: "Confirm new password",
              isVisible: _showConfirmPassword,
              onVisibilityToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
            if (_formError != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _formError!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () => Navigator.pop(context, false),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isUpdating ? null : _handleUpdate,
          child: _isUpdating
              ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text("Save"),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: onVisibilityToggle,
        ),
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showDivider;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor ?? Colors.black),
          title: Text(text, style: TextStyle(color: textColor ?? Colors.black)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          tileColor: Colors.white,
          onTap: onTap,
        ),
        if (showDivider) Divider(height: 1, color: Colors.grey[300]),
      ],
    );
  }
}