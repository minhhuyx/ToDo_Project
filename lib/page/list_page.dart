import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widget/update_task_dialog.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  // Filter states
  String _selectedStatus = "all";
  DateTime? _selectedDateFrom;
  DateTime? _selectedDateTo;
  String? _selectedCategory;
  String _selectedDateRange = "all";

  // Collapsed groups state
  Map<String, bool> _collapsedGroups = {
    'Previously': false,
    'Today': false,
    'Future': false,
  };

  // Cache for grouped tasks
  Map<String, List<Map<String, dynamic>>> _cachedGroupedTasks = {};
  String? _lastTaskListHash;

  @override
  void initState() {
    super.initState();
    // Load tasks when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  void _openFilterBottomSheet() {
    final tasks = context.read<TaskProvider>().tasks;
    final categories = tasks
        .map((t) => t['category'] as String)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Filter",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Scrollable content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status filter
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Status",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text("All"),
                                selected: _selectedStatus == "all",
                                onSelected: (_) => setModalState(() => _selectedStatus = "all"),
                              ),
                              ChoiceChip(
                                label: const Text("Completed"),
                                selected: _selectedStatus == "completed",
                                onSelected: (_) => setModalState(() => _selectedStatus = "completed"),
                              ),
                              ChoiceChip(
                                label: const Text("Pending"),
                                selected: _selectedStatus == "pending",
                                onSelected: (_) => setModalState(() => _selectedStatus = "pending"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Time filter
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Time",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              ChoiceChip(
                                label: const Text("All"),
                                selected: _selectedDateRange == "all",
                                onSelected: (_) {
                                  setModalState(() {
                                    _selectedDateRange = "all";
                                    _selectedDateFrom = null;
                                    _selectedDateTo = null;
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text("Today"),
                                selected: _selectedDateRange == "today",
                                onSelected: (_) {
                                  setModalState(() {
                                    _selectedDateRange = "today";
                                    final today = DateTime.now();
                                    _selectedDateFrom = DateTime(today.year, today.month, today.day);
                                    _selectedDateTo = DateTime(today.year, today.month, today.day, 23, 59, 59);
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text("This Week"),
                                selected: _selectedDateRange == "this_week",
                                onSelected: (_) {
                                  setModalState(() {
                                    _selectedDateRange = "this_week";
                                    final now = DateTime.now();
                                    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                                    _selectedDateFrom = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
                                    _selectedDateTo = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + 6, 23, 59, 59);
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text("This Month"),
                                selected: _selectedDateRange == "this_month",
                                onSelected: (_) {
                                  setModalState(() {
                                    _selectedDateRange = "this_month";
                                    final now = DateTime.now();
                                    _selectedDateFrom = DateTime(now.year, now.month, 1);
                                    _selectedDateTo = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text("Custom"),
                                selected: _selectedDateRange == "custom",
                                onSelected: (_) {
                                  setModalState(() {
                                    _selectedDateRange = "custom";
                                  });
                                },
                              ),
                            ],
                          ),

                          // Custom date picker
                          if (_selectedDateRange == "custom") ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Pick a date and time",
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            final date = await showDatePicker(
                                              context: context,
                                              initialDate: _selectedDateFrom ?? DateTime.now(),
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime(2030),
                                            );
                                            if (date != null) {
                                              setModalState(() {
                                                _selectedDateFrom = date;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.blue),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "From Date",
                                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                                                ),
                                                Text(
                                                  _selectedDateFrom != null
                                                      ? "${_selectedDateFrom!.day}/${_selectedDateFrom!.month}/${_selectedDateFrom!.year}"
                                                      : "Choose Date",
                                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(" - "),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            final date = await showDatePicker(
                                              context: context,
                                              initialDate: _selectedDateTo ?? DateTime.now(),
                                              firstDate: _selectedDateFrom ?? DateTime(2020),
                                              lastDate: DateTime(2030),
                                            );
                                            if (date != null) {
                                              setModalState(() {
                                                _selectedDateTo = DateTime(date.year, date.month, date.day, 23, 59, 59);
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.blue),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "To Date",
                                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                                                ),
                                                Text(
                                                  _selectedDateTo != null
                                                      ? "${_selectedDateTo!.day}/${_selectedDateTo!.month}/${_selectedDateTo!.year}"
                                                      : "Choose Date",
                                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Category filter
                          if (categories.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Category",
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                ChoiceChip(
                                  label: const Text("All"),
                                  selected: _selectedCategory == null,
                                  onSelected: (_) => setModalState(() {
                                    _selectedCategory = null;
                                  }),
                                ),
                                ...categories.map(
                                      (cat) => ChoiceChip(
                                    label: Text(cat),
                                    selected: _selectedCategory == cat,
                                    onSelected: (_) => setModalState(() {
                                      _selectedCategory = _selectedCategory == cat ? null : cat;
                                    }),
                                  ),
                                ).toList(),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setModalState(() {
                                _selectedStatus = "all";
                                _selectedDateRange = "all";
                                _selectedDateFrom = null;
                                _selectedDateTo = null;
                                _selectedCategory = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Clear Filter"),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {}); // rebuild main UI
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check),
                            label: const Text("Apply"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  bool _isTaskInDateRange(Map<String, dynamic> task) {
    if (_selectedDateRange == "all") return true;

    final taskDateTime = task['task_datetime'] != null
        ? DateTime.parse(task['task_datetime'])
        : null;

    if (taskDateTime == null) {
      return _selectedDateRange == "all" || _selectedDateRange == "today";
    }

    if (_selectedDateFrom != null && _selectedDateTo != null) {
      return taskDateTime.isAfter(_selectedDateFrom!.subtract(const Duration(seconds: 1))) &&
          taskDateTime.isBefore(_selectedDateTo!.add(const Duration(seconds: 1)));
    }

    return true;
  }

  Map<String, List<Map<String, dynamic>>> _groupTasksByTime(List<Map<String, dynamic>> tasks) {
    // Create hash including all fields
    String currentHash = tasks
        .map((t) => '${t['task_id']}${t['title']}${t['category']}${t['task_datetime']}${t['notes']}${t['completed']}')
        .join();

    if (_lastTaskListHash == currentHash && _cachedGroupedTasks.isNotEmpty) {
      return _cachedGroupedTasks;
    }

    _cachedGroupedTasks = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final Map<String, List<Map<String, dynamic>>> groupedTasks = {
      'Previously': [],
      'Today': [],
      'Future': [],
    };

    for (final task in tasks) {
      final taskDateTime = task['task_datetime'] != null
          ? DateTime.parse(task['task_datetime'])
          : null;

      if (taskDateTime == null) {
        groupedTasks['Today']!.add(task);
      } else {
        final taskDate = DateTime(taskDateTime.year, taskDateTime.month, taskDateTime.day);

        if (taskDate.isBefore(today)) {
          groupedTasks['Previously']!.add(task);
        } else if (_isSameDay(taskDate, today)) {
          groupedTasks['Today']!.add(task);
        } else {
          groupedTasks['Future']!.add(task);
        }
      }
    }

    groupedTasks.forEach((key, taskList) {
      taskList.sort((a, b) => _compareTaskDateTime(a, b));
    });

    _cachedGroupedTasks = groupedTasks;
    _lastTaskListHash = currentHash;

    return groupedTasks;
  }

  int _compareTaskDateTime(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a['completed'] != b['completed']) {
      return (a['completed'] as bool) ? 1 : -1;
    }

    DateTime dateTimeA = a['task_datetime'] != null
        ? DateTime.parse(a['task_datetime'])
        : DateTime.now();
    DateTime dateTimeB = b['task_datetime'] != null
        ? DateTime.parse(b['task_datetime'])
        : DateTime.now();
    int compare = dateTimeA.compareTo(dateTimeB);

    if (compare == 0) {
      return (a['title'] as String).compareTo(b['title'] as String);
    }

    return compare;
  }

  Widget _buildGroupHeader(String groupName, int taskCount) {
    IconData icon;
    Color color;

    switch (groupName) {
      case 'Previously':
        icon = Icons.history;
        color = Colors.red;
        break;
      case 'Today':
        icon = Icons.today;
        color = Colors.blue;
        break;
      case 'Future':
        icon = Icons.schedule;
        color = Colors.green;
        break;
      default:
        icon = Icons.folder;
        color = Colors.grey;
    }

    final isCollapsed = _collapsedGroups[groupName] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _collapsedGroups[groupName] = !isCollapsed;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                groupName,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  taskCount.toString(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: isCollapsed ? -0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.expand_more, color: color, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return GestureDetector(
      onTap: () => _showTaskDetails(task),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _toggleTaskCompletion(task),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (task['completed'] as bool)
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                    ),
                    child: Icon(
                      (task['completed'] as bool) ? Icons.check_circle : Icons.circle_outlined,
                      color: (task['completed'] as bool) ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: (task['completed'] as bool)
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: (task['completed'] as bool) ? Colors.grey : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if ((task['category'] as String).isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(task['category'] as String),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            task['category'] as String,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (task['task_datetime'] != null)
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${DateTime.parse(task['task_datetime']).day}/${DateTime.parse(task['task_datetime']).month}/${DateTime.parse(task['task_datetime']).year} ${DateTime.parse(task['task_datetime']).hour.toString().padLeft(2, '0')}:${DateTime.parse(task['task_datetime']).minute.toString().padLeft(2, '0')}',
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      if ((task['notes'] as String?)?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          task['notes'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _editTask(task),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                        child: const Icon(Icons.edit, color: Colors.blue, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _confirmDeleteTask(task),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.1),
                        ),
                        child: const Icon(Icons.delete, color: Colors.red, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: 24,
          ),
          contentPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Icon(
                (task['completed'] as bool) ? Icons.check_circle : Icons.sync,
                color: (task['completed'] as bool) ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task['title'] as String,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((task['category'] as String).isNotEmpty) ...[
                    Text(
                      'Category',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(task['category'] as String),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task['category'] as String,
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    ),
                  ],
                  if (task['task_datetime'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Date & Time',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${DateTime.parse(task['task_datetime']).day}/${DateTime.parse(task['task_datetime']).month}/${DateTime.parse(task['task_datetime']).year} ${DateTime.parse(task['task_datetime']).hour.toString().padLeft(2, '0')}:${DateTime.parse(task['task_datetime']).minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                  if ((task['notes'] as String?)?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Notes',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task['notes'] as String,
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                    ),
                  ],

                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.inter(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _toggleTaskCompletion(Map<String, dynamic> task) async {
    final taskProvider = context.read<TaskProvider>();

    try {
      await taskProvider.toggleTaskCompletion(task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật trạng thái task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editTask(Map<String, dynamic> task) async {
    final updatedTask = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => UpdateTaskDialog(task: task),
    );

    if (updatedTask != null) {
      final taskProvider = context.read<TaskProvider>();
      final taskData = {
        'title': updatedTask['title'],
        'category': updatedTask['category'],
        'task_datetime': updatedTask['task_datetime'],
        'notes': updatedTask['notes'],
        'completed': updatedTask['completed'],
      };

      final success = await taskProvider.updateTask(task['task_id'], taskData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Task "${updatedTask['title']}" đã được cập nhật!'
                : 'Lỗi khi cập nhật task'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDeleteTask(Map<String, dynamic> task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(color: Colors.black, fontSize: 14),
            children: [
              const TextSpan(text: 'Bạn có chắc muốn xóa task '),
              TextSpan(
                text: '"${task['title']}"',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' không?\n\nHành động này không thể hoàn tác.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final taskProvider = context.read<TaskProvider>();
      final success = await taskProvider.deleteTask(task['task_id'] as String);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Đã xóa task "${task['title']}"'
                : 'Lỗi khi xóa task'),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'note':
        return Colors.blue;
      case 'calendar':
        return Colors.purple;
      case 'achievement':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedStatus != "all") count++;
    if (_selectedDateRange != "all") count++;
    if (_selectedCategory != null) count++;
    return count;
  }

  String _getActiveFiltersDescription() {
    List<String> filters = [];

    if (_selectedStatus != "all") {
      filters.add(_selectedStatus == "completed" ? "Completed" : "Pending");
    }

    if (_selectedDateRange != "all") {
      switch (_selectedDateRange) {
        case "today":
          filters.add("Today");
          break;
        case "this_week":
          filters.add("This Week");
          break;
        case "this_month":
          filters.add("This Month");
          break;
        case "custom":
          if (_selectedDateFrom != null && _selectedDateTo != null) {
            filters.add("${_selectedDateFrom!.day}/${_selectedDateFrom!.month} - ${_selectedDateTo!.day}/${_selectedDateTo!.month}");
          }
          break;
      }
    }

    if (_selectedCategory != null) {
      filters.add("Category: $_selectedCategory");
    }

    return "Filter: ${filters.join(", ")}";
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.black),
        ),
      ],
    );
  }

  int _calculateTotalItems(Map<String, List<Map<String, dynamic>>> groupedTasks) {
    int total = 0;

    for (final entry in groupedTasks.entries) {
      final groupName = entry.key;
      final tasks = entry.value;

      if (tasks.isEmpty) continue;

      total += 1; // Header

      final isCollapsed = _collapsedGroups[groupName] ?? false;
      if (!isCollapsed) {
        final maxDisplay = tasks.length > 5 ? 5 : tasks.length;
        total += maxDisplay;

        if (tasks.length > 5) {
          total += 1; // "View more" button
        }
      }
    }

    return total;
  }

  Widget _buildGroupedItem(Map<String, List<Map<String, dynamic>>> groupedTasks, int index) {
    int currentIndex = 0;

    for (final entry in groupedTasks.entries) {
      final groupName = entry.key;
      final tasks = entry.value;

      if (tasks.isEmpty) continue;

      final isCollapsed = _collapsedGroups[groupName] ?? false;

      if (index == currentIndex) {
        return _buildGroupHeader(groupName, tasks.length);
      }
      currentIndex++;

      if (isCollapsed) {
        continue;
      }

      final maxDisplay = tasks.length > 5 ? 5 : tasks.length;

      if (index < currentIndex + maxDisplay) {
        final taskIndex = index - currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _buildTaskItem(tasks[taskIndex]),
        );
      }
      currentIndex += maxDisplay;

      if (tasks.length > 5 && index == currentIndex) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Center(
            child: TextButton.icon(
              onPressed: () {
                _showAllTasksBottomSheet(groupName, tasks);
              },
              icon: const Icon(Icons.expand_more),
              label: Text(
                'Xem thêm ${tasks.length - 5} tasks khác',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              style: TextButton.styleFrom(
                foregroundColor: _getGroupColor(groupName),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        );
      }

      if (tasks.length > 5) {
        currentIndex += 1;
      }
    }

    return const SizedBox.shrink();
  }

  Color _getGroupColor(String groupName) {
    switch (groupName) {
      case 'Previously':
        return Colors.red;
      case 'Today':
        return Colors.blue;
      case 'Future':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getGroupIcon(String groupName) {
    switch (groupName) {
      case 'Previously':
        return Icons.history;
      case 'Today':
        return Icons.today;
      case 'Future':
        return Icons.schedule;
      default:
        return Icons.folder;
    }
  }

  void _showAllTasksBottomSheet(String groupName, List<Map<String, dynamic>> tasks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 1.0,
          maxChildSize: 1.0,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(_getGroupIcon(groupName), color: _getGroupColor(groupName)),
                      const SizedBox(width: 8),
                      Text(
                        '$groupName (${tasks.length} tasks)',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getGroupColor(groupName),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskItem(tasks[index]);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        final isLoading = taskProvider.isLoading;
        final error = taskProvider.error;

        // Apply filters
        var filteredTasks = tasks.where((task) {
          // Status filter
          if (_selectedStatus == "completed" && !(task['completed'] as bool)) {
            return false;
          }
          if (_selectedStatus == "pending" && (task['completed'] as bool)) {
            return false;
          }

          // Category filter
          if (_selectedCategory != null && task['category'] != _selectedCategory) {
            return false;
          }

          // Date range filter
          if (!_isTaskInDateRange(task)) {
            return false;
          }

          return true;
        }).toList();

        // Group tasks by time
        final groupedTasks = _groupTasksByTime(filteredTasks);
        final totalTasks = filteredTasks.length;
        final activeFilters = _getActiveFilterCount();

        return Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final isLoading = taskProvider.isLoading;
            final error = taskProvider.error;
            final tasks = taskProvider.tasks;

            // lọc tasks theo filter đã chọn
            var filteredTasks = tasks.where((task) {
              if (_selectedStatus == "completed" && !(task['completed'] as bool)) return false;
              if (_selectedStatus == "pending" && (task['completed'] as bool)) return false;
              if (_selectedCategory != null && task['category'] != _selectedCategory) return false;
              if (!_isTaskInDateRange(task)) return false;
              return true;
            }).toList();

            final groupedTasks = _groupTasksByTime(filteredTasks);
            final totalTasks = filteredTasks.length;
            final activeFilters = _getActiveFilterCount();

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                const SizedBox(height: 12),

                // Header with statistics and filter button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Statistics overview
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem('Total', totalTasks, Colors.blue),
                              _buildStatItem('Previously', groupedTasks['Previously']!.length, Colors.red),
                              _buildStatItem('Today', groupedTasks['Today']!.length, Colors.blue),
                              _buildStatItem('Future', groupedTasks['Future']!.length, Colors.green),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Filter button with badge
                      Stack(
                        children: [
                          TextButton.icon(
                            onPressed: _openFilterBottomSheet,
                            icon: const Icon(Icons.filter_list, size: 18),
                            label: Text(
                              "Filter",
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          if (activeFilters > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  activeFilters.toString(),
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Show active filters
                if (activeFilters > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getActiveFiltersDescription(),
                            style: GoogleFonts.inter(
                              color: Colors.orange[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStatus = "all";
                              _selectedDateRange = "all";
                              _selectedDateFrom = null;
                              _selectedDateTo = null;
                              _selectedCategory = null;
                            });
                          },
                          child: Icon(Icons.clear, color: Colors.orange[700], size: 16),
                        ),
                      ],
                    ),
                  ),
                ],

                // Error message
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lỗi: $error',
                            style: GoogleFonts.inter(color: Colors.red[700], fontSize: 12),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => taskProvider.clearError(),
                          child: Icon(Icons.clear, color: Colors.red[700], size: 16),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Task list grouped by time
                Expanded(
                  child: totalTasks == 0
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "Không có công việc nào",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeFilters > 0
                              ? "Không tìm thấy công việc phù hợp với bộ lọc"
                              : "Hãy thêm công việc đầu tiên của bạn!",
                          style: GoogleFonts.inter(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: _calculateTotalItems(groupedTasks),
                    itemBuilder: (context, index) {
                      return _buildGroupedItem(groupedTasks, index);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}