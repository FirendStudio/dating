import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/infrastructure/dal/util/color.dart';

import 'firebase_config.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: DefaultFirebaseConfig.platformOptions);
  } else {
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification: (
            int id,
            String? title,
            String? body,
            String? payload,
          ) async {
            print(payload);
            // didReceiveLocalNotificationSubject.add(
            //   ReceivedNotification(
            //     id: id,
            //     title: title,
            //     body: body,
            //     payload: payload,
            //   ),
            // );
          });
  const MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
    linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin?.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null && payload.isNotEmpty) {
      debugPrint('notification payload: $payload');
      // Get.find<NotificationController>().initPayload(payload);
    }
    // selectedNotificationPayload = payload;
    // selectNotificationSubject.add(payload);
  });

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  await GetStorage.init();
  var initialRoute = await Routes.initialRoute;
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  Get.put(GlobalController());
  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  Main(this.initialRoute);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      defaultTransition: Transition.circularReveal,
      title: "JablessCupid",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      initialRoute: initialRoute,
      getPages: Nav.routes,
    );
  }
}
