import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widget/analogclock.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService apiAuth = AuthService();
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final data = await apiAuth.getUserInfo();
    setState(() {
      user = data;
    });
  }

  void _logout() async {
    await apiAuth.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30,),
        Center(
          child: user == null
              ? CircularProgressIndicator() // Hiển thị loading nếu chưa có dữ liệu
              : Text(
            "Have a good day, ${user!['username']}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 30,),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6, // điều chỉnh nhỏ/lớn
            child: const ClockScreen(),
          ),
        ),

      ],
    );
  }
}
