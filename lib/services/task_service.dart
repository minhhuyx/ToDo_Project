import 'package:hive/hive.dart';
import '../model/task.dart';

class TaskService {
  static const String _boxName = 'tasksBox';

  // Mở box
  Future<Box<Task>> _openBox() async {
    return await Hive.openBox<Task>(_boxName);
  }

  // CREATE
  Future<void> addTask(Task task) async {
    var box = await _openBox();
    await box.put(task.taskId, task); // dùng taskId làm key
  }

  // READ ALL
  Future<List<Task>> getAllTasks() async {
    var box = await _openBox();
    return box.values.toList();
  }

  // READ BY ID
  Future<Task?> getTask(int taskId) async {
    var box = await _openBox();
    return box.get(taskId);
  }

  // UPDATE
  Future<void> updateTask(Task task) async {
    var box = await _openBox();

    // tìm Task có cùng taskId (UUID)
    final existingTask = box.values.firstWhere(
          (t) => t.taskId == task.taskId,
      orElse: () => throw Exception("Task with id ${task.taskId} not found"),
    );

    // cập nhật giá trị
    existingTask.title = task.title;
    existingTask.category = task.category;
    existingTask.taskDatetime = task.taskDatetime;
    existingTask.completed = task.completed;
    existingTask.note = task.note;
    existingTask.userId = task.userId;

    await existingTask.save(); // save lại object trong Hive
  }


  // DELETE
  Future<void> deleteTask(String taskId) async {
    var box = await _openBox();

    try {
      final taskToDelete = box.values.firstWhere(
            (task) => task.taskId == taskId,
        orElse: () => throw Exception('Task not found'),
      );

      await taskToDelete.delete();
    } catch (e) {
      throw Exception("Lỗi khi xóa task: $e");
    }
  }

  // DELETE ALL
  Future<void> deleteAllTasks() async {
    var box = await _openBox();
    await box.clear();
  }
}
