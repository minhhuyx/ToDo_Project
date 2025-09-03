import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/task.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    Box<Task> box = Hive.box<Task>('tasksBox');

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách Task")),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Task> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("Chưa có task nào!"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index);
              final Task? task = box.get(key);

              if (task == null) return const SizedBox();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📂 Category: ${task.category}"),
                      Text(
                        "📅 Date: ${task.taskDatetime.day}/${task.taskDatetime.month}/${task.taskDatetime.year} "
                            "${task.taskDatetime.hour}:${task.taskDatetime.minute.toString().padLeft(2, '0')}",
                      ),
                      Text("✅ Completed: ${task.completed ? "Yes" : "No"}"),
                      if (task.note != null && task.note!.isNotEmpty)
                        Text("📝 Note: ${task.note}"),
                      Text("🔑 Hive Key: $key"), // để debug xem Hive lưu key nào
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => box.delete(key),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
