import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';

import '../widget/TaskItemHorizontalWidget.dart';
import '../widget/analogclock.dart';
import '../widget/custom_color.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<UserProvider>(context, listen: false).fetchUserInfo(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Center(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.isLoading) {
                  return const CircularProgressIndicator();
                }

                if (userProvider.user == null) {
                  return Text(userProvider.errorMessage ?? "Không có dữ liệu");
                }

                final user = userProvider.user!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Have a good day, ${user['username'] ?? 'Unknown'}",
                        style: const TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: const ClockScreen(),
            ),
          ),
          SizedBox(height: 30),
          Center(child: Text("Task Today", style: TextStyle(fontSize: 25))),
          SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final now = DateTime.now();

                // Lọc chỉ task hôm nay
                final todayTasks =
                    taskProvider.tasks.where((task) {
                      final taskDate = task.taskDatetime;
                      return taskDate.year == now.year &&
                          taskDate.month == now.month &&
                          taskDate.day == now.day;
                    }).toList();

                // Sắp xếp theo thời gian (từ sớm đến muộn)
                todayTasks.sort(
                  (a, b) => a.taskDatetime.compareTo(b.taskDatetime),
                );

                return todayTasks.isEmpty
                    ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.faceLaughSquint,
                            color: AppColors.primary,
                          ),SizedBox(width: 10),
                          Text("Hôm nay không có task nào!",style: TextStyle(fontSize: 15),),
                        ],
                      ),
                    )
                    : ListView.builder(
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
          ),

          //   HorizontalTaskList(todayOnly: true),
        ],
      ),
    );
  }
}
