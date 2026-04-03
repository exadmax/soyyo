import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/warranty.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    _initialized = true;
  }

  static Future<void> scheduleWarrantyNotification(Warranty warranty) async {
    if (kIsWeb || !_initialized) return;

    final notifyDate =
        warranty.expirationDate.subtract(const Duration(days: 7));
    if (notifyDate.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(notifyDate, tz.local);

    await _notifications.zonedSchedule(
      warranty.id.hashCode,
      'Garantia vencendo em breve',
      'A garantia de ${warranty.productName} vence em 7 dias.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'warranty_channel',
          'Garantias',
          channelDescription: 'Notificações de vencimento de garantia',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelWarrantyNotification(String warrantyId) async {
    if (kIsWeb || !_initialized) return;
    await _notifications.cancel(warrantyId.hashCode);
  }

  static Future<void> cancelAllNotifications() async {
    if (kIsWeb || !_initialized) return;
    await _notifications.cancelAll();
  }
}
