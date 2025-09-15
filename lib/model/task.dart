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
  String userId;

  @HiveField(7)
  bool isSynced;

  @HiveField(8)
  bool isDeleted = false;

  @HiveField(9)
  bool isNew = false;

  @HiveField(10)
  int? notificationId;



  Task({
    required this.taskId,
    required this.title,
    required this.category,
    required this.taskDatetime,
    this.completed = false,
    this.note,
    required this.userId,
    this.isSynced = false,
    this.isDeleted = false,
    this.isNew = false,
    this.notificationId,
  });
}
