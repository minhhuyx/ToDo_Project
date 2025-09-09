import 'package:flutter/material.dart';
import '../model/task.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  List<Task> _pendingSyncTasks = [];

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.completed).length;
  int get pendingTasks => _tasks.where((task) => !task.completed).length;
  int get pendingSyncTasks => _pendingSyncTasks.length;

  TaskProvider() {
    loadTasks();
  }

  // Load all tasks from TaskService
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final tasks = await _taskService.readTasks();

      _tasks = tasks;
      _pendingSyncTasks = tasks.where((t) => t.isSynced == false).toList();
    } catch (e) {
      print('❌ Lỗi khi load tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    await _taskService.addTask(task);
    await loadTasks();
    _isLoading = false;
    notifyListeners();
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _taskService.updateTask(task);

      final index = _tasks.indexWhere((t) => t.taskId == task.taskId);
      if (index != -1) {
        _tasks[index] = task;
      }

      print("✅ Task ${task.taskId} cập nhật xong (local + sync)");
    } catch (e) {
      print("❌ Lỗi khi cập nhật task: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _taskService.deleteTask(taskId);

      _tasks.removeWhere((t) => t.taskId == taskId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print("Lỗi khi xóa task: $e");
      notifyListeners();
    }
  }

  // Simulate syncing pending tasks with a server
  Future<void> syncPendingTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      for (var task in _pendingSyncTasks) {
        task.note = null;
        await _taskService.updateTask(task);
      }
      await loadTasks();
    } catch (e) {
      print('Lỗi khi đồng bộ tasks: $e');
    }
  }
  // Refresh task data
  Future<void> syncAllTasks() async {
    await _taskService.syncAll();
    await loadTasks(); // load lại danh sách
  }
}