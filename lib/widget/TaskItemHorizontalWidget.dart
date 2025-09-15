import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../model/task.dart';
import 'custom_color.dart';

class TaskItemHorizontalWidget extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;

  const TaskItemHorizontalWidget({
    super.key,
    required this.task,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = task.completed
        ? (isDark ? Colors.grey[800] : Colors.grey[300])
        : (isDark ? Colors.grey[900] : Colors.white);

    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              task.title,
              style: TextStyle(color: textColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(FontAwesomeIcons.list, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text("Danh mục: ${task.category}", style: TextStyle(color: subTextColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
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
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
                decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: task.completed ? Colors.red : null,
                decorationThickness: 2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),
            // Category
            Row(
              children: [
                Icon(FontAwesomeIcons.list, size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.category,
                    style: TextStyle(fontSize: 11, color: subTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Datetime
            Row(
              children: [
                Icon(FontAwesomeIcons.clock, size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "${task.taskDatetime.day}/${task.taskDatetime.month}/${task.taskDatetime.year} "
                        "${task.taskDatetime.hour}:${task.taskDatetime.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 11, color: subTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Check button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    task.completed ? Icons.check_circle : Icons.circle_outlined,
                    color: task.completed ? AppColors.primary : Colors.grey,
                    size: 20,
                  ),
                  onPressed: onToggleComplete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
