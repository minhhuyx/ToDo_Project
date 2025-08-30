// task_provider.dart
import 'package:flutter/material.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load tasks
  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedTasks = await _taskService.getTasks();
      _tasks = fetchedTasks;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new task
  Future<bool> addTask(Map<String, dynamic> taskData) async {
    try {
      final newTask = await _taskService.createTask(taskData);
      if (newTask != null) {
        _tasks.add(newTask);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update task
  Future<bool> updateTask(String taskId, Map<String, dynamic> taskData) async {
    try {
      final updatedTask = await _taskService.updateTask(taskId, taskData);
      if (updatedTask != null) {
        final index = _tasks.indexWhere((t) => t['task_id'] == taskId);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      final success = await _taskService.deleteTask(taskId);
      if (success) {
        _tasks.removeWhere((t) => t['task_id'] == taskId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle task completion (optimistic update)
  Future<void> toggleTaskCompletion(Map<String, dynamic> task) async {
    final oldCompleted = task['completed'] as bool;
    final newCompleted = !oldCompleted;

    // Optimistic update
    task['completed'] = newCompleted;
    notifyListeners();

    try {
      final taskData = {'completed': newCompleted};
      final result = await _taskService.updateTask(
        task['task_id'] as String,
        taskData,
      );

      if (result != null) {
        final index = _tasks.indexWhere((t) => t['task_id'] == task['task_id']);
        if (index != -1) {
          _tasks[index] = result;
          notifyListeners();
        }
      } else {
        // Rollback on failure
        task['completed'] = oldCompleted;
        notifyListeners();
        throw Exception('Không thể cập nhật task trên server');
      }
    } catch (e) {
      // Rollback on error
      task['completed'] = oldCompleted;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}