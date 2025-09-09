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
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.clock, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      "Ngày giờ: ${task.taskDatetime.day}/${task.taskDatetime.month}/${task.taskDatetime.year} "
                          "${task.taskDatetime.hour}:${task.taskDatetime.minute.toString().padLeft(2, '0')}",
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.check, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text("Trạng thái: ${task.completed ? "Hoàn thành" : "Chưa xong"}"),
                  ],
                ),
                const SizedBox(height: 10),
                if (task.note != null && task.note!.isNotEmpty)
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.noteSticky, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Text("Ghi chú: ${task.note}")),
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
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, // gọn, responsive
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: task.completed
              ? Colors.grey[300] : Colors.white ,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
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
                decoration: task.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: task.completed ? Colors.red : null, // màu gạch ngang
                decorationThickness: 2, // độ dày (nếu muốn chỉnh)
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
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
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
