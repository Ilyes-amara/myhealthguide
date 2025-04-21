import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define RepeatInterval enum if not provided by flutter_local_notifications
enum RepeatInterval { daily, weekly, monthly }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<ReceivedNotification>
  didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
  final BehaviorSubject<String?> selectNotificationSubject =
      BehaviorSubject<String?>();

  // Notification IDs
  static const int appointmentReminderId = 1;
  static const int medicationReminderId = 2;
  static const int healthCheckReminderId = 3;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    try {
      // Skip notification setup on web platform
      if (kIsWeb) {
        debugPrint('Notifications not supported on web platform');
        return;
      }

      tz_data.initializeTimeZones();

      final AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false,
            onDidReceiveLocalNotification: (
              int id,
              String? title,
              String? body,
              String? payload,
            ) async {
              didReceiveLocalNotificationSubject.add(
                ReceivedNotification(
                  id: id,
                  title: title ?? '',
                  body: body ?? '',
                  payload: payload,
                ),
              );
            },
          );

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          selectNotificationSubject.add(response.payload);
        },
      );

      // Request permissions for iOS
      if (!kIsWeb && io.Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }

      // Request permissions for Android 13 and above
      if (!kIsWeb && io.Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        await androidImplementation?.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      // Don't rethrow on web to prevent app crash
      if (!kIsWeb) {
        rethrow;
      }
    }
  }

  // Schedule an appointment reminder
  Future<void> scheduleAppointmentReminder(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    String payload,
  ) async {
    // Skip on web
    if (kIsWeb) {
      debugPrint('Appointment reminder not scheduled (web platform)');
      return;
    }

    // Schedule notification 1 day before and 1 hour before
    await _scheduleNotification(
      id,
      title,
      'Reminder: You have an appointment tomorrow',
      scheduledDate.subtract(const Duration(days: 1)),
      payload,
    );

    await _scheduleNotification(
      id + 1000, // Use a different ID for the second notification
      title,
      'Reminder: You have an appointment in 1 hour',
      scheduledDate.subtract(const Duration(hours: 1)),
      payload,
    );
  }

  // Schedule a medication reminder
  Future<void> scheduleMedicationReminder(
    int id,
    String medicationName,
    String dosage,
    TimeOfDay time,
    List<int> days, // 1-7 for Monday-Sunday
    String payload,
  ) async {
    // Skip on web
    if (kIsWeb) {
      debugPrint('Medication reminder not scheduled (web platform)');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationReminders =
          prefs.getStringList('medication_reminders') ?? [];

      // Remove existing reminders for this medication
      medicationReminders.removeWhere(
        (reminder) => reminder.startsWith('$id|'),
      );

      // Store new reminder info
      final reminderInfo =
          '$id|$medicationName|$dosage|${time.hour}:${time.minute}|${days.join(",")}';
      medicationReminders.add(reminderInfo);
      await prefs.setStringList('medication_reminders', medicationReminders);

      // Cancel existing notifications for this medication
      for (var i = 0; i < 7; i++) {
        await flutterLocalNotificationsPlugin.cancel(id + i);
      }

      // Schedule for each selected day
      for (final day in days) {
        final localNow = tz.TZDateTime.now(tz.local);

        // Calculate next occurrence
        int daysUntilNextOccurrence = (day - localNow.weekday) % 7;
        if (daysUntilNextOccurrence == 0 &&
            (time.hour < localNow.hour ||
                (time.hour == localNow.hour &&
                    time.minute <= localNow.minute))) {
          daysUntilNextOccurrence = 7;
        }

        final nextOccurrence = tz.TZDateTime(
          tz.local,
          localNow.year,
          localNow.month,
          localNow.day + daysUntilNextOccurrence,
          time.hour,
          time.minute,
        );

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id + day,
          'Medication Reminder',
          'Time to take $medicationName ($dosage)',
          nextOccurrence,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_channel',
              'Medication Reminders',
              channelDescription: 'Daily medication reminders',
              importance: Importance.high,
              priority: Priority.high,
              enableLights: true,
              enableVibration: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: payload,
        );

        debugPrint(
          'Scheduled medication reminder for: ${nextOccurrence.toString()}',
        );
      }
    } catch (e) {
      debugPrint('Error scheduling medication reminder: $e');
      rethrow;
    }
  }

  // Schedule a health check reminder
  Future<void> scheduleHealthCheckReminder(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    String payload,
  ) async {
    // Skip on web
    if (kIsWeb) {
      debugPrint('Health check reminder not scheduled (web platform)');
      return;
    }

    await _scheduleNotification(id, title, body, scheduledDate, payload);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    // Skip on web
    if (kIsWeb) {
      debugPrint('Cancel notifications skipped (web platform)');
      return;
    }

    await flutterLocalNotificationsPlugin.cancelAll();

    // Clear stored reminders
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('medication_reminders');
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    // Skip on web
    if (kIsWeb) {
      debugPrint('Cancel notification skipped (web platform)');
      return;
    }

    await flutterLocalNotificationsPlugin.cancel(id);

    // Remove from stored reminders if it's a medication reminder
    if (id >= medicationReminderId && id < healthCheckReminderId) {
      final prefs = await SharedPreferences.getInstance();
      final medicationReminders =
          prefs.getStringList('medication_reminders') ?? [];

      medicationReminders.removeWhere(
        (reminder) => reminder.startsWith('$id|'),
      );
      await prefs.setStringList('medication_reminders', medicationReminders);
    }
  }

  // Private method to schedule a one-time notification
  Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    String payload,
  ) async {
    // Skip on web
    if (kIsWeb) {
      return;
    }

    try {
      // Convert to local timezone
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      // Validate scheduled date
      if (scheduledTZ.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('Warning: Attempted to schedule notification in the past');
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'health_guide_channel',
            'Health Guide Notifications',
            channelDescription:
                'Notifications for health reminders and appointments',
            importance: Importance.high,
            priority: Priority.high,
            enableLights: true,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint(
        'Successfully scheduled notification for: ${scheduledTZ.toString()}',
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  // Private method to schedule a repeating notification
  Future<void> _scheduleRepeatingNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    String payload,
    RepeatInterval repeatInterval,
  ) async {
    // Skip on web
    if (kIsWeb) {
      return;
    }

    try {
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'health_reminders_channel',
        'Health Reminders',
        channelDescription: 'Channel for health-related reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Determine the appropriate DateTimeComponents based on the repeat interval
      DateTimeComponents? dateTimeComponents;
      switch (repeatInterval) {
        case RepeatInterval.daily:
          dateTimeComponents = DateTimeComponents.time;
          break;
        case RepeatInterval.weekly:
          dateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
          break;
        case RepeatInterval.monthly:
          dateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
          break;
        default:
          dateTimeComponents = null;
      }

      // For repeating notifications, use zonedSchedule with appropriate matchDateTimeComponents
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(scheduledDate),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: dateTimeComponents,
        payload: payload,
      );

      debugPrint(
        'Scheduled repeating notification for: ${scheduledDate.toString()} with repeat interval: $repeatInterval',
      );
    } catch (e) {
      debugPrint('Error scheduling repeating notification: $e');
      rethrow;
    }
  }

  // Helper method to get the next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(DateTime dateTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    if (scheduledDate.isBefore(now)) {
      // If the scheduled date is before now, schedule it for the next occurrence
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
      );

      if (scheduledDate.isBefore(now)) {
        // If still before now, add one day and check again
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    return scheduledDate;
  }

  // Restore scheduled medication reminders after app restart
  Future<void> restoreScheduledMedicationReminders() async {
    // Skip on web
    if (kIsWeb) {
      debugPrint('Restoring reminders skipped (web platform)');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationReminders =
          prefs.getStringList('medication_reminders') ?? [];

      for (final reminderStr in medicationReminders) {
        try {
          final parts = reminderStr.split('|');
          if (parts.length >= 5) {
            final id = int.tryParse(parts[0]);
            if (id == null) continue;

            final medicationName = parts[1];
            final dosage = parts[2];

            final timeParts = parts[3].split(':');
            if (timeParts.length != 2) continue;

            final hour = int.tryParse(timeParts[0]);
            final minute = int.tryParse(timeParts[1]);
            if (hour == null ||
                minute == null ||
                hour < 0 ||
                hour > 23 ||
                minute < 0 ||
                minute > 59) {
              continue;
            }

            final time = TimeOfDay(hour: hour, minute: minute);

            final daysList = parts[4].split(',');
            final days = <int>[];
            for (final dayStr in daysList) {
              final day = int.tryParse(dayStr);
              if (day != null && day >= 1 && day <= 7) {
                days.add(day);
              }
            }

            if (days.isEmpty) continue;

            // Reschedule this medication reminder
            await scheduleMedicationReminder(
              id,
              medicationName,
              dosage,
              time,
              days,
              'medication_$id',
            );

            debugPrint('Restored medication reminder: $medicationName');
          }
        } catch (e) {
          debugPrint('Error restoring individual medication reminder: $e');
          // Continue with next reminder even if this one fails
          continue;
        }
      }
      debugPrint('Completed restoring all medication reminders');
    } catch (e) {
      debugPrint('Error restoring medication reminders: $e');
      // Don't rethrow here to prevent app crash on startup
    }
  }
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String? payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}
