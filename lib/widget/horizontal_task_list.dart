import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';

class HorizontalTaskList extends StatelessWidget {
  final bool todayOnly;

  const HorizontalTaskList({super.key, this.todayOnly = true});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    List<Map<String, dynamic>> tasks = taskProvider.tasks;

    final today = DateTime.now();

    // Lọc task hôm nay nếu cần
    if (todayOnly) {
      tasks = tasks.where((task) {
        if (task['task_datetime'] == null) return false;
        final taskDate = DateTime.parse(task['task_datetime']);
        return taskDate.year == today.year &&
            taskDate.month == today.month &&
            taskDate.day == today.day;
      }).toList();
    }

    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No tasks available 🎉"),
      );
    }

    // Sắp xếp: chưa hoàn thành trước → theo thời gian
    tasks.sort((a, b) {
      final aCompleted = a['completed'] ?? false;
      final bCompleted = b['completed'] ?? false;
      if (aCompleted != bCompleted) return aCompleted ? 1 : -1;

      final dateA = DateTime.parse(a['task_datetime']);
      final dateB = DateTime.parse(b['task_datetime']);
      return dateA.compareTo(dateB);
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

// responsive width
    double cardWidthFactor = 0.42;
    if (screenWidth < 350) cardWidthFactor = 0.6;

// responsive height
    double cardHeight = screenHeight * 0.3;
    if (screenHeight < 600) cardHeight = 160;
    if (screenHeight > 900) cardHeight = 220;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return SizedBox(
            width: screenWidth * cardWidthFactor,
            child: _buildTaskCard(context, task),
          );
        },
      ),
    );


    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return SizedBox(
            width: screenWidth * cardWidthFactor,
            child: _buildTaskCard(context, task),
          );
        },
      ),
    );
  }

  // ----------------------- UI Card -----------------------
  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task) {
    final taskProvider = context.read<TaskProvider>();

    return GestureDetector(
      onTap: () {
        // Hiển thị chi tiết
        showDialog(
          context: context,
          builder: (context) {
            final taskDate = task['task_datetime'] != null
                ? DateTime.parse(task['task_datetime'])
                : null;
            final formattedDate = taskDate != null
                ? DateFormat('dd/MM/yyyy - HH:mm').format(taskDate)
                : '';

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(task['title'] ?? ''),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((task['category'] ?? '').isNotEmpty)
                    Text("📂 Category: ${task['category']}"),
                  if (formattedDate.isNotEmpty) Text("📅 $formattedDate"),
                  if ((task['notes'] ?? '').isNotEmpty)
                    Text("📝 ${task['notes']}"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Đóng"),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Card(
          color: task['completed'] == true ? Colors.grey[200] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task['title'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: task['completed'] == true
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color:
                    task['completed'] == true ? Colors.grey : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),

                // Category chip
                if ((task['category'] ?? '').isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(task['category']),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task['category'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // Time chip
                if (task['task_datetime'] != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('HH:mm')
                          .format(DateTime.parse(task['task_datetime'])),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const Spacer(),

                // Nút hoàn thành
                Center(
                  child: IconButton(
                    icon: Icon(
                      task['completed']
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: task['completed'] ? Colors.green : Colors.grey,
                    ),
                    onPressed: () async {
                      await taskProvider.toggleTaskCompletion(task);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------- Helper -----------------------
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'note':
        return Colors.blue;
      case 'calendar':
        return Colors.purple;
      case 'achievement':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}
