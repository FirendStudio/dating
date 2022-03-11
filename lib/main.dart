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
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Splash.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:hookup4u/Screens/Welcome.dart';
import 'package:hookup4u/Screens/auth/login.dart';
import 'package:hookup4u/ads/ads.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/firebase_config.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await EasyLocalization.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);
  }else{
    await Firebase.initializeApp();

    // if(Platform.isIOS){
    //   await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);
    //
    //
    // }else{
    // }

  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]).then((_) {
    // InAppPurchaseConnection.enablePendingPurchases();
    //runApp(new MyApp());
    runApp(MyApp());
  });
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
      await FirebaseFirestore.instance
      .collection('Users')
      .where('userId', isEqualTo: user.uid)
      .limit(1)
      .get()
      .then((QuerySnapshot snapshot) async {

        // var data = snapshot.data();

        if (snapshot.docs.length > 0) {

          print(snapshot.docs);
          var docs = snapshot.docs.first;
          print(docs.data());
          Map<String, dynamic> data = docs.data();
          // var data['']
          // if (snapshot.docs[0].data['location'] != null) {
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
          print("loggedin ${user.uid}");
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
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
