import 'package:flutter/material.dart';
import '../model/task.dart';
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
    _loadTasks();
  }

  // Load all tasks from TaskService
  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _taskService.getAllTasks();
      _pendingSyncTasks = _tasks.where((task) => task.note == 'pending_sync').toList();
    } catch (e) {
      print('Lỗi khi tải tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskService.addTask(task);
      await _loadTasks();
    } catch (e) {
      print('Lỗi khi thêm task: $e');
    }
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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print("Lỗi khi cập nhật task: $e");
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
      await _loadTasks();
    } catch (e) {
      print('Lỗi khi đồng bộ tasks: $e');
    }
  }

  // Refresh task data
  Future<void> refresh() async {
    await _loadTasks();
  }
}