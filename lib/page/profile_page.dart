import 'package:flutter/material.dart';

// Constants
class ProfileConstants {
  static const double avatarRadius = 60.0;
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
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
  bool _isLoading = false;
  Map<String, dynamic> _user = {
    'username': 'demo_user',
    'email': 'demo@example.com',
  };

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EditProfileDialog(
        username: _user['username'],
        email: _user['email'],
        onSave: (username, email) {
          setState(() {
            _user['username'] = username;
            _user['email'] = email;
          });
          _showSnackBar('Profile updated (front-end only)', Colors.green);
        },
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await _showConfirmDialog(
      context,
      'Confirm Delete',
      'Are you sure you want to delete your account? This will remove all your tasks too.',
      'Delete',
    );
    if (confirm == true) {
      _showSnackBar('Account deleted (front-end only)', Colors.red);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await _showConfirmDialog(
      context,
      'Logout',
      'Are you sure you want to logout?',
      'Logout',
    );
    if (confirm == true) {
      _showSnackBar('Logged out (front-end only)', Colors.blue);
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 30),
          _buildUserAvatar(),
          SizedBox(height: 20),
          _buildUserInfo(),
          SizedBox(height: 30),
          _buildMenuCard(context),
        ],
      ),
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

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          _user['username'] ?? 'Unknown User',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text(
          _user['email'] ?? 'No email',
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
            onTap: () => _showSnackBar('Settings not implemented', Colors.orange),
          ),
          ProfileMenuItem(
            icon: Icons.help,
            text: "Help & Support",
            onTap: () => _showSnackBar('Help & Support not implemented', Colors.orange),
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

class _EditProfileDialog extends StatefulWidget {
  final String username;
  final String email;
  final Function(String, String) onSave;

  const _EditProfileDialog({
    required this.username,
    required this.email,
    required this.onSave,
  });

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  String? _formError;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    setState(() {
      _formError = null;
      _isUpdating = true;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    final usernameError = ProfileValidation.validateUsername(username);
    if (usernameError != null) {
      setState(() {
        _formError = usernameError;
        _isUpdating = false;
      });
      return;
    }

    final emailError = ProfileValidation.validateEmail(email);
    if (emailError != null) {
      setState(() {
        _formError = emailError;
        _isUpdating = false;
      });
      return;
    }

    widget.onSave(username, email);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Profile"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                hintText: "Enter new username (optional)",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter new email (optional)",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
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