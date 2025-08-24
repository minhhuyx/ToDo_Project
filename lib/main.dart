
import 'package:flutter/material.dart';
import 'package:ungdung_ghichu/page/forgot_password_page.dart';
import 'package:ungdung_ghichu/page/login_page.dart';
import 'package:ungdung_ghichu/page/register_page.dart';
import 'package:ungdung_ghichu/page/welcome_screen.dart';

import 'layout/main_layout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/home', // Trang đầu tiên mở
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => MainLayout(), // Đây là main layout với bottom nav
        '/forgot': (context) => ForgotPasswordScreen(),
      },
    );
  }
}