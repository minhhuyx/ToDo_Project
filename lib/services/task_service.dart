import 'dart:convert';
import 'api_service.dart';

class TaskService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>?> createTask(Map<String, dynamic> task) async {
    final response = await _api.post(
      "/api/task/",
      body: task,
      requireAuth: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print('Create task failed: ${response.body}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    try {
      // Gọi API sử dụng cơ chế auto-refresh token
      final response = await _api.get("/api/task", requireAuth: true);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Get tasks failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get tasks error: $e');
      return [];
    }
  }


  Future<Map<String, dynamic>?> updateTask(String taskId, Map<String, dynamic> task) async {
    final response = await _api.put(
      "/api/task/$taskId",
      body: task,
      requireAuth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Update task failed: ${response.body}');
      return null;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      final response = await _api.delete("/api/task/$taskId", requireAuth: true);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Xóa task thất bại: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi khi gọi API deleteTask: $e');
      return false;
    }
  }
}
