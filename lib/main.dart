import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    print(user);
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: user.uid)
          .get()
          .then((QuerySnapshot snapshot) async {
        if (snapshot.docs.length > 0) {
          // if (snapshot.docs[0].data['location'] != null) {
          if (snapshot.docs[0]['location'] != null) {
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

    if(itemList['spanish'] != null){
      if (itemList['spanish'] == true && itemList['english'] == false) {
        setState(() {
          // EasyLocalization.of(context).locale = Locale('es', 'ES');
          // context.setLocale(Locale('es', 'ES'));
        });
      }
      // if (itemList.data['english'] == true && itemList.data['spanish'] == false) {
      if (itemList['english'] == true && itemList['spanish'] == false) {
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
                  : Login(),
    );
  }
}
