import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../model/task.dart';
import '../providers/task_provider.dart';
import '../widget/TaskItemWidget.dart';
import '../widget/custom_color.dart';
import '../widget/dashbroard.dart';
import '../widget/update_task_dialog.dart';
import 'package:expandable/expandable.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  String _selectedStatus = "all";
  String? _selectedCategory;
  DateTime? _selectedDate;
  late TaskProvider taskProvider;

  @override
  void initState() {
    super.initState();
    taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // 1️⃣ Load task offline
    taskProvider.loadTasks();

    // 2️⃣ Tự động sync khi có mạng
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        taskProvider.syncAllTasks();
      }
    });
  }





  Widget _buildFilterSheet() {
    // Biến tạm để lưu lựa chọn
    String tempStatus = _selectedStatus;
    String? tempCategory = _selectedCategory;
    DateTime? tempDate = _selectedDate;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo hiện đại
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text("Bộ lọc Task",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Trạng thái
              const Text("Trạng thái", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text("Tất cả"),
                    selected: tempStatus == "all",
                    onSelected: (_) => setModalState(() => tempStatus = "all"),
                  ),
                  ChoiceChip(
                    label: const Text("Completed"),
                    selected: tempStatus == "completed",
                    onSelected: (_) => setModalState(() => tempStatus = "completed"),
                  ),
                  ChoiceChip(
                    label: const Text("Pending"),
                    selected: tempStatus == "pending",
                    onSelected: (_) => setModalState(() => tempStatus = "pending"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category
              const Text("Danh mục", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text("Tất cả"),
                    selected: tempCategory == null,
                    onSelected: (_) => setModalState(() => tempCategory = null),
                  ),
                  ChoiceChip(
                    label: const Text("Note"),
                    selected: tempCategory == "Note",
                    onSelected: (_) => setModalState(() => tempCategory = "Note"),
                  ),
                  ChoiceChip(
                    label: const Text("Calendar"),
                    selected: tempCategory == "Calendar",
                    onSelected: (_) => setModalState(() => tempCategory = "Calendar"),
                  ),
                  ChoiceChip(
                    label: const Text("Achievement"),
                    selected: tempCategory == "Achievement",
                    onSelected: (_) => setModalState(() => tempCategory = "Achievement"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ngày
              const Text("Ngày", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text("Tất cả"),
                    selected: tempDate == null,
                    onSelected: (_) => setModalState(() => tempDate = null),
                  ),
                  ChoiceChip(
                    label: Text(tempDate != null
                        ? "${tempDate!.day}/${tempDate!.month}/${tempDate!.year}"
                        : "Chọn ngày"),
                    selected: tempDate != null,
                    onSelected: (_) async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => tempDate = picked); // Cập nhật tempDate
                      }
                    },
                  ),

                ],
              ),
              const SizedBox(height: 24),

              // Clear & Apply
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Reset cả temp và selected
                        setState(() {
                          _selectedStatus = "all";
                          _selectedCategory = null;
                          _selectedDate = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Clear", style: TextStyle(color: Colors.red)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        side: const BorderSide(color: Colors.red),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatus = tempStatus;
                          _selectedCategory = tempCategory;
                          _selectedDate = tempDate; // Chỉ apply khi nhấn
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Apply"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // 1️⃣ Lọc tasks theo trạng thái, category và ngày (nếu chọn)
        var filteredTasks = taskProvider.tasks.where((task) {
          // Lọc trạng thái
          if (_selectedStatus == "completed" && !task.completed) return false;
          if (_selectedStatus == "pending" && task.completed) return false;

          // Lọc category
          if (_selectedCategory != null && task.category != _selectedCategory) return false;

          // Lọc theo ngày
          if (_selectedDate != null) {
            final taskDate = task.taskDatetime;
            if (taskDate.year != _selectedDate!.year ||
                taskDate.month != _selectedDate!.month ||
                taskDate.day != _selectedDate!.day) return false;
          }

          return true;
        }).toList();

        // 2️⃣ Gom nhóm
        final now = DateTime.now();
        List<Task> todayTasks = [];
        List<Task> futureTasks = [];
        List<Task> previousTasks = [];

        for (var task in filteredTasks) {
          final taskDay = DateTime(task.taskDatetime.year, task.taskDatetime.month, task.taskDatetime.day);
          final today = DateTime(now.year, now.month, now.day);

          if (taskDay == today) {
            todayTasks.add(task);
          } else if (taskDay.isAfter(today)) {
            futureTasks.add(task);
          } else {
            previousTasks.add(task);
          }
        }

        // 3️⃣ Sắp xếp từng nhóm
        todayTasks.sort((a, b) => a.taskDatetime.compareTo(b.taskDatetime));
        futureTasks.sort((a, b) => a.taskDatetime.compareTo(b.taskDatetime));
        previousTasks.sort((a, b) => a.taskDatetime.compareTo(b.taskDatetime));

        // 4️⃣ Hiển thị
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TaskStatsCard(
                    todayCount: todayTasks.length,
                    previousCount: previousTasks.length,
                    futureCount: futureTasks.length,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => _buildFilterSheet(),
                        );
                      },
                      icon: const Icon(Icons.filter_list, color: AppColors.primary),
                      label: const Text(
                        "Bộ lọc",
                        style: TextStyle(color:AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Nút filter


            // List tasks theo nhóm
            Expanded(
              child: filteredTasks.isNotEmpty
                  ? ListView(
                children: [
                  // Today
                  if (todayTasks.isNotEmpty)
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text("Today (${todayTasks.length})", style: TextStyle(color: AppColors.primary)),
                        initiallyExpanded: true,
                        children: todayTasks.map((task) => TaskItemWidget(
                          task: task,
                          onToggleComplete: () async {
                            task.completed = !task.completed;
                            await taskProvider.updateTask(task);
                            _showSnackBar('Cập nhật trạng thái task', Colors.green);
                          },
                          onEdit: () {
                            showDialog(context: context, builder: (_) => UpdateTaskDialog(task: task));
                          },
                          onDelete: () async {
                            await taskProvider.deleteTask(task.taskId);
                            _showSnackBar('Task đã được xóa', Colors.red);
                          },
                        )).toList(),
                      ),
                    ),

                  // Future
                  if (futureTasks.isNotEmpty)
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text("Future (${futureTasks.length})", style: TextStyle(color: AppColors.primary)),
                        initiallyExpanded: false,
                        children: futureTasks.map((task) => TaskItemWidget(
                          task: task,
                          onToggleComplete: () async {
                            task.completed = !task.completed;
                            await taskProvider.updateTask(task);
                            _showSnackBar('Cập nhật trạng thái task', Colors.green);
                          },
                          onEdit: () {
                            showDialog(context: context, builder: (_) => UpdateTaskDialog(task: task));
                          },
                          onDelete: () async {
                            await taskProvider.deleteTask(task.taskId);
                            _showSnackBar('Task đã được xóa', Colors.red);
                          },
                        )).toList(),
                      ),
                    ),

                  // Previously
                  if (previousTasks.isNotEmpty)
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text("Previously (${previousTasks.length})", style: TextStyle(color: AppColors.primary)),
                        initiallyExpanded: false,
                        children: previousTasks.map((task) => TaskItemWidget(
                          task: task,
                          onToggleComplete: () async {
                            task.completed = !task.completed;
                            await taskProvider.updateTask(task);
                            _showSnackBar('Cập nhật trạng thái task', Colors.green);
                          },
                          onEdit: () {
                            showDialog(context: context, builder: (_) => UpdateTaskDialog(task: task));
                          },
                          onDelete: () async {
                            await taskProvider.deleteTask(task.taskId);
                            _showSnackBar('Task đã được xóa', Colors.red);
                          },
                        )).toList(),
                      ),
                    ),
                ],
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.list, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      "Không có task nào",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )



          ],
        );
      },
    );
  }

}