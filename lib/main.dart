import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:ungdung_ghichu/page/add_page.dart';
import 'package:ungdung_ghichu/providers/theme_provider.dart';
import 'package:ungdung_ghichu/providers/user_provider.dart';
import 'package:ungdung_ghichu/theme/app_theme.dart';
import 'package:ungdung_ghichu/services/notification_service.dart';
import 'page/forgot_password_page.dart';
import 'page/login_page.dart';
import 'page/register_page.dart';
import 'page/welcome_screen.dart';
import 'layout/main_layout.dart';
import 'model/task.dart';
import 'providers/task_provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,   // light theme custom
            darkTheme: AppTheme.darkTheme, // dark theme custom
            themeMode: themeProvider.themeMode, // do provider quản lý
            initialRoute: '/home',
            routes: {
              '/welcome': (context) => WelcomePage(),
              '/login': (context) => LoginPage(),
              '/register': (context) => RegisterPage(),
              '/home': (context) => MainLayout(),
              '/forgot': (context) => ForgotPasswordScreen(),
              '/add_task': (context) => AddPage(),
            },
          );
        },
      ),
    );
  }
}
