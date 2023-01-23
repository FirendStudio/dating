import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/SuspendModel.dart';
import 'package:hookup4u/domain/core/model/user_model.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:hookup4u/infrastructure/dal/util/session.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';
import '../../../domain/core/model/Payment.dart';
import '../../../presentation/dashboard/view/home/controllers/home.controller.dart';
import '../services/fcm_service.dart';
import '../util/local_notif.dart';

class GlobalController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Rxn<UserModel> currentUser = Rxn();
  Map<String, dynamic> items = {};
  StreamSubscription<DocumentSnapshot>? streamCurrentUser;
  StreamSubscription<DocumentSnapshot>? streamPayment;
  StreamSubscription<DocumentSnapshot>? streamSuspend;
  RxBool isPurchased = false.obs;
  Payment? paymentModel;
  List<int> listAge = [];
  RxInt distance = 0.obs;
  int initFCM = 0;
  Rxn<ReviewModel> reviewModel = Rxn();

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

  @override
  onClose() {
    super.onClose();
    streamCurrentUser?.cancel();
    streamPayment?.cancel();
    streamSuspend?.cancel();
  }

  initAfterLogin() {
    listenUser();
    initPayment();
    listenSuspend();
    for (int i = 18; i <= 99; i++) {
      listAge.add(i);
    }
  }

  listenSuspend() {
    streamSuspend = queryDocDB("Review/${currentUser.value?.id}")
        .snapshots()
        .listen((event) async {
      if (!event.exists) {
        return;
      }
      if (kDebugMode) {
        print(event.data());
      }

      reviewModel.value =
          ReviewModel.fromJson(event.data() as Map<String, dynamic>);
      reviewModel.value?.status?.value = reviewModel.value?.getStatus();
      reviewModel.value?.reason?.value = reviewModel.value?.getReason();
    });
  }

  initFirebaseMessaging() async {
    if (initFCM == 1) {
      return;
    }
    initFCM = 1;
    FirebaseMessaging.instance.subscribeToTopic("${currentUser.value?.id}");
    FirebaseMessaging.instance.subscribeToTopic("all");
    if (kDebugMode) {
      print("Subcribe to ${currentUser.value?.id}");
    }
    await FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (kDebugMode) {
        print('Firebase Connect');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      showNotification(message);
    });
  }

  listenUser() {
    streamCurrentUser = queryDocDB(
            "Users/${Get.find<GlobalController>().currentUser.value?.id}")
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
      bool cek = Get.isRegistered<HomeController>();
      if(kDebugMode){
        print("Cek Home is registered : " + cek.toString());
      }
      if (cek) {
        Get.find<HomeController>().initUser();
      }
      initFirebaseMessaging();
    });
  }

  getAccessItems() async {
    var doc = await queryCollectionDB("Item_access").get();
    items = doc.docs[0].data();
    print(doc.docs[0].data());
  }

  initPayment() {
    print("Init Payment");
    streamPayment = queryCollectionDB("Payment")
        .doc(currentUser.value?.id)
        .snapshots()
        .listen((event) async {
      if (!event.exists) {
        await setUpdatePayment(
          uid: currentUser.value?.id ?? "",
          packageId: "",
          status: false,
          date: DateTime.now(),
          purchasedId: "",
        );
        isPurchased.value = false;
        return;
      }
      paymentModel = Payment.fromDocument(event.data()!);
      if (paymentModel!.status == false) {
        isPurchased.value = false;
      }
      if (paymentModel!.status == true &&
          paymentModel!.date!.isBefore(DateTime.now())) {
        isPurchased.value = false;
        await setUpdatePayment(
          uid: currentUser.value?.id ?? "",
          packageId: "",
          status: false,
          date: DateTime.now(),
          purchasedId: "",
        );
      }
      if (paymentModel!.status && paymentModel!.date!.isAfter(DateTime.now())) {
        isPurchased.value = true;
      }

      if (kDebugMode) {
        isPurchased.value = true;
      }
      if (kDebugMode) {
        print("Payment Status : " + isPurchased.value.toString());
      }
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

    await queryCollectionDB("Payment").doc(uid).set(
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
        var result = await queryCollectionDB('Users')
            .where(type, isEqualTo: user.uid)
            .limit(1)
            .get();
        data = result;
        if (result.docs.isNotEmpty) {
          break;
        }
      }
    } else {
      data = await queryCollectionDB('Users')
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

    Map<String, dynamic> data = docs.data() as Map<String, dynamic>;
    currentUser.value = UserModel.fromJson(data);
    if (kDebugMode) {
      print(docs.data());
      print("ID User : " + (currentUser.value?.id ?? ""));
    }
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
    await queryCollectionDB("Users")
        .doc(userID)
        .set(data, SetOptions(merge: true));
  }

  firstAddUser({
    required String metode,
    required Map<String, dynamic> dataExisting,
  }) async {
    if (auth.currentUser == null) {
      Global().showInfoDialog("User not exist");
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
    await queryCollectionDB("Users")
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