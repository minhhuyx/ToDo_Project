// // lib/services/notification_service.dart
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
//
// class NotificationService {
//   static final _plugin = FlutterLocalNotificationsPlugin();
//
//   /// MUST await this before scheduling anything.
//   static Future<void> init() async {
//     // load tz database
//     tz.initializeTimeZones();
//
//     // get device IANA timezone (e.g. "Asia/Ho_Chi_Minh")
//     try {
//       final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
//       print('👉 device timezone (IANA): $timeZoneName');
//       final location = tz.getLocation(timeZoneName);
//       tz.setLocalLocation(location);
//       print('👉 tz.local.name = ${tz.local.name}');
//       print('👉 tz now (local) = ${tz.TZDateTime.now(tz.local)}');
//     } catch (e, st) {
//       print('⚠️ Could not get device timezone, fallback to default tz.local. Error: $e');
//       // keep tz.local as default (may be UTC) — ideally you want to catch this early
//     }
//
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: androidInit);
//     await _plugin.initialize(initSettings);
//     print('🔔 Notification plugin initialized');
//   }
//
//   static Future<void> showNow(String title, String body) async {
//     const androidDetails = AndroidNotificationDetails(
//       'reminder_channel',
//       'Reminders',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const details = NotificationDetails(android: androidDetails);
//     await _plugin.show(0, title, body, details);
//   }
//
//   static Future<void> scheduleAfterSeconds(
//       String title, String body, int seconds) async {
//     final scheduledDate =
//     tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
//     print("👉 Schedule at (local TZDateTime): $scheduledDate (tz.local=${tz.local.name})");
//
//     const androidDetails = AndroidNotificationDetails(
//       'reminder_channel',
//       'Reminders',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const details = NotificationDetails(android: androidDetails);
//
//     await _plugin.zonedSchedule(
//       1,
//       title,
//       body,
//       scheduledDate,
//       details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }
//
//   static Future<void> cancelAll() async {
//     await _plugin.cancelAll();
//   }
// }
