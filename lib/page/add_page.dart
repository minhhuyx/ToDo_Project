import 'package:flutter/material.dart';
import '../widget/enhanced_button_row.dart';
import '../services/task_service.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String selectedCategory = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool _isLoading = false;

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();

    // Validation
    if (title.isEmpty) {
      _showSnackBar('Vui lòng nhập tiêu đề task', Colors.red);
      return;
    }

    if (selectedCategory.isEmpty) {
      _showSnackBar('Vui lòng chọn category', Colors.orange);
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      _showSnackBar('Vui lòng chọn ngày và giờ', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Format date: "YYYY-MM-DD"
      final formattedDate =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

      // Format time: "HH:mm"
      final hour = selectedTime!.hour;
      final minute = selectedTime!.minute;
      final formattedDatetime =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2,'0')}-${selectedDate!.day.toString().padLeft(2,'0')}T${selectedTime!.hour.toString().padLeft(2,'0')}:${selectedTime!.minute.toString().padLeft(2,'0')}:00";

      final taskData = {
        'title': title,
        'notes': notes.isNotEmpty ? notes : null,
        'category': selectedCategory.toLowerCase(),
        'task_datetime': formattedDatetime,
        'completed': false,
      };

      print('Task data sent: $taskData'); // debug

      // Gọi API
      final TaskService taskService = TaskService();
      final result = await taskService.createTask(taskData);

      if (result != null) {
        _showSnackBar('Task đã được tạo thành công!', Colors.green);
        _resetForm();
      } else {
        _showSnackBar('Có lỗi xảy ra khi tạo task', Colors.red);
      }
    } catch (e) {
      print('Error creating task: $e');
      _showSnackBar('Lỗi kết nối server: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  // Helper function để lấy màu category
  Color _getCategoryColor() {
    switch (selectedCategory) {
      case 'Note':
        return Colors.blue;
      case 'Calendar':
        return Colors.purple;
      case 'Achievement':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Callback functions cho Enhanced Button Row
  void _handleNotePressed() {
    setState(() {
      selectedCategory = 'Note';
    });
    print("Category selected: Note");

  }

  void _handleCalendarPressed() {
    setState(() {
      selectedCategory = 'Calendar';
    });
    print("Category selected: Calendar");

  }

  void _handleAchievementPressed() {
    setState(() {
      selectedCategory = 'Achievement';
    });
    print("Category selected: Achievement");

  }

  // Hàm chọn ngày
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Hàm chọn giờ
  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Reset form sau khi lưu thành công
  void _resetForm() {
    setState(() {
      _titleController.clear();
      _notesController.clear();
      selectedCategory = '';
      selectedDate = null;
      selectedTime = null;
    });
  }


  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    selectedDate = null;
    selectedTime = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Title Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              "Task Title",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Nhập tiêu đề task...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Category Section
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Category",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                if (selectedCategory.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(left: 12),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      selectedCategory,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          EnhancedButtonRow(
            onNotePressed: _handleNotePressed,
            onCalendarPressed: _handleCalendarPressed,
            onAchievementPressed: _handleAchievementPressed,
          ),

          // When Section
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              "When",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Date picker
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade200],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            selectedDate != null
                                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : 'Chọn ngày',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Time picker
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade400, Colors.purple.shade200],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : 'Chọn giờ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
,

          // Notes Section
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              "Notes",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                controller: _notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Thêm ghi chú cho task...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(16),
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ),

          // Save Button
          SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Save Task',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
