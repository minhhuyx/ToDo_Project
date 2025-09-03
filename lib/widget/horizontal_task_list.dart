// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../model/task_model.dart';
//
// class HorizontalTaskList extends StatefulWidget {
//   final bool todayOnly;
//
//   const HorizontalTaskList({super.key, this.todayOnly = true});
//
//   @override
//   State<HorizontalTaskList> createState() => _HorizontalTaskListState();
// }
//
// class _HorizontalTaskListState extends State<HorizontalTaskList> {
//   List<Task> tasks = [
//     Task(
//       title: 'Buy groceries',
//       category: 'Note',
//       taskDatetime: DateTime.now(),
//       notes: 'Milk, eggs, bread',
//       completed: false,
//       syncStatus: '',
//     ),
//     Task(
//       title: 'Meeting with team',
//       category: 'Calendar',
//       taskDatetime: DateTime.now().add(Duration(hours: 2)),
//       notes: 'Discuss project',
//       completed: false,
//       syncStatus: '',
//     ),
//     Task(
//       title: 'Finish report',
//       category: 'Achievement',
//       taskDatetime: DateTime.now().subtract(Duration(hours: 1)),
//       notes: '',
//       completed: true,
//       syncStatus: '',
//     ),
//   ];
//
//   void _toggleTaskCompletion(Task task) {
//     setState(() {
//       task.completed = !task.completed;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Task status updated (front-end only)'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final today = DateTime.now();
//     List<Task> displayTasks = tasks;
//
//     if (widget.todayOnly) {
//       displayTasks = displayTasks.where((task) {
//         if (task.taskDatetime == null) return false;
//         return task.taskDatetime!.year == today.year &&
//             task.taskDatetime!.month == today.month &&
//             task.taskDatetime!.day == today.day;
//       }).toList();
//     }
//
//     if (displayTasks.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(16),
//         child: Text("No tasks available 🎉"),
//       );
//     }
//
//     displayTasks.sort((a, b) {
//       if (a.completed != b.completed) return a.completed ? 1 : -1;
//       final aDate = a.taskDatetime ?? DateTime.now();
//       final bDate = b.taskDatetime ?? DateTime.now();
//       return aDate.compareTo(bDate);
//     });
//
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     double cardWidthFactor = 0.42;
//     if (screenWidth < 350) cardWidthFactor = 0.6;
//
//     double cardHeight = screenHeight * 0.3;
//     if (screenHeight < 600) cardHeight = 160;
//     if (screenHeight > 900) cardHeight = 220;
//
//     return SizedBox(
//       height: cardHeight,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: displayTasks.length,
//         itemBuilder: (context, index) {
//           final task = displayTasks[index];
//           return SizedBox(
//             width: screenWidth * cardWidthFactor,
//             child: _buildTaskCard(context, task),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildTaskCard(BuildContext context, Task task) {
//     return GestureDetector(
//       onTap: () {
//         final formattedDate = task.taskDatetime != null
//             ? DateFormat('dd/MM/yyyy - HH:mm').format(task.taskDatetime!)
//             : 'No date selected';
//
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             title: Text(task.title),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (task.category.isNotEmpty)
//                   Text("📂 Category: ${task.category}"),
//                 if (formattedDate.isNotEmpty) Text("📅 $formattedDate"),
//                 if (task.notes != null && task.notes!.isNotEmpty)
//                   Text("📝 ${task.notes}"),
//                 if (task.syncStatus == 'pending' || task.syncStatus == 'pending_delete')
//                   Text(
//                     "🔄 Sync: ${task.syncStatus == 'pending' ? 'Pending' : 'Pending Delete'}",
//                     style: TextStyle(color: Colors.orange),
//                   ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Close"),
//               ),
//             ],
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//         child: Card(
//           color: task.completed ? Colors.grey[200] : Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 3,
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (task.syncStatus == 'pending' || task.syncStatus == 'pending_delete')
//                   Align(
//                     alignment: Alignment.topRight,
//                     child: Icon(
//                       Icons.sync,
//                       size: 16,
//                       color: Colors.orange,
//                     ),
//                   ),
//                 Text(
//                   task.title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     decoration: task.completed
//                         ? TextDecoration.lineThrough
//                         : TextDecoration.none,
//                     color: task.completed ? Colors.grey : Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 if (task.category.isNotEmpty)
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 6),
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: _getCategoryColor(task.category),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       task.category,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 if (task.taskDatetime != null)
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 6),
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: Colors.teal,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       DateFormat('HH:mm').format(task.taskDatetime!),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 const Spacer(),
//                 Center(
//                   child: IconButton(
//                     icon: Icon(
//                       task.completed
//                           ? Icons.check_circle
//                           : Icons.circle_outlined,
//                       color: task.completed ? Colors.green : Colors.grey,
//                     ),
//                     onPressed: () => _toggleTaskCompletion(task),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Color _getCategoryColor(String category) {
//     switch (category.toLowerCase()) {
//       case 'note':
//         return Colors.blue;
//       case 'calendar':
//         return Colors.purple;
//       case 'achievement':
//         return Colors.orange;
//       default:
//         return Colors.teal;
//     }
//   }
// }