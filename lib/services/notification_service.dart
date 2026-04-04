import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  static Future<void> showFuelAlert({
    required String stationName,
    required String message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'fuel_alerts',
      'ဆီဌာန သတိပေးချက်',
      channelDescription: 'ဆီဌာနအနေအထား ပြောင်းလဲမှု သတိပေးချက်',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '⛽ $stationName',
      message,
      details,
    );
  }

  static Future<void> showAvailableAlert(String stationName) async {
    await showFuelAlert(
      stationName: stationName,
      message: '✅ ဆီရနေပြီ! လာယူနိုင်ပါပြီ',
    );
  }

  static Future<void> showBusyAlert(String stationName, int minutes) async {
    await showFuelAlert(
      stationName: stationName,
      message: '⚠️ တန်းစီချိန် ~$minutes မိနစ် ခန့်ရှိနေသည်',
    );
  }
}
