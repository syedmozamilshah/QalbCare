import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qalbcare/main.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'qalbcare_channel_group',
          channelKey: 'azkar_channel',
          channelName: 'Azkar Reminders',
          channelDescription: 'Daily morning and evening Azkar reminders',
          defaultColor: const Color(0xFF1F7A68),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          locked: false,
        ),
        NotificationChannel(
          channelGroupKey: 'qalbcare_channel_group',
          channelKey: 'muhasiba_channel',
          channelName: 'Muhasiba Reminders',
          channelDescription: 'Daily Muhasiba completion reminders',
          defaultColor: const Color(0xFF1F7A68),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          locked: false,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'qalbcare_channel_group',
          channelGroupName: 'QalbCare Notifications',
        ),
      ],
      debug: true,
    );

    // Set up notification listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    // Request notification permissions
    await requestNotificationPermissions();
    
    // Set up initial notifications
    await scheduleAzkarNotifications();
    await checkAndScheduleMuhasibaReminder();
  }

  static Future<void> requestNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Request permission with proper context
      await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
        ],
      );
    }
    
    // Log permission status for debugging
    final permissionStatus = await AwesomeNotifications().isNotificationAllowed();
    debugPrint('Notification permissions allowed: $permissionStatus');
  }

  // Notification event handlers
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('Notification created: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('Notification displayed: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('Notification dismissed: ${receivedAction.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('Notification action received: ${receivedAction.payload}');
    
    final String? route = receivedAction.payload?['route'];
    
    if (route != null && MyApp.navigatorKey.currentState != null) {
      MyApp.navigatorKey.currentState!.pushNamed(route);
    }
  }

  // Schedule Azkar notifications
  static Future<void> scheduleAzkarNotifications() async {
    // Morning Azkar notification at 7:00 AM
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'azkar_channel',
        title: '🌅 Start your day with Adhkār. Tap to complete.',
        body: 'Let this morning be reflective and blessed.',
        payload: {'route': '/azkar-streak'},
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: 7,
        minute: 0,
        second: 0,
        repeats: true,
      ),
    );

    // Evening Azkar notification at 6:30 PM
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 11,
        channelKey: 'azkar_channel',
        title: '🌇 Evening is here. Reflect and recite your Adhkār.',
        body: 'End your day with peace and reflection.',
        payload: {'route': '/azkar-streak'},
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: 18,
        minute: 30,
        second: 0,
        repeats: true,
      ),
    );
  }

  // Schedule Muhasiba reminder notification
  static Future<void> scheduleMuhasibaReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSubmitDate = prefs.getString('muhasiba_last_submit');
    final today = DateTime.now();
    final todayString = formatDate(today);

    if (lastSubmitDate == null || lastSubmitDate != todayString) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 12,
          channelKey: 'muhasiba_channel',
          title: '🌙 Don\'t forget to complete your Muhasiba today.',
          body: 'Take time to reflect on your day and seek Allah\'s guidance.',
          payload: {'route': '/muhasiba'},
          notificationLayout: NotificationLayout.Messaging,
        ),
        schedule: NotificationCalendar(
          hour: 21,
          minute: 30,
          second: 0,
          repeats: true,
        ),
      );
    }
  }

  // Check if Muhasiba was completed today and schedule reminder if needed
  static Future<void> checkAndScheduleMuhasibaReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSubmitDate = prefs.getString('muhasiba_last_submit');
    final today = DateTime.now();
    final todayString = formatDate(today);

    // If user hasn't submitted Muhasiba today, make sure reminder is scheduled
    if (lastSubmitDate == null || lastSubmitDate != todayString) {
      await scheduleMuhasibaReminder();
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
  
  // Debug method to check notification status
  static Future<void> checkNotificationStatus() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    final activeNotifications = await AwesomeNotifications().listScheduledNotifications();
    
    debugPrint('=== Notification Status Debug ===');
    debugPrint('Notifications allowed: $isAllowed');
    debugPrint('Active scheduled notifications: ${activeNotifications.length}');
    
    for (var notification in activeNotifications) {
      debugPrint('Notification ID: ${notification.content?.id}, Title: ${notification.content?.title}');
      debugPrint('Schedule: ${notification.schedule?.toString()}');
    }
    debugPrint('=== End Debug ===');
  }
  
  // Force reschedule notifications (for debugging)
  static Future<void> forceRescheduleNotifications() async {
    await cancelAllNotifications();
    await scheduleAzkarNotifications();
    await checkAndScheduleMuhasibaReminder();
    debugPrint('All notifications rescheduled');
  }
  
  // Utility method for consistent date formatting
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
