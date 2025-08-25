import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widget/CustomTextField.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService apiAuth = AuthService();

  bool loading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => loading = true);
    final result = await apiAuth.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => loading = false);

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thành công!")),
      );

      Future.delayed(Duration(milliseconds: 1500), () {
        Navigator.pushReplacementNamed(context, '/login');
      });

    } else {
      // ❌ Nếu thất bại => hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"])),
      );
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập email";
    }
    // Regex cơ bản kiểm tra định dạng email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
      return "Email không hợp lệ";
    }
    return null; // hợp lệ
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập lại mật khẩu";
    }
    if (value != _passwordController.text) {
      return "Mật khẩu nhập lại không khớp";
    }
    return null;
  }

  String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return "Vui lòng nhập tên đăng nhập";
    }
    if (username.length < 3) {
      return "Tên đăng nhập phải có ít nhất 3 ký tự";
    }
    if (username.length > 20) {
      return "Tên đăng nhập tối đa 20 ký tự";
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return "Tên đăng nhập chỉ được chứa chữ, số và dấu gạch dưới (_)";
    }
    return null; // null = hợp lệ
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }
    if (password.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự";
    }
    // Nếu muốn mạnh hơn thì thêm quy tắc:
    // ít nhất 1 chữ hoa, 1 chữ thường, 1 số
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).+$').hasMatch(password)) {
       return "Mật khẩu phải có chữ hoa, chữ thường và số";
    }
    return null; // null = hợp lệ
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // trong suốt
        elevation: 0, // bỏ shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // nút back
          onPressed: () {
            Navigator.of(context).pop(); // quay lại màn hình trước
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionallySizedBox(
              widthFactor: 0.7, // chỉ chiếm 70% chiều rộng parent
              child: Text("Hello! Register to get started",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _usernameController,
                    labelText: "Username",
                    validator: validateUsername,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: _emailController,
                    labelText: "Email",
                    validator: validateEmail,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: "Password",
                    isPassword: true,
                    validator: validatePassword,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: "Confirm Password",
                    isPassword: true,
                    validator: validateConfirmPassword,
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, // full width
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : _register,
                      child: Text(loading ? "Loading..." : "Register"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // màu nền
                        foregroundColor: Colors.white, // màu chữ
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            5,
                          ), // bán kính bo tròn
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Center(
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(
                      text: "Login now",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Xử lý chuyển sang màn hình Register
                          Navigator.pushNamed(context, '/login');
                        },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
