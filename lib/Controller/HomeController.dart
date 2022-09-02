import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hookup4u/Screens/Calling/incomingCall.dart';
import 'package:hookup4u/models/user_model.dart';

import 'LoginController.dart';

class HomeController extends GetxController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int index = 0;
  List<int> listAge = [];
  int ageMin = 0, ageMax = 0;

  initFCM(
      CollectionReference docRef, UserModel user, BuildContext context) async {
    if (index == 0) {
      await FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage message) {
        if (kDebugMode) {
          print('Firebase Connect');
        }
        // _serialiseAndNavigate(message);
      });
      // FirebaseMessaging.instance.getToken().then((value) => print("Token : " + value));
      FirebaseMessaging.instance
          .subscribeToTopic("${Get.find<LoginController>().userId}");
      print("Subcribe to ${Get.find<LoginController>().userId}");
      // String fcmToken = GetStorage().read("fcmToken") ?? "";
      // if(fcmToken.isEmpty){
      //   FirebaseMessaging.instance.getToken().then((token) {
      //     print(token);
      //     GetStorage().write("fcmToken", token);
      //     docRef.doc(user.id).update({
      //       'pushToken': token,
      //     });
      //   });
      // }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("onmessage$message");
        showNotification(message);
        // if (Platform.isIOS && message.data['type'] == 'Call') {
        //   Map callInfo = {};
        //   callInfo['channel_id'] = message.data['channel_id'];
        //   callInfo['senderName'] = message.data['senderName'];
        //   callInfo['senderPicture'] = message.data['senderPicture'];
        //   // Navigator.push(context,
        //   //     MaterialPageRoute(builder: (context) => Incoming(callInfo)));
        // } else if (Platform.isAndroid && message.data['data']['type'] == 'Call') {
        //   // Navigator.push(
        //   //     context,
        //   //     MaterialPageRoute(
        //   //         builder: (context) => Incoming(message.data['data'])));
        // } else{
        //   print("object");
        // }
      });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        print('===============onLaunch$message');
        showNotification(message);
        // if (Platform.isIOS && message.data['type'] == 'Call') {
        //   Map callInfo = {};
        //   callInfo['channel_id'] = message.data['channel_id'];
        //   callInfo['senderName'] = message.data['senderName'];
        //   callInfo['senderPicture'] = message.data['senderPicture'];
        //   bool iscallling = await _checkcallState(message.data['channel_id']);
        //   print("=================$iscallling");
        //   if (iscallling) {
        //     // await Navigator.push(context,
        //     //     MaterialPageRoute(builder: (context) => Incoming(message)));
        //   }
        // } else if (Platform.isAndroid && message.data['data']['type'] == 'Call') {
        //   bool iscallling =
        //   await _checkcallState(message.data['data']['channel_id']);
        //   print("=================$iscallling");
        //   if (iscallling) {
        //     // await Navigator.push(
        //     //     context,
        //     //     MaterialPageRoute(
        //     //         builder: (context) => Incoming(message.data['data'])));
        //   } else {
        //     print("Timeout");
        //   }
        // }
      });

      index = 1;
      for (int i = 0; i <= 100; i++) {
        listAge.add(i);
      }
    } else {}
  }

  showNotification(RemoteMessage message) async {
    RemoteNotification notification = message.notification;
    String title = notification.title;
    String body = notification.body;

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
    if(message.notification.title == "Liked"){
      payload = "liked/" + message.data['idUser'];
    }
    await flutterLocalNotificationsPlugin.show(
      0, title, body, platformChannelSpecifics,
      payload: payload
      // payload:payload
    );
  }

  showSimpleNotification(
      {@required String title, @required String body}) async {
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

  _checkcallState(channelId) async {
    bool iscalling = await FirebaseFirestore.instance
        .collection("calls")
        .doc(channelId)
        .get()
        .then((value) {
      print(value);
      // return value.data["calling"] ?? false;
      return value["calling"] ?? false;
    });
    return iscalling;
  }
}
