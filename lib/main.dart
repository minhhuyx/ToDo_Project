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
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');
  await dotenv.load(fileName: ".env");
  var settingsBox = await Hive.openBox('settingsBox');
  bool hasSeenWelcome = settingsBox.get('hasSeenWelcome', defaultValue: false);
  bool isLoggedIn = settingsBox.get('isLoggedIn', defaultValue: false);

  runApp(MyApp(
    hasSeenWelcome: hasSeenWelcome,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool hasSeenWelcome;
  final bool isLoggedIn;
  const MyApp({super.key, required this.hasSeenWelcome, required this.isLoggedIn});

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
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: !hasSeenWelcome
                ? '/welcome'
                : (isLoggedIn ? '/home' : '/login'),
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