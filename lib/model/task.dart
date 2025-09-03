import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String taskId;

  @HiveField(1)
  String title;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime taskDatetime;

  @HiveField(4)
  bool completed;

  @HiveField(5)
  String? note;

  @HiveField(6)
  int userId;

  Task({
    required this.taskId,
    required this.title,
    required this.category,
    required this.taskDatetime,
    this.completed = false,
    this.note,
    required this.userId,
  });
}
