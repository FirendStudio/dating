import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hookup4u/Controller/ChatController.dart';
import 'package:hookup4u/Controller/NotificationController.dart';
import 'package:hookup4u/models/Payment.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../Screens/Chat/Matches.dart';
import '../Screens/Widget/DialogFirstApp.dart';
import '../models/Relationship.dart';
import '../models/user_model.dart';
import '../util/Global.dart';
import '../util/consumable_store.dart';
import 'HomeController.dart';
import 'LoginController.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class TabsController extends GetxController{
  CollectionReference docRef = FirebaseFirestore.instance.collection('Users');
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserModel currentUser;
  List<UserModel> Allmatches = [];
  List<UserModel> matches = [];
  List<UserModel> newmatches = [];
  FirebaseMessaging _firebaseMessaging;
  List userRemoved = [];
  int countswipe = 1;
  List<UserModel> users = [];
  List<UserModel> allUsers = [];
  UserModel selectedUser;
  List likedByList = [];
  /// Past purchases
  // List<PurchaseDetails> purchases = [];
  InAppPurchase _iap = InAppPurchase.instance;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> notFoundIds = [];
  List<ProductDetails> products = [];
  List<PurchaseDetails> purchases = [];
  List<String> listCheck = ["A"];
  List<String> consumables = [];
  bool isAvailable = false;
  bool purchasePending = false;
  bool loading = true;
  String queryProductError;
  bool isPuchased = false;
  bool kAutoConsume = true;
  String kConsumableId = 'consumable';
  Payment paymentModel;

  Map<String, dynamic> items = {};
  int init = 0;
  int indexUser = 0;
  int indexImage = 0;
  List checkedUser = [];
  GetStorage storage = GetStorage();

  List<String> kProductIds = <String>[
    "monthly",
    "quarterly",
  ];

  initAllTab(BuildContext context){
    if(init == 0){
      getAccessItems();
      getCurrentUser(context);
      getMatches();
      Get.find<NotificationController>().initNotification();
      initPayment();
      initNewCheckPayment();
      init = 1;
      firstLoginApp();
    }

  }

  Future <void> firstLoginApp() async {
    await Future.delayed(Duration(seconds: 4));
    bool cek = storage.read("isLogin")??false;
    print("Cek isLogin : "+ cek.toString());
    if(!cek){
      await storage.write("isLogin", true);
      Get.to(()=>DialogFirstApp());
    }
  }

  initNewCheckPayment(){
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      print(purchaseDetailsList);
      listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      print("done");
      _subscription.cancel();
    }, onError: (error) {
      print(error);
      // handle error here.
    });
    initStoreInfo();
  }

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // showPendingUI();
        purchasePending = true;
        update();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // handleError(purchaseDetails.error!);
          purchasePending = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == kConsumableId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
            _inAppPurchase.getPlatformAddition<
                InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  void handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID);
      List<String> consumables = await ConsumableStore.load();
      purchasePending = false;
      consumables = consumables;
      update();
    } else {
      purchases.add(purchaseDetails);
      purchasePending = false;
      update();
    }
  }

  Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  Future<void> initStoreInfo() async {
    final bool check = await _inAppPurchase.isAvailable();
    if (!check) {
      isAvailable = check;
      products = [];
      purchases = [];
      notFoundIds = [];
      consumables = [];
      purchasePending = false;
      loading = false;
      update();
      return;
    }


    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(kProductIds.toSet());
    // print("Detail produk ");
    // print(productDetailResponse.productDetails[1].title);
    if (productDetailResponse.error != null) {

      queryProductError = productDetailResponse.error.message;
      isAvailable = isAvailable;
      products = productDetailResponse.productDetails;
      purchases = [];
      notFoundIds = productDetailResponse.notFoundIDs;
      consumables = [];
      purchasePending = false;
      loading = false;
      update();
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      queryProductError = null;
      isAvailable = isAvailable;
      products = productDetailResponse.productDetails;
      purchases = [];
      notFoundIds = productDetailResponse.notFoundIDs;
      consumables = [];
      purchasePending = false;
      loading = false;
      update();
      return;
    }
    // print(consumables);
    List<String> listconsumables = await ConsumableStore.load();
    isAvailable = isAvailable;
    products = productDetailResponse.productDetails;
    print(products);
    notFoundIds = productDetailResponse.notFoundIDs;
    consumables = listconsumables;
    // print(consumables);
    purchasePending = false;
    loading = false;
    // update();
  }

  initPayment(){
    print("Init Payment");
    FirebaseFirestore.instance.collection("Payment")
        .doc(Get.find<LoginController>().userId)
        .snapshots().listen((event) async {
      print("Payment");
      if(!event.exists){
        await setUpdatePayment(uid: Get.find<LoginController>().userId, packageId: "", status: false, date: DateTime.now(), purchasedId: "");
        return;
      }
      paymentModel = Payment.fromDocument(event.data());
      if(paymentModel.status == false){
        isPuchased = false;
      }
      if(paymentModel.status && paymentModel.date.isBefore(DateTime.now())){
        isPuchased = false;
        await setUpdatePayment(uid: Get.find<LoginController>().userId, packageId: "", status: false, date: DateTime.now(), purchasedId: "");
      }
      if(paymentModel.status && paymentModel.date.isAfter(DateTime.now())){
        isPuchased = true;
      }

      //if debug then payment always true
      if(kDebugMode){
        isPuchased = true;
      }
      print(isPuchased);
      update();

    });

  }

  setUpdatePayment({@required String uid, @required String packageId, @required bool status, @required DateTime date,
    @required String purchasedId
  }) async {
    Map <String, dynamic> newRelation = {
      "userId" : uid,
      "packageId" : packageId,
      "purchasedId" : purchasedId,
      "status" : status,
      "date" : date.toString(),
    };

    await FirebaseFirestore.instance
        .collection("Payment")
        .doc(uid)
        .set(newRelation,
        SetOptions(merge : true)
    );
  }

  String capitalize(String text) {
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  getAccessItems() async {
    FirebaseFirestore.instance.collection("Item_access").snapshots().listen((doc) {
      if (doc.docs.length > 0) {
        // items = doc.docs[0].data;
        items = doc.docs[0].data();
        print(doc.docs[0].data());
        update();
      }

      // if (mounted) setState(() {});
    });
  }

  // Future<void> _getpastPurchases() async {
  //   print('in past purchases');
  //   QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
  //   print('response   ${response.pastPurchases}');
  //   for (PurchaseDetails purchase in response.pastPurchases) {
  //     // if (Platform.isIOS) {
  //     await _iap.completePurchase(purchase);
  //     // }
  //   }
  //   setState(() {
  //     purchases = response.pastPurchases;
  //   });
  //   if (response.pastPurchases.length > 0) {
  //     purchases.forEach((purchase) async {
  //       print('   ${purchase.productID}');
  //       await _verifyPuchase(purchase.productID);
  //     });
  //   }
  // }

  /// check if user has pruchased
  PurchaseDetails hasPurchased(String productId) {
    return purchases.firstWhere((purchase) => purchase.productID == productId,
        orElse: () => null);
  }

  ///verifying pourchase of user
  Future<void> verifyPuchase(String id) async {
    PurchaseDetails purchase = hasPurchased(id);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      print(purchase.productID);
      if (Platform.isIOS) {
        await _iap.completePurchase(purchase);
        print('Achats antérieurs........$purchase');
        isPuchased = true;
      }
      isPuchased = true;
    } else {
      isPuchased = false;
    }
  }

  int swipecount = 0;
  getSwipedcount() {
    FirebaseFirestore.instance.collection('/Users/${currentUser.id}/CheckedUser')
    .where('timestamp', isGreaterThan: Timestamp.now().toDate().subtract(Duration(days: 1)),)
    .snapshots()
    .listen((event) {
      print(event.docs.length);
      swipecount = event.docs.length;
      update();
      return event.docs.length;
    });
  }

  getMatches() async {
    User user = _firebaseAuth.currentUser;
    return FirebaseFirestore.instance
        .collection('/Users/${user.uid}/Matches')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((ondata) async {
      matches.clear();
      newmatches.clear();
      print(ondata.docs.length);
      List<String> listIDChat = [];
      if (ondata.docs.length > 0) {
        if(Get.find<ChatController>().checkStreamChat){
          Get.find<ChatController>().streamChat.cancel();
        }
        Get.find<NotificationController>().listMatchUserAll = ondata.docs;
        // Get.find<NotificationController>().listTempMatch = ondata.docs;
        Get.find<NotificationController>().filterLiked();

        for(var i in ondata.docs){
          listIDChat.add(Get.find<ChatController>().chatIdCustom(currentUser.id, i.id));
          var doc = await docRef.doc(i['Matches']).get();
          if (doc.exists) {
            UserModel tempuser = UserModel.fromDocument(doc);
            tempuser.distanceBW = calculateDistance(
                currentUser.coordinates['latitude'],
                currentUser.coordinates['longitude'],
                tempuser.coordinates['latitude'],
                tempuser.coordinates['longitude'])
                .round();

            matches.add(tempuser);
            newmatches.add(tempuser);
            Allmatches.add(tempuser);
            update();
            // if (mounted) setState(() {});
          }
        }
        if(kDebugMode){
          print("List ID Chat : " + listIDChat.length.toString());
          print("List ListMatches : " + newmatches.length.toString());
        }
        
        Get.find<ChatController>().initListChat(listIDChat);
      }
    });
  }

  

  getCurrentUser(BuildContext context) async {
    User user = _firebaseAuth.currentUser;
    // return docRef.doc("${user.uid}").snapshots().listen((data) async {
    return docRef.doc(Get.find<LoginController>().userId).snapshots().listen((data) async {
      print(data);
      currentUser = UserModel.fromDocument(data);
      update();
      // if (mounted) setState(() {});
      users.clear();
      userRemoved.clear();
      getUserList();
      getLikedByList();
      configurePushNotification(currentUser, context);
      if (!isPuchased) {
        getSwipedcount();
      }
      return currentUser;
    });
  }

  configurePushNotification(UserModel user, BuildContext context) async {

    // await FirebaseMessaging.instance.requestPermission(
    //     IosNotificationSettings(
    //         alert: true, sound: true, provisional: false, badge: true)
    // );
    await Get.find<HomeController>().initFCM(docRef, user, context);
    // _firebaseMessaging.configure(
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print('===============onLaunch$message');
    //     if (Platform.isIOS && message['type'] == 'Call') {
    //       Map callInfo = {};
    //       callInfo['channel_id'] = message['channel_id'];
    //       callInfo['senderName'] = message['senderName'];
    //       callInfo['senderPicture'] = message['senderPicture'];
    //       bool iscallling = await _checkcallState(message['channel_id']);
    //       print("=================$iscallling");
    //       if (iscallling) {
    //         await Navigator.push(context,
    //             MaterialPageRoute(builder: (context) => Incoming(message)));
    //       }
    //     } else if (Platform.isAndroid && message['data']['type'] == 'Call') {
    //       bool iscallling =
    //       await _checkcallState(message['data']['channel_id']);
    //       print("=================$iscallling");
    //       if (iscallling) {
    //         await Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //                 builder: (context) => Incoming(message['data'])));
    //       } else {
    //         print("Timeout");
    //       }
    //     }
    //   },
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onmessage$message");
    //     if (Platform.isIOS && message['type'] == 'Call') {
    //       Map callInfo = {};
    //       callInfo['channel_id'] = message['channel_id'];
    //       callInfo['senderName'] = message['senderName'];
    //       callInfo['senderPicture'] = message['senderPicture'];
    //       await Navigator.push(context,
    //           MaterialPageRoute(builder: (context) => Incoming(callInfo)));
    //     } else if (Platform.isAndroid && message['data']['type'] == 'Call') {
    //       await Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => Incoming(message['data'])));
    //     } else
    //       print("object");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print('onResume$message');
    //     if (Platform.isIOS && message['type'] == 'Call') {
    //       Map callInfo = {};
    //       callInfo['channel_id'] = message['channel_id'];
    //       callInfo['senderName'] = message['senderName'];
    //       callInfo['senderPicture'] = message['senderPicture'];
    //       bool iscallling = await _checkcallState(message['channel_id']);
    //       print("=================$iscallling");
    //       if (iscallling) {
    //         await Navigator.push(context,
    //             MaterialPageRoute(builder: (context) => Incoming(message)));
    //       }
    //     } else if (Platform.isAndroid && message['data']['type'] == 'Call') {
    //       bool iscallling =
    //       await _checkcallState(message['data']['channel_id']);
    //       print("=================$iscallling");
    //       if (iscallling) {
    //         await Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //                 builder: (context) => Incoming(message['data'])));
    //       } else {
    //         print("Timeout");
    //       }
    //     }
    //   },
    // );
  }



  query() {

    return docRef
    .where('age', isGreaterThanOrEqualTo: int.parse(currentUser.ageRange['min']),)
    .where('age',
    isLessThanOrEqualTo: int.parse(currentUser.ageRange['max']))
    .orderBy('age', descending: false);

    // if (currentUser.showGender == 'everyone') {
    //   return docRef
    //       .where(
    //         'age',
    //         isGreaterThanOrEqualTo: int.parse(currentUser.ageRange['min']),
    //       )
    //       .where('age',
    //           isLessThanOrEqualTo: int.parse(currentUser.ageRange['max']))
    //       .orderBy('age', descending: false);
    // } else {
    //   return docRef
    //       .where('editInfo.userGender', isEqualTo: currentUser.showGender)
    //       .where(
    //         'age',
    //         isGreaterThanOrEqualTo: int.parse(currentUser.ageRange['min']),
    //       )
    //       .where('age',
    //           isLessThanOrEqualTo: int.parse(currentUser.ageRange['max']))
    //       //FOR FETCH USER WHO MATCH WITH USER SEXUAL ORIENTAION
    //       // .where('sexualOrientation.orientation',
    //       //     arrayContainsAny: currentUser.sexualOrientation)
    //       .orderBy('age', descending: false);
    // }
  }

  Future getUserList() async {
    checkedUser = [];
    FirebaseFirestore.instance
        .collection('/Users/${currentUser.id}/CheckedUser')
    // .collection('/Users/${currentUser.id}')
        .get()
        .then((data) {
      print("Cek User List");

      // print(dataAll.get("LikedUser"));
      data.docs.forEach((element) {
        print(element.data()["LikedUser"]);
        if(element.data()["LikedUser"] == null){
          checkedUser.add(element.data()["DislikedUser"]);
        }else{
          checkedUser.add(element.data()["LikedUser"]);
        }
      });
      print(checkedUser);

    }).then((_) {
      query().get().then((data) async {
        print(data);
        QuerySnapshot result = data;
        if (result.docs.length < 1) {
          print("no more data");
          return;
        }
        users.clear();
        userRemoved.clear();
        for (var doc in result.docs) {
          UserModel temp = UserModel.fromDocument(doc);
          allUsers.add(temp);
          var distance = calculateDistance(
              currentUser.coordinates['latitude'],
              currentUser.coordinates['longitude'],
              temp.coordinates['latitude'],
              temp.coordinates['longitude']);
          temp.distanceBW = distance.round();
          if (checkedUser.any((value) => value == temp.id,)) {

          } else {
            print("Jarak : " + distance.toString());
            print(currentUser.maxDistance);
            if (distance <= currentUser.maxDistance && temp.id != currentUser.id && !temp.isBlocked) {
              if(temp.imageUrl.isNotEmpty){
                List imageUrlTemp = [];
                for(int i =0; i <= temp.imageUrl.length-1; i++){
                  if(temp.imageUrl[i].runtimeType == String){
                    imageUrlTemp.add({
                      "url": temp.imageUrl[i],
                      "show": "true"
                    });

                  }else{
                    if(temp.imageUrl[i]['show'] == "true"){
                      imageUrlTemp.add(temp.imageUrl[i]);

                    }
                  }

                }
                var data = await FirebaseFirestore.instance.collection("Relationship").doc(temp.id).get();
                if(!data.exists){
                  await Get.find<NotificationController>().setNewRelationship(temp.id);
                  data = await FirebaseFirestore.instance.collection("Relationship").doc(temp.id).get();
                }
                Relationship relationUserPartner = Relationship.fromDocument(data.data());

                users.add(UserModel(
                    id: temp.id,
                    age: temp.age,
                    address: temp.address,
                    name: temp.name,
                    imageUrl: imageUrlTemp,
                    editInfo: temp.editInfo,
                    LoginID: temp.LoginID,
                    metode: temp.metode,
                    gender: temp.gender,
                    ageRange: temp.ageRange,
                    coordinates: temp.coordinates,
                    maxDistance: temp.maxDistance,
                    interest: temp.interest,
                    desires: temp.desires,
                    distanceBW: distance.toStringAsFixed(0),
                    isBlocked: temp.isBlocked,
                    phoneNumber: temp.phoneNumber,
                    showingGender: temp.showingGender,
                    sexualOrientation: temp.sexualOrientation,
                    showingOrientation: temp.showingOrientation,
                    showMe: temp.showMe,
                    status: temp.status,
                    kinks: temp.kinks,
                    lastmsg: temp.lastmsg,
                    relasi: relationUserPartner,
                    fcmToken: temp.fcmToken
                ));
                // temp.distanceBW = Get.find<TabsController>().calculateDistance(
                //     Get.find<TabsController>().currentUser.coordinates['latitude'],
                //     Get.find<TabsController>().currentUser.coordinates['longitude'],
                //     temp.coordinates['latitude'],
                //     temp.coordinates['longitude']).round();
              }else{
                users.add(temp);
              }

            }
            // final List<String> listIDRelationship = users.map((city) => city.id).toList();

            // initListLikedUser();

            print(users);

          }
        }
        update();
        // if (mounted) setState(() {});
      });
    });
  }

  dynamic getUserSelected(idUser){
    UserModel selected;
    selected = allUsers.firstWhere((element) => element.id == idUser, orElse:()=>selected);
    return selected;
  }

  getLikedByList() {
    docRef.doc(Get.find<LoginController>().userId)
    .collection("LikedBy")
    .orderBy('LikedBy', descending: true)
    .snapshots()
    .listen((data) async {
      likedByList.addAll(data.docs.map((f) => f['LikedBy']));
      Get.find<NotificationController>().listLikedUserAll = [];
      Get.find<NotificationController>().listLikedUserAll = data.docs;
      print("LikedBy Test");
      print(Get.find<NotificationController>().listLikedUserAll);
      Get.find<NotificationController>().filterLiked();
      update();
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}