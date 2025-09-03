import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widget/TaskItemHorizontalWidget.dart';
import '../widget/analogclock.dart';
import '../widget/horizontal_task_list.dart';
import '../widget/update_task_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = 'Unknown User';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30,),
          Center(
            child: Text(
              "Have a good day, $username",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 30,),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: const ClockScreen(),
            ),
          ),
          SizedBox(height: 30,),
          Center(child: Text("Task Today", style: TextStyle(fontSize: 25),),),
          SizedBox(height: 20,),
          SizedBox(
            height: 180,
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final now = DateTime.now();

                // Lọc chỉ task hôm nay
                final todayTasks = taskProvider.tasks.where((task) {
                  final taskDate = task.taskDatetime;
                  return taskDate.year == now.year &&
                      taskDate.month == now.month &&
                      taskDate.day == now.day;
                }).toList();

                // Sắp xếp theo thời gian (từ sớm đến muộn)
                todayTasks.sort((a, b) => a.taskDatetime.compareTo(b.taskDatetime));

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: todayTasks.length,
                  itemBuilder: (context, index) {
                    final task = todayTasks[index];
                    return TaskItemHorizontalWidget(
                      task: task,
                      onToggleComplete: () async {
                        task.completed = !task.completed;
                        await taskProvider.updateTask(task);
                      },
                    );
                  },
                );
              },
            ),
          )




          //   HorizontalTaskList(todayOnly: true),
        ],
      ),
    );
  }
}