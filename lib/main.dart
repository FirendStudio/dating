import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hookup4u/Controller/HomeController.dart';
import 'package:hookup4u/Controller/LoginController.dart';
import 'package:hookup4u/Controller/TabsController.dart';
import 'package:hookup4u/Controller/WelcomeController.dart';
import 'package:hookup4u/Screens/Splash.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:hookup4u/Screens/Welcome.dart';
import 'package:hookup4u/Screens/auth/login.dart';
import 'package:hookup4u/ads/ads.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/firebase_config.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'Controller/NotificationController.dart';
// import 'package:easy_localization/easy_localization.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await EasyLocalization.ensureInitialized();

  if(kIsWeb){
    await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);
  }else{
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('launcher_icon');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (
          int id,
          String title,
          String body,
          String payload,
          ) async {
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
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: $payload');
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

  Get.put(HomeController());
  Get.put(WelcomeController());
  Get.put(LoginController());
  Get.put(NotificationController());
  Get.put(TabsController());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]).then((_) {
    // InAppPurchaseConnection.enablePendingPurchases();
    //runApp(new MyApp());
    runApp(MyApp());
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  bool isAuth = false;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    // FirebaseAdMob.instance
    //     .initialize(appId: Platform.isAndroid ? androidAdAppId : iosAdAppId);
    _getLanguage();
  }

  Future _checkAuth() async {

    if(GetPlatform.isIOS){
      await FirebaseMessaging.instance.requestPermission();

      var iosToken = await FirebaseMessaging.instance.getAPNSToken();
      print(iosToken);
    }

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    print(user);
    if (user != null) {
      print("ID User : " + user.uid);
      String metode = "";
      String cek = user.providerData[0].providerId;
      print(cek);
      QuerySnapshot userAuth = await Get.find<LoginController>().getUser(user, cek);

      if (userAuth.docs.length > 0) {

        print(userAuth.docs);
        var docs = userAuth.docs.first;
        print(docs.data());
        Map<String, dynamic> data = docs.data();
        Get.find<LoginController>().storage.write("userId", data['userId']);
        Get.find<LoginController>().userId = data['userId'];
        if (data['location'] != null) {
          setState(() {
            isRegistered = true;
            isLoading = false;
          });
        } else {
          setState(() {
            isAuth = true;
            isLoading = false;
          });
        }
        print("loggedin ${data['userId']}");
      } else {
        setState(() {
          isLoading = false;
        });
      }

    } else {
      setState(() {
        isLoading = false;
      });
    }
    // _auth.currentUser().then((FirebaseUser user) async {
    //   print(user);
    //   if (user != null) {
    //     await Firestore.instance
    //         .collection('Users')
    //         .where('userId', isEqualTo: user.uid)
    //         .getDocuments()
    //         .then((QuerySnapshot snapshot) async {
    //       if (snapshot.documents.length > 0) {
    //         if (snapshot.documents[0].data['location'] != null) {
    //           setState(() {
    //             isRegistered = true;
    //             isLoading = false;
    //           });
    //         } else {
    //           setState(() {
    //             isAuth = true;
    //             isLoading = false;
    //           });
    //         }
    //         print("loggedin ${user.uid}");
    //       } else {
    //         setState(() {
    //           isLoading = false;
    //         });
    //       }
    //     });
    //   } else {
    //     setState(() {
    //       isLoading = false;
    //     });
    //   }
    // });
  }

  _getLanguage() async {
    var itemList = await FirebaseFirestore.instance.collection('Language')
        .doc('present_languages')
        .get();

    var data = itemList.data();
    print("Data Language : " + data.toString());

    if(data != null){
      if (data['spanish'] == true && data['english'] == false) {
        setState(() {
          // EasyLocalization.of(context).locale = Locale('es', 'ES');
          // context.setLocale(Locale('es', 'ES'));
        });
      }
      // if (itemList.data['english'] == true && itemList.data['spanish'] == false) {
      if (data['english'] == true && data['spanish'] == false) {
        setState(() {
          // EasyLocalization.of(context).locale = Locale('en', 'US');
          // context.setLocale(Locale('en', 'US'));
        });
      }
    }
    // if (itemList.data['spanish'] == true && itemList.data['english'] == false) {

    // return EasyLocalization.of(context).locale;
  }

  @override
  Widget build(BuildContext context) {
    
    return GetMaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      title: "JablessCupid",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      home: isLoading
          ? Splash()
          : isRegistered
              ? Tabbar(null, null)
              : isAuth
                  ? Welcome()
                  : FirstLogin(),
    );
  }
}
