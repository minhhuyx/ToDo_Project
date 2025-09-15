import 'package:flutter/material.dart';
import 'package:ungdung_ghichu/widget/custom_color.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Cài đặt",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color, // ✅ đổi màu theo theme
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Thông báo"),
            value: _isNotificationEnabled,
            onChanged: (value) {
              setState(() {
                _isNotificationEnabled = value;
              });

              // 👉 bạn có thể lưu vào SharedPreferences hoặc gọi API
              debugPrint("Thông báo: ${value ? "Bật" : "Tắt"}");
            },
            secondary: const Icon(Icons.notifications),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text("Giao diện"),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value); // ✅ lưu và notifyListeners()
              debugPrint("Chế độ giao diện: ${value ? "Tối" : "Sáng"}");
            },
            secondary: const Icon(Icons.format_paint),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
