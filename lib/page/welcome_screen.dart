import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24), // khoảng cách lề
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ảnh minh họa
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/icon_welcome.png',
                    height: MediaQuery.of(context).size.height * 0.4,// đường dẫn đúng theo pubspec.yaml
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Button Login
              SizedBox(
                width: double.infinity, // full width
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // màu nền
                    foregroundColor: Colors.white, // màu chữ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        5,
                      ), // bán kính bo tròn
                    ),
                  ),
                  child: Text("Login"),
                ),
              ),

              SizedBox(height: 16),

              // Button Register
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white, // màu nền
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                    ),
                  ),
                  child: Text("Register"),
                ),
              ),

              SizedBox(height: 16),

              // Text link "Continue as a guest"
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home'); // guest page
                },
                child: Text(
                  "Continue as a guest",
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
