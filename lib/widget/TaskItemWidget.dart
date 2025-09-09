import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../model/task.dart';
import 'custom_color.dart';

class TaskItemWidget extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          decoration:
              task.completed ? TextDecoration.lineThrough : TextDecoration.none,
          decorationColor: task.completed ? Colors.red : null, // màu gạch ngang
          decorationThickness: 2, // độ dày (nếu muốn chỉnh)
        ),
      ),
      subtitle: Text(
        '${task.category} • ${task.taskDatetime.day}/${task.taskDatetime.month}/${task.taskDatetime.year} '
        '${task.taskDatetime.hour}:${task.taskDatetime.minute.toString().padLeft(2, '0')}',
      ),
      tileColor: task.completed ? Colors.grey[300] : Colors.white, // màu nền
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              task.completed ? Icons.check_circle : Icons.circle_outlined,
              color: task.completed ? AppColors.primary : Colors.grey,
            ),
            onPressed: onToggleComplete,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),

      /// 👇 Bổ sung click vào tile
      onTap: () {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(task.title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.list, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(child: Text("Danh mục: ${task.category}")),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.clock, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          "Ngày giờ: "
                          "${task.taskDatetime.day}/${task.taskDatetime.month}/${task.taskDatetime.year} "
                          "${task.taskDatetime.hour}:${task.taskDatetime.minute.toString().padLeft(2, '0')}",
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.check, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          "Trạng thái: ${task.completed ? "Hoàn thành" : "Chưa xong"}",
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        if (task.note != null && task.note!.isNotEmpty) ...[
                          Icon(
                            FontAwesomeIcons.noteSticky,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text("Ghi chú: ${task.note}"),
                        ],
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text("Đóng"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
        );
      },
    );
  }
}
