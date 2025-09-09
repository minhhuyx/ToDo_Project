import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../model/task.dart';
import 'api_service.dart';
import 'dart:convert';

class TaskService {
  static const String _boxName = 'tasksBox';
  final ApiService _apiService = ApiService();

  // Mở box
  Future<Box<Task>> _openBox() async {
    return await Hive.openBox<Task>(_boxName);
  }

  // CREATE
  Future<void> addTask(Task task) async {
    final box = await _openBox();

    // luôn lưu offline trước
    task.isNew = true;
    task.isSynced = false;
    await box.put(task.taskId, task);

    // Thử đồng bộ server nếu có mạng
    try {
      final response = await _apiService.post(
        "/api/task/",
        body: {
          "task_id": task.taskId,
          "title": task.title,
          "category": task.category,
          "task_datetime": task.taskDatetime.toIso8601String(),
          "completed": task.completed,
          "note": task.note,
        },
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        task.isSynced = true;
        task.isNew = false; // ✅ sau khi sync xong, không còn là task mới
        await task.save();
        print("✅ Task sync thành công");
      } else {
        print("⚠️ Sync thất bại: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Offline, chỉ lưu Hive: $e");
    }
  }

  // READ ALL
  Future<List<Task>> readTasks() async {
    var box = await _openBox();

    // 🔍 Kiểm tra mạng
    var connectivityResult = await Connectivity().checkConnectivity();
    final hasNetwork = connectivityResult != ConnectivityResult.none;

    if (hasNetwork) {
      try {
        final response = await _apiService.get("/api/task/", requireAuth: true);
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);

          List<Task> tasks = [];
          for (var item in data) {
            final task = Task(
              taskId: item["task_id"],
              title: item["title"],
              category: item["category"],
              taskDatetime: DateTime.parse(item["task_datetime"]),
              completed: item["completed"],
              note: item["note"],
              userId: item["user_id"],
              isSynced: true,
            );

            await box.put(task.taskId, task); // update Hive
            tasks.add(task);
          }
          return tasks;
        }
      } catch (e) {
        print("⚠️ Lỗi fetch server, fallback đọc Hive: $e");
      }
    }

    // 🔴 Không có mạng hoặc lỗi → đọc Hive
    return box.values.toList();
  }


  // UPDATE
  Future<void> updateTask(Task task) async {
    var box = await _openBox();

    // Tìm task trong Hive
    final existingTask = box.values.firstWhere(
          (t) => t.taskId == task.taskId,
      orElse: () => throw Exception("Task with id ${task.taskId} not found"),
    );

    // Cập nhật giá trị
    existingTask.title = task.title;
    existingTask.category = task.category;
    existingTask.taskDatetime = task.taskDatetime;
    existingTask.completed = task.completed;
    existingTask.note = task.note;
    existingTask.userId = task.userId;

    // 🔥 Vì đây là update → không phải task mới nữa
    existingTask.isNew = false;

    var connectivityResult = await Connectivity().checkConnectivity();
    final hasNetwork = connectivityResult != ConnectivityResult.none;

    if (hasNetwork) {
      try {
        final response = await _apiService.put(
          "/api/task/${task.taskId}",
          body: {
            "title": task.title,
            "category": task.category,
            "task_datetime": task.taskDatetime.toIso8601String(),
            "completed": task.completed,
            "note": task.note,
          },
          requireAuth: true,
        );

        if (response.statusCode == 200) {
          print("✅ Task ${task.taskId} update server thành công");
          existingTask.isSynced = true;
        } else {
          print("⚠️ Update server thất bại, status: ${response.statusCode}");
          existingTask.isSynced = false;
        }
      } catch (e) {
        print("⚠️ Lỗi khi update server: $e");
        existingTask.isSynced = false;
      }
    } else {
      // 🔴 Offline → chỉ lưu local, chờ sync sau
      existingTask.isSynced = false;
    }

    // Lưu lại vào Hive sau cùng
    await existingTask.save();
  }


  Future<void> deleteTask(String taskId) async {
    var box = await _openBox();

    final task = box.values.firstWhere(
          (t) => t.taskId == taskId,
      orElse: () => throw Exception('Task not found'),
    );

    var connectivityResult = await Connectivity().checkConnectivity();
    final hasNetwork = connectivityResult != ConnectivityResult.none;

    if (hasNetwork) {
      // 🟢 Online: xóa server luôn
      try {
        final response = await _apiService.delete(
          "/api/task/$taskId",
          requireAuth: true,
        );

        if (response.statusCode == 200) {
          print("✅ Task $taskId đã xóa server thành công");
          await task.delete(); // chỉ xóa Hive nếu server xóa ok
          return;
        }
      } catch (e) {
        print("⚠️ Lỗi khi xóa server: $e");
      }
    }

    // 🔴 Offline hoặc lỗi API → chỉ đánh dấu
    task.isDeleted = true;
    task.isSynced = false;
    await task.save();

    print("🗑️ Task $taskId đánh dấu xóa (chờ sync)");
  }

  Future<void> syncAll() async {
    var box = await _openBox();

    // 1️⃣ Sync task mới (POST)
    var newTasks = box.values
        .where((t) => t.isSynced == false && t.isDeleted == false && t.isNew)
        .toList();

    for (var task in newTasks) {
      try {
        final response = await _apiService.post(
          "/api/task/",
          body: {
            "task_id": task.taskId,
            "title": task.title,
            "category": task.category,
            "task_datetime": task.taskDatetime.toIso8601String(),
            "completed": task.completed,
            "note": task.note,
          },
          requireAuth: true,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          task.isSynced = true;
          task.isNew = false;
          await task.save();
          print("✅ Task ${task.taskId} đã sync CREATE thành công");
        }
      } catch (e) {
        print("⚠️ Task ${task.taskId} chưa sync CREATE (offline): $e");
      }
    }

    // 2️⃣ Sync task update (PUT)
    var updatedTasks = box.values
        .where((t) => t.isSynced == false && t.isDeleted == false && !t.isNew)
        .toList();

    for (var task in updatedTasks) {
      try {
        final response = await _apiService.put(
          "/api/task/${task.taskId}",
          body: {
            "title": task.title,
            "category": task.category,
            "task_datetime": task.taskDatetime.toIso8601String(),
            "completed": task.completed,
            "note": task.note,
          },
          requireAuth: true,
        );

        if (response.statusCode == 200) {
          task.isSynced = true;
          await task.save();
          print("✅ Task ${task.taskId} đã sync UPDATE thành công");
        }
      } catch (e) {
        print("⚠️ Task ${task.taskId} chưa sync UPDATE (offline): $e");
      }
    }

    // 3️⃣ Sync task xóa (DELETE)
    var deletedTasks = box.values.where((t) => t.isDeleted).toList();

    for (var task in deletedTasks) {
      try {
        final response = await _apiService.delete(
          "/api/task/${task.taskId}",
          requireAuth: true,
        );

        if (response.statusCode == 200) {
          print("✅ Task ${task.taskId} đã xóa server thành công");
          await task.delete(); // xoá hẳn khỏi Hive
        }
      } catch (e) {
        print("⚠️ Lỗi khi xóa task ${task.taskId} trên server: $e");
      }
    }
  }

}

