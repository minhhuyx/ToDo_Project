import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:ungdung_ghichu/page/add_page.dart';
import 'package:ungdung_ghichu/providers/user_provider.dart';
import 'page/forgot_password_page.dart';
import 'page/login_page.dart';
import 'page/register_page.dart';
import 'page/welcome_screen.dart';
import 'layout/main_layout.dart';
import 'model/task.dart';
import 'providers/task_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TaskProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()), // thêm dòng này
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => MainLayout(),
        '/forgot': (context) => ForgotPasswordScreen(),
        '/add_task': (context) => AddPage(),
      },
    ),
  );
  }
}