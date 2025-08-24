import 'package:flutter/material.dart';

import '../services/api_services.dart';
import '../widget/CustomTextField.dart';
import 'reset_password_page.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String message;
  VerifyOtpScreen({required this.email, required this.message});

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool loading = false;

  void _verifyOtp() async {
    setState(() => loading = true);

    final api = ApiService(); // Tạo instance như bạn đã làm
    bool success = await api.verifyOtp(widget.email, _otpController.text);

    setState(() => loading = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP không hợp lệ hoặc đã hết hạn")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Verify OTP",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 100),

            CustomTextField(controller: _otpController, labelText: "Nhập OTP"),
            SizedBox(height: 20),
            if (widget.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  widget.message,
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity, // full width
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _verifyOtp,
                child:
                    loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Xác thực"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // màu nền
                  foregroundColor: Colors.white, // màu chữ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // bán kính bo tròn
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
