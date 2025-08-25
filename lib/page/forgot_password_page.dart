import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widget/CustomTextField.dart';
import 'verify_otp_page.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool loading = false;

  void _sendOtp() async {
    String email = _emailController.text.trim();

    String? error = validateEmail(email);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() => loading = true);

    final response = await AuthService().forgotPassword(email);

    setState(() => loading = false);

    if (response != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            email: email,
            message: response['message'], // truyền thông báo vào màn hình Verify
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể gửi OTP. Vui lòng thử lại.")),
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
                "Forget Password",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 100),
            CustomTextField(
              controller: _emailController,
              labelText: "Email",
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity, // full width
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _sendOtp ,
                child: Text("Gửi OTP"),
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
    );
  }
}
