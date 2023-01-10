import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/user_model.dart';
import 'package:hookup4u/infrastructure/dal/util/session.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';

class GlobalController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  static const your_redirect_url =
      'https://jablesscupid.firebaseapp.com/__/auth/handler';
  late UserModel currentUser;

  @override
  onInit() async {
    super.onInit();
    if (GetPlatform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();

      var iosToken = await FirebaseMessaging.instance.getAPNSToken();
      print("Ios Token : " + (iosToken ?? ""));
    }
    checkAuth();
  }

  Future<QuerySnapshot?> getUser(User user, String metode) async {
    print("metode login ID : " + metode);
    QuerySnapshot? data;
    String type = getTypeMetode(metode);
    if (user.providerData.length > 1) {
      for (int index = 0; index <= user.providerData.length - 1; index++) {
        var userProvider = user.providerData[index];
        type = getTypeMetode(userProvider.providerId);
        print("Type : $type" + " ID : " + user.uid);
        var result = await FirebaseFirestore.instance
            .collection('Users')
            .where(type, isEqualTo: user.uid)
            .limit(1)
            .get();
        data = result;
        if (result.docs.isNotEmpty) {
          break;
        }
      }
    } else {
      data = await FirebaseFirestore.instance
          .collection('Users')
          .where(type, isEqualTo: user.uid)
          .limit(1)
          .get();
    }
    return data;
  }

  String getTypeMetode(String metode) {
    String type = '';
    if (metode == "apple.com" || metode == "apple") {
      type = 'LoginID.apple';
    } else if (metode == "phone") {
      type = 'LoginID.phone';
    } else if (metode == "google" || metode == "google.com") {
      type = 'LoginID.google';
    } else {
      type = 'LoginID.fb';
    }
    return type;
  }

  Future checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!Session().getIntroduction()) {
      Get.offAllNamed(Routes.WELCOME);
      return;
    }
    User? user = auth.currentUser;
    print(user);
    if (user == null) {
      Get.offAllNamed(Routes.AUTH_LOGIN);
      return;
    }
    if (kDebugMode) {
      print("ID User : " + user.uid);
    }
    String cek = user.providerData[0].providerId;
    navigationCheck(user, cek);
  }

  Future navigationCheck(User user, String metode,
      {bool isDouble = false}) async {
    print(user);
    QuerySnapshot? userAuth = await getUser(user, metode);
    if (userAuth == null) {
      Get.offAllNamed(Routes.AUTH_REGISTER);
      return;
    }
    if (kDebugMode) {
      print(userAuth.docs);
    }
    var docs = userAuth.docs.first;
    if (kDebugMode) {
      print(docs.data());
    }
    Map<String, dynamic> data = docs.data() as Map<String, dynamic>;
    currentUser = UserModel.fromJson(data);
    return;
  }
}
