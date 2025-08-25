import 'dart:convert';
import 'api_service.dart';

class TaskService {
  final ApiService _api = ApiService();

  // =====================
  // Tạo task mới
  // =====================
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

  // =====================
  // Lấy tất cả task
  // =====================
  Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await _api.get("/tasks/", requireAuth: true);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      print('Get tasks failed: ${response.body}');
      return [];
    }
  }

  // =====================
  // Lấy 1 task theo id
  // =====================
  Future<Map<String, dynamic>?> getTask(String taskId) async {
    final response = await _api.get("/tasks/$taskId", requireAuth: true);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Get task failed: ${response.body}');
      return null;
    }
  }

  // =====================
  // Cập nhật task
  // =====================
  Future<Map<String, dynamic>?> updateTask(String taskId, Map<String, dynamic> task) async {
    final response = await _api.put(
      "/tasks/$taskId",
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

  // =====================
  // Xóa task
  // =====================
  Future<bool> deleteTask(String taskId) async {
    final response = await _api.delete("/tasks/$taskId", requireAuth: true);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Delete task failed: ${response.body}');
      return false;
    }
  }
}
