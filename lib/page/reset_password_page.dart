import 'package:flutter/material.dart';
import 'package:ungdung_ghichu/services/auth_service.dart';

import '../services/api_service.dart';
import '../widget/CustomTextField.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  ResetPasswordScreen({required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool loading = false;


  void _resetPassword() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => loading = true);

    final api = AuthService();
    bool success = await api.resetPassword(
      widget.email,
      _passwordController.text,
    );

    setState(() => loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đổi mật khẩu thành công!")),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có lỗi xảy ra. Vui lòng thử lại!")),
      );
    }
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập lại mật khẩu";
    }
    if (value != _passwordController.text) {
      return "Mật khẩu nhập lại không khớp";
    }
    return null;
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionallySizedBox(
              widthFactor: 0.7, // chỉ chiếm 70% chiều rộng parent
              child: Text(
                "New Password",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 100),
            Form(
              key: _formKey,
              child: Column(
                children: [
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
                      onPressed: loading ? null : _resetPassword,
                      child: Text("Xác nhận"),
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

          ],
        ),
      ),
    );
  }
}