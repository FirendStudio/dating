import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/NotificationController.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/user_model.dart';
import 'HomeController.dart';
import 'LoginController.dart';

class TabsController extends GetxController{
  CollectionReference docRef = FirebaseFirestore.instance.collection('Users');
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserModel currentUser;
  List<UserModel> matches = [];
  List<UserModel> newmatches = [];
  FirebaseMessaging _firebaseMessaging;
  List userRemoved = [];
  int countswipe = 1;
  List<UserModel> users = [];
  List likedByList = [];
  /// Past purchases
  List<PurchaseDetails> purchases = [];
  InAppPurchase _iap = InAppPurchase.instance;
  bool isPuchased = false;

  Map<String, dynamic> items = {};
  int init = 0;
  List checkedUser = [];
  initAllTab(BuildContext context){
    if(init == 0){
      getAccessItems();
      getCurrentUser(context);
      getMatches();
      Get.find<NotificationController>().initNotification();
      init = 1;
    }

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
        .listen((ondata) {
      matches.clear();
      newmatches.clear();
      print(ondata.docs.length);
      if (ondata.docs.length > 0) {
        ondata.docs.forEach((f) async {
          await docRef
          // .doc(f.data['Matches'])
              .doc(f['Matches'])
              .get()
              .then((DocumentSnapshot doc) {
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
              update();
              // if (mounted) setState(() {});
            }
          });
        });
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
        .where(
      'age',
      isGreaterThanOrEqualTo: int.parse(currentUser.ageRange['min']),
    )
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
      // var cek = data.docs.map((doc) => doc.get('DislikedUser')).toList();
      // print(cek);
      // var dataDislike = data.docs.map((f) {
      //   f['DislikedUser'] ?? "";
      // });
      // print(dataDislike);
      print("Cek");

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
      // checkedUser.addAll(data.docs.map((f) => f['DislikedUser']) ?? []);
      // print(dataAll.get('LikedUser'));

      // if(dataDislike. != null){
      //   // checkedUser.addAll(data.docs.map((f) => f['DislikedUser']));
      //   checkedUser.addAll(dataDislike);
      // }
      // var dataLike = data.docs.map((f) => f['LikedUser']);
      // if(dataLike != null){
      //   // checkedUser.addAll(data.docs.map((f) => f['LikedUser']));
      //   checkedUser.addAll(dataLike);
      // }

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
          var distance = calculateDistance(
              currentUser.coordinates['latitude'],
              currentUser.coordinates['longitude'],
              temp.coordinates['latitude'],
              temp.coordinates['longitude']);
          temp.distanceBW = distance.round();
          if (checkedUser.any((value) => value == temp.id,)) {

          } else {
            print(distance);
            print(currentUser.maxDistance);
            if (distance <= currentUser.maxDistance &&
                temp.id != currentUser.id && !temp.isBlocked) {
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
                users.add(UserModel(
                    id: temp.id,
                    age: temp.age,
                    address: temp.address,
                    name: temp.name,
                    imageUrl: imageUrlTemp
                ));
              }else{
                users.add(temp);
              }

            }
            print(users);
          }
        }
        update();
        // if (mounted) setState(() {});
      });
    });
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