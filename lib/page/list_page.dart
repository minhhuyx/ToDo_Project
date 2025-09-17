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

  Widget _buildTaskExpansionTile({
    required String title,
    required List<Task> tasks,
    required bool initiallyExpanded,
    required Color titleColor, // màu cố định
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Theme(
      data: theme.copyWith(
        dividerColor: Colors.transparent,
        expansionTileTheme: ExpansionTileThemeData(
          backgroundColor: isDark ? theme.cardColor : Colors.white, // 🔥
          collapsedBackgroundColor: isDark ? theme.cardColor : Colors.white, // 🔥
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white, // 🔥
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ExpansionTile(
          key: ValueKey('${title}_${tasks.length}'),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor, // 🔥 giữ màu cố định
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          initiallyExpanded: initiallyExpanded,
          childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          children: tasks.map(
                (task) => Container(
              key: ValueKey(task.taskId),
              margin: const EdgeInsets.only(bottom: 4),
              child: TaskItemWidget(
                task: task,
                onToggleComplete: () async {
                  setState(() => task.completed = !task.completed);
                  try {
                    await taskProvider.updateTask(task);
                    if (mounted) {
                      _showSnackBar('Cập nhật trạng thái task', Colors.green);
                    }
                  } catch (e) {
                    if (mounted) setState(() => task.completed = !task.completed);
                    if (mounted) _showSnackBar('Lỗi cập nhật task', Colors.red);
                  }
                },
                onEdit: () {
                  showDialog(
                    context: context,
                    builder: (_) => UpdateTaskDialog(task: task),
                  );
                },
                onDelete: () async {
                  try {
                    await taskProvider.deleteTask(task.taskId);
                    if (mounted) {
                      _showSnackBar('Task đã được xóa', Colors.red);
                    }
                  } catch (e) {
                    if (mounted) _showSnackBar('Lỗi xóa task', Colors.red);
                  }
                },
              ),
            ),
          ).toList(),
        ),
      ),
    );
  }




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

    final theme = Theme.of(context);

    return StatefulBuilder(
      builder: (context, setModalState) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor, // ✅ theo theme (Light/Dark)
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Thanh kéo
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Text(
                    "Bộ lọc Task",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Trạng thái
                  Text("Trạng thái",
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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
                  Text("Danh mục",
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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
                  Text("Ngày",
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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
                        label: Text(
                          tempDate != null
                              ? "${tempDate!.day}/${tempDate!.month}/${tempDate!.year}"
                              : "Chọn ngày",
                        ),
                        selected: tempDate != null,
                        onSelected: (_) async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setModalState(() => tempDate = picked);
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
                            setState(() {
                              _selectedStatus = "all";
                              _selectedCategory = null;
                              _selectedDate = null;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Clear",
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            elevation: 0,
                            side: BorderSide(color: theme.colorScheme.error),
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
                              _selectedDate = tempDate;
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
            ),
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
        var filteredTasks =
            taskProvider.tasks.where((task) {
              // Lọc trạng thái
              if (_selectedStatus == "completed" && !task.completed)
                return false;
              if (_selectedStatus == "pending" && task.completed) return false;

              // Lọc category
              if (_selectedCategory != null &&
                  task.category != _selectedCategory)
                return false;

              // Lọc theo ngày
              if (_selectedDate != null) {
                final taskDate = task.taskDatetime;
                if (taskDate.year != _selectedDate!.year ||
                    taskDate.month != _selectedDate!.month ||
                    taskDate.day != _selectedDate!.day)
                  return false;
              }

              return true;
            }).toList();

        // 2️⃣ Gom nhóm
        final now = DateTime.now();
        List<Task> todayTasks = [];
        List<Task> futureTasks = [];
        List<Task> previousTasks = [];

        for (var task in filteredTasks) {
          final taskDay = DateTime(
            task.taskDatetime.year,
            task.taskDatetime.month,
            task.taskDatetime.day,
          );
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
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) => _buildFilterSheet(),
                        );
                      },
                      icon: const Icon(
                        Icons.filter_list,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        "Bộ lọc",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
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
              child:
                  filteredTasks.isNotEmpty
                      ? ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        children: [
                          if (todayTasks.isNotEmpty)
                            _buildTaskExpansionTile(
                              title: "Today (${todayTasks.length})",
                              tasks: todayTasks,
                              initiallyExpanded: true,
                              titleColor: AppColors.primary,
                            ),
                          if (futureTasks.isNotEmpty)
                            _buildTaskExpansionTile(
                              title: "Future (${futureTasks.length})",
                              tasks: futureTasks,
                              initiallyExpanded: false,
                              titleColor:
                                  Colors.blue,
                            ),
                          if (previousTasks.isNotEmpty)
                            _buildTaskExpansionTile(
                              title: "Previously (${previousTasks.length})",
                              tasks: previousTasks,
                              initiallyExpanded: false,
                              titleColor:
                                  Colors.red
                            ),
                        ],
                      )
                      : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.list,
                              size: 48,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Không có task nào",
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }
}
