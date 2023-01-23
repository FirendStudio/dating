import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
showSimpleNotification({required String title, required String body}) async {
  const AndroidNotificationDetails androidplatformChannelSpecifics =
      AndroidNotificationDetails('your channel id', 'your channel name',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const IOSNotificationDetails iOSplatformChannelSpecifics =
      IOSNotificationDetails(presentSound: false);
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidplatformChannelSpecifics,
      iOS: iOSplatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0, title, body, platformChannelSpecifics,
    // payload:payload
  );
}

showNotification(RemoteMessage? message) async {
  RemoteNotification? notification = message?.notification;
  String? title = notification?.title ?? "";
  String? body = notification?.body ?? "";

  const AndroidNotificationDetails androidplatformChannelSpecifics =
      AndroidNotificationDetails('your channel id', 'your channel name',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const IOSNotificationDetails iOSplatformChannelSpecifics =
      IOSNotificationDetails(presentSound: false);
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidplatformChannelSpecifics,
      iOS: iOSplatformChannelSpecifics);
  String payload = "";
  if (message?.notification?.title == "Liked") {
    payload = "liked/" + message?.data['idUser'];
  }
  await flutterLocalNotificationsPlugin
      .show(0, title, body, platformChannelSpecifics, payload: payload
          // payload:payload
          );
}
