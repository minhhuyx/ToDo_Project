import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
                  onPressed: () async {
                    var settingsBox = await Hive.openBox('settingsBox');
                    await settingsBox.put('hasSeenWelcome', true);

                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // màu nền
                    foregroundColor: Colors.white, // màu chữ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // bo tròn
                    ),
                  ),
                  child: const Text("Login"),
                ),
              ),

              SizedBox(height: 16),

              // Button Register
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    var settingsBox = await Hive.openBox('settingsBox');
                    await settingsBox.put('hasSeenWelcome', true);

                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text("Register"),
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
