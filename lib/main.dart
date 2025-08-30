import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:ungdung_ghichu/page/forgot_password_page.dart';
import 'package:ungdung_ghichu/page/login_page.dart';
import 'package:ungdung_ghichu/page/register_page.dart';
import 'package:ungdung_ghichu/page/welcome_screen.dart';
import 'layout/main_layout.dart';
import 'providers/task_provider.dart';
import 'providers/user_provider.dart';
import '../model/task_model.dart';// import TaskProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  // Mở box lưu Task
  await Hive.openBox<Task>('tasks');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child:  MyApp(),
    ),
  );
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
