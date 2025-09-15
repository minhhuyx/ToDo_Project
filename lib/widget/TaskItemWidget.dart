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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tileBackground = task.completed
        ? (isDark ? Colors.grey[800] : Colors.grey[300])
        : (isDark ? Colors.grey[900] : Colors.white);

    final titleColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return ListTile(
      title: Text(
        task.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: titleColor,
          decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
          decorationColor: task.completed ? Colors.red : null,
          decorationThickness: 2,
        ),
      ),
      subtitle: Text(
        '${task.category} • ${task.taskDatetime.day}/${task.taskDatetime.month}/${task.taskDatetime.year} '
            '${task.taskDatetime.hour}:${task.taskDatetime.minute.toString().padLeft(2, '0')}',
        style: TextStyle(color: subTextColor),
      ),
      tileColor: tileBackground,
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
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(task.title, style: TextStyle(color: titleColor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(FontAwesomeIcons.list, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text("Danh mục: ${task.category}", style: TextStyle(color: subTextColor))),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.clock, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      "Ngày giờ: ${task.taskDatetime.day}/${task.taskDatetime.month}/${task.taskDatetime.year} "
                          "${task.taskDatetime.hour}:${task.taskDatetime.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(color: subTextColor),
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
                      style: TextStyle(color: subTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (task.note != null && task.note!.isNotEmpty)
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.noteSticky, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Text("Ghi chú: ${task.note}", style: TextStyle(color: subTextColor))),
                    ],
                  ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Đóng", style: TextStyle(color: AppColors.primary)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
