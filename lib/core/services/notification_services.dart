//don't lose your 5 day streak!
// This is a placeholder for future push notification implementation
class NotificationServices {
  // Initialize notifications
  Future<void> initialize() async {
    // Will implement push notifications later
    print('Notification service initialized');
  }

  // Send local notification
  Future<void> showNotification(String title, String body) async {
    // Will implement later
    print('Notification: $title - $body');
  }

  // Schedule watering reminder
  Future<void> scheduleWateringReminder(String plantName) async {
    // Will implement later
    print('Scheduled watering reminder for $plantName');
  }
}