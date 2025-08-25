import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ungdung_ghichu/page/home_page.dart';
import '../services/auth_service.dart';
import '../widget/CustomTextField.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool loading = false;

  void _login() async {
    setState(() => loading = true);
    bool success = await AuthService().login(
      _usernameController.text,
      _passwordController.text,
    );
    setState(() => loading = false);

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false, // Xóa hết stack
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sai username hoặc password")));
    }
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
            // widget sát lề trái
            FractionallySizedBox(
              widthFactor: 0.7, // chỉ chiếm 70% chiều rộng parent
              child: Text(
                "Welcome back! Glad to see you. Again!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    controller: _usernameController,
                    labelText: "Username",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập username";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: "Password",
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập mật khẩu";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Forgot Password?",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/forgot');
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, // full width
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : _login,
                      child: Text(loading ? "Loading..." : "Login"),
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
            SizedBox(height: 20),
            Center(
              child: RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(
                      text: "Register now",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              // Xử lý chuyển sang màn hình Register
                              Navigator.pushNamed(context, '/register');
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
