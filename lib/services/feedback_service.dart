import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class FeedbackService {
  static Future<bool> sendFeedback(String email, String message) async {
    final url = "${ApiService.baseUrl}/api/settings/feedback";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_email": email,
          "message": message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["success"] == true;
      }
      return false;
    } catch (e) {
      print("Error sending feedback: $e");
      return false;
    }
  }
}
