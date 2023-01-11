import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/user_model.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';
import 'package:hookup4u/infrastructure/dal/util/session.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';

import '../../../domain/core/model/Payment.dart';
import '../services/fcm_service.dart';
import '../util/local_notif.dart';

class GlobalController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Rxn<UserModel> currentUser = Rxn();
  Map<String, dynamic> items = {};
  StreamSubscription<DocumentSnapshot>? streamCurrentUser;
  RxBool isPuchased = false.obs;
  Payment? paymentModel;

  @override
  onInit() async {
    super.onInit();
    if (GetPlatform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();

      var iosToken = await FirebaseMessaging.instance.getAPNSToken();
      print("Ios Token : " + (iosToken ?? ""));
    }
    checkAuth();
    getAccessItems();
  }

  initAfterLogin() {
    listenUser();
  }

  listenUser() {
    streamCurrentUser = FirebaseFirestore.instance
        .doc("Users/${Get.find<GlobalController>().currentUser.value?.id}")
        .snapshots()
        .listen((event) async {
      if (kDebugMode) {
        print(event.data());
      }

      UserModel tempUser =
          UserModel.fromJson(event.data() as Map<String, dynamic>);
      currentUser.value = tempUser;
      currentUser.value!.relasi.value =
          await Global().getRelationship(tempUser.id);
    });
  }

  getAccessItems() async {
    var doc = await FirebaseFirestore.instance.collection("Item_access").get();
    items = doc.docs[0].data();
    print(doc.docs[0].data());
  }

  initPayment() {
    print("Init Payment");
    FirebaseFirestore.instance
        .collection("Payment")
        .doc(currentUser.value?.id)
        .snapshots()
        .listen((event) async {
      print("Payment");
      if (!event.exists) {
        await setUpdatePayment(
          uid: currentUser.value?.id ?? "",
          packageId: "",
          status: false,
          date: DateTime.now(),
          purchasedId: "",
        );
        return;
      }
      paymentModel = Payment.fromDocument(event.data()!);
      if (paymentModel!.status == false) {
        isPuchased.value = false;
      }
      if (paymentModel!.status == true &&
          paymentModel!.date!.isBefore(DateTime.now())) {
        isPuchased.value = false;
        await setUpdatePayment(
            uid: currentUser.value?.id ?? "",
            packageId: "",
            status: false,
            date: DateTime.now(),
            purchasedId: "");
      }
      if (paymentModel!.status && paymentModel!.date!.isAfter(DateTime.now())) {
        isPuchased.value = true;
      }

      //if debug then payment always true
      if (kDebugMode) {
        isPuchased.value = true;
      }
      print(isPuchased);
      update();
    });
  }

  setUpdatePayment({
    required String uid,
    required String packageId,
    required bool status,
    required DateTime date,
    required String purchasedId,
  }) async {
    Map<String, dynamic> newRelation = {
      "userId": uid,
      "packageId": packageId,
      "purchasedId": purchasedId,
      "status": status,
      "date": date.toString(),
    };

    await FirebaseFirestore.instance.collection("Payment").doc(uid).set(
          newRelation,
          SetOptions(
            merge: true,
          ),
        );
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
      Session().saveIntroduction(true);
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

  Future navigationCheck(User user, String metode) async {
    print(user.providerData);
    QuerySnapshot? userAuth = await getUser(user, metode);
    // print(userAuth?.docs);
    if (userAuth == null || userAuth.docs.isEmpty) {
      Get.offAllNamed(Routes.AUTH_REGISTER);
      return;
    }
    if (kDebugMode) {
      print(userAuth.docs.first);
    }
    var docs = userAuth.docs.first;
    if (kDebugMode) {
      print(docs.data());
    }
    Map<String, dynamic> data = docs.data() as Map<String, dynamic>;
    currentUser.value = UserModel.fromJson(data);
    initAfterLogin();
    Get.offAllNamed(Routes.DASHBOARD);
  }

  Future<void> addNewLoginTypeUser(User user, String metode) async {
    Map<String, dynamic> loginID = {
      "fb": "",
      "apple": "",
      "phone": "",
      "google": "",
    };
    QuerySnapshot? userSnapshot = await getUser(user, metode);

    if (userSnapshot == null) {
      Get.toNamed(Routes.AUTH_REGISTER);
      return;
    }

    var userID = "";
    userID = user.uid;
    // print("Masuk gak ya");
    Map<String, dynamic> userModel =
        userSnapshot.docs.first.data() as Map<String, dynamic>;

    print(userModel);
    loginID = {
      "fb": userModel['LoginID']['fb'] ?? "",
      "apple": userModel['LoginID']['apple'] ?? "",
      "phone": userModel['LoginID']['phone'] ?? "",
      "google": userModel['LoginID']['google'] ?? "",
    };
    for (var temp in user.providerData) {
      loginID = Global().getLoginType(temp.providerId, temp.uid ?? "", loginID);
    }
    Map<String, dynamic> data = {
      "LoginID": loginID,
    };
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userID)
        .set(data, SetOptions(merge: true));
  }

  firstAddUser({
    required String metode,
    required Map<String, dynamic> dataExisting,
  }) async {
    if (auth.currentUser == null) {
      Get.snackbar("Information", "User not exist");
      return;
    }
    String url = "";
    if (auth.currentUser?.photoURL != null) {
      url = auth.currentUser!.photoURL! + '?width=9999';
    } else {
      url =
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxUC64VZctJ0un9UBnbUKtj-blhw02PeDEQIMOqovc215LWYKu&s";
    }
    var imageData = {"url": url, "show": "true"};
    Map<String, dynamic> LoginID = {
      "fb": "",
      "apple": "",
      "phone": "",
      "google": "",
    };
    LoginID = Global().getLoginType(metode, auth.currentUser!.uid, LoginID);
    dataExisting.addAll({
      "LoginID": LoginID,
      "metode": auth.currentUser!.providerData[0].providerId,
      'userId': auth.currentUser!.uid,
      // 'UserName': user.displayName ?? '',
      'Pictures': [imageData],
      'phoneNumber': auth.currentUser!.phoneNumber,
      'timestamp': FieldValue.serverTimestamp()
    });
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(auth.currentUser!.uid)
        .set(dataExisting, SetOptions(merge: true));
  }

  sendMatchedFCM({required String idUser, required String name}) async {
    showSimpleNotification(
        title: "Matched", body: "You are matched with $name");
    // UserModel userFCM = Get.find<TabsController>().getUserSelected(idUser);
    String toParams = "/topics/" + idUser;
    var data = {
      "title": "Matched",
      "body": "You are matched with ${currentUser.value?.name}"
    };
    print(data);
    var response = await FCMService().sendFCM(data: data, to: toParams);
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print("Success Request FCM");
      print(result);
      var data = jsonDecode(result);
    } else {
      print(response.reasonPhrase);
    }
  }

  sendLikedFCM({required String idUser, required String name}) async {
    // Get.find<HomeController>().showSimpleNotification(title: "Liked", body: "You are matched with $name");
    // UserModel userFCM = Get.find<TabsConstroller>().getUserSelected(idUser);
    String toParams = "/topics/" + idUser;
    var data = {
      "title": "Liked",
      "body": "Someone just liked your profile! Tap to see if you're a match!",
      "idUser": idUser,
    };
    var notif = {
      "title": "Liked",
      "body": "Someone just liked your profile! Tap to see if you're a match!"
    };
    if (kDebugMode) {
      print(data);
    }
    var response = await FCMService()
        .sendCustomFCM(data: data, to: toParams, notif: notif);
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print("Success Request FCM");
      print(result);
      var data = jsonDecode(result);
    } else {
      print(response.reasonPhrase);
    }
  }

  sendChatFCM({required String idUser, required String name}) async {
    // UserModel userFCM = Get.find<TabsController>().getUserSelected(idUser);
    if (kDebugMode) {
      print("Send Message FCM");
    }
    String toParams = "/topics/" + idUser;
    var data = {"title": "New Chat", "body": "You have new message from $name"};
    var response = await FCMService().sendFCM(data: data, to: toParams);
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print("Success Request FCM");
      print(result);
      var data = jsonDecode(result);
    } else {
      print(response.reasonPhrase);
    }
  }

  sendLeaveFCM({required String idUser, required String name}) async {
    // UserModel userFCM = Get.find<TabsController>().getUserSelected(idUser);
    if (kDebugMode) {
      print("Send Leave FCM");
    }
    String toParams = "/topics/" + idUser;
    var data = {
      "title": "Leaving Chat",
      "body": "$name has left the conversation"
    };
    var response = await FCMService().sendFCM(data: data, to: toParams);
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print("Success Request FCM");
      print(result);
      var data = jsonDecode(result);
    } else {
      print(response.reasonPhrase);
    }
  }

  sendRestoreLeaveFCM({required String idUser, required String name}) async {
    // UserModel userFCM = Get.find<TabsController>().getUserSelected(idUser);
    if (kDebugMode) {
      print("Send Restore Leave FCM");
    }
    String toParams = "/topics/" + idUser;
    var data = {
      "title": "Resume Chat",
      "body": "$name has resumed the conversation"
    };
    var response = await FCMService().sendFCM(data: data, to: toParams);
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print("Success Request FCM");
      print(result);
      var data = jsonDecode(result);
    } else {
      print(response.reasonPhrase);
    }
  }

  sendDisconnectFCM({required String idUser, required String name}) async {
    // UserModel userFCM = Get.find<TabsController>().getUserSelected(idUser);
    if (kDebugMode) {
      print("Send Blocked FCM");
    }
    String toParams = "/topics/" + idUser;
    var data = {"title": "Blocked Chat", "body": "$name has blocked you"};
    var response = await FCMService().sendFCM(data: data, to: toParams);
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print("Success Request FCM");
      print(result);
      var data = jsonDecode(result);
    } else {
      print(response.reasonPhrase);
    }
  }
}
