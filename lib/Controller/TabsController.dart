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
import '../util/color.dart';
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
  List<String> listUidSwiped = [];

  List<String> kProductIds = <String>[
    "monthly_unjabbed",
    "quarterly_unjabbed",
  ];

  @override
  onInit(){
    super.onInit();
    getAccessItems();
  }

  initAllTab(BuildContext context) async {
    if(init == 0){
      // getAccessItems();
      if(storage.read("listUidSwiped") != null){
        listUidSwiped = storage.read("listUidSwiped").cast<String>() ?? [];
      }
      getCurrentUser(context);
      getMatches();
      Get.find<NotificationController>().initNotification();
      initPayment();
      initNewCheckPayment();
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
      Allmatches.clear();
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
      if(kDebugMode){
        print(data);
      }
      currentUser = UserModel.fromDocument(data);
      update();
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
    await Get.find<HomeController>().initFCM(docRef, user, context);
  }

  Query query() {
    
    return docRef
    // .limit(5)
    .where('age', isGreaterThanOrEqualTo: int.parse(currentUser.ageRange['min']), isLessThanOrEqualTo: int.parse(currentUser.ageRange['max']))
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
  bool filterLastSwiped(String idUID){
    if(listUidSwiped.isEmpty){
      return false;
    }
    var data = listUidSwiped.firstWhereOrNull((element) => element == idUID);
    if(data == null){
      return false;
    }
    return true;
  }

  addLastSwiped(String idUID, int nextIndex){
    if(kDebugMode){
      print("Adding user to last Swiped : " + idUID);
    }
    if(nextIndex == users.length-1 && indexUser == 0){
      if(kDebugMode){
        print("User Swiped left");
      }
      return;
    }
    if( nextIndex < indexUser){
      if(kDebugMode){
        print("User Swiped left");
      }
      return;
    }
    if(listUidSwiped.isEmpty){
      listUidSwiped.add(idUID);
      storage.write("listUidSwiped", listUidSwiped);
      return;
    }
    var data = listUidSwiped.firstWhereOrNull((element) => element == idUID);
    if(data == null){
      listUidSwiped.add(idUID);
      storage.write("listUidSwiped", listUidSwiped);
      return;
    }
    if(kDebugMode){
      print("User already exist");
    }
  }

  List<QueryDocumentSnapshot<Object>> getLastSwipe(List<QueryDocumentSnapshot<Object>> result){
    List<QueryDocumentSnapshot<Object>> listTempResult = [];
    List<QueryDocumentSnapshot<Object>> listTemp = [];
    for (var doc in result) {
      Map<String, dynamic> map = doc.data();
      if(kDebugMode){
        print(doc.id);
      }
      bool cek = filterLastSwiped(map['userId']);
      if(kDebugMode){
        print(cek);
      }
      if(cek){
        listTemp.add(doc);
      }else{
        listTempResult.add(doc);
      }
    }
    listTempResult.addAll(listTemp);
    return listTempResult;
  }

  Future getUserList() async {
    checkedUser = [];
    FirebaseFirestore.instance
        .collection('/Users/${currentUser.id}/CheckedUser')
    // .collection('/Users/${currentUser.id}')
        .get()
        .then((data) {
      

      data.docs.forEach((element) {
        print(element.data()["LikedUser"]);
        if(element.data()["LikedUser"] == null){
          checkedUser.add(element.data()["DislikedUser"]);
        }else{
          checkedUser.add(element.data()["LikedUser"]);
        }
      });
      
    }).then((_) async {
      await query().get().then((data) async {
        print(data);
        if (data.docs.length < 1) {
          print("no more data");
          return;
        }
        List<QueryDocumentSnapshot<Object>> result = data.docs;
        result = getLastSwipe(result);
        users.clear();
        userRemoved.clear();
        for (var doc in result) {
          print(doc.data());
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

            if(kDebugMode){
              print("Jarak : " + distance.toString());
              print(currentUser.maxDistance);
            }
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
                    fcmToken: temp.fcmToken,
                    listSwipedUser : temp.listSwipedUser,
                    countryName: temp.countryName,
                    countryID: temp.countryID,
                    verified: temp.verified
                    
                ));
              }else{
                users.add(temp);
              }

            }

            if(kDebugMode){
              print(users);
            }
          }
        }
        update();
        // if (mounted) setState(() {});
      });
      init = 1;
      update();
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

  disloveFunction() async {
    if (users.length > 0) {
      print("object 1");
      await docRef
          .doc(Get.find<LoginController>().userId)
          .collection("CheckedUser")
          .doc(users[indexUser].id)
          .set({
        'userName': users[indexUser].name,
        'pictureUrl': (users[indexUser].imageUrl[0].runtimeType == String)
            ?users[indexUser].imageUrl[0]:users[indexUser].imageUrl[0]['url'],
        'DislikedUser':
        users[indexUser].id,
        'timestamp': DateTime.now(),
      }, SetOptions(merge : true)
      );

      if (indexUser < users.length) {
        userRemoved.clear();
        userRemoved.add(users[indexUser]);
        users.removeAt(indexUser);
        
        indexImage = 0;
        if(indexUser != 0){
          indexUser--;
        }
      }
      // swipeKey.currentState.swipeLeft();

    }
  }

  bool getSelectedUserIndex(String idUser){

    var selectedUser = users.firstWhereOrNull((element) => element.id == idUser);
    if(selectedUser != null){
      return true;
    }
    return false;
  }

  loveUserFunction() async {
    if (users.length > 0) {
      bool cek = false;
      print(users[indexUser].name);
      // swipeKey.currentState.swipeRight();
      print(users[indexUser].name);
      if (likedByList.contains(users[indexUser].id)) {
        cek = true;
        print("Masuk sini");

        Get.find<NotificationController>().sendMatchedFCM(
          idUser:users[indexUser].id,
          name: users[indexUser].name
        );
        showDialog(
            context: Get.context,
            builder: (ctx) {
              Future.delayed(
                  Duration(milliseconds: 1700),
                      () {
                    Navigator.pop(ctx);
                  });
              return Padding(
                padding: const EdgeInsets.only(
                    top: 80),
                child: Align(
                  alignment:
                  Alignment.topCenter,
                  child: Card(
                    child: Container(
                      height: 100,
                      width: 300,
                      child: Center(
                          child: Text(
                            "It's a match\n With ",
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 30,
                                decoration:
                                TextDecoration
                                    .none),
                          )
                        // .tr(args: ['${widget.users[index].name}']),
                      ),
                    ),
                  ),
                ),
              );
            });
        await docRef
            .doc(Get.find<LoginController>().userId)
            .collection("Matches")
            .doc(users[indexUser].id)
            .set(
            {
              'Matches': users[indexUser].id,
              'isRead': false,
              'userName': users[indexUser].name,
              'pictureUrl': (users[indexUser].imageUrl[0].runtimeType == String)?users[indexUser].imageUrl[0]:users[indexUser].imageUrl[0]['url'],
              'timestamp': FieldValue.serverTimestamp()
            },
            SetOptions(merge : true)
        );
        await docRef
            .doc(users[indexUser].id)
            .collection("Matches")
            .doc(Get.find<LoginController>().userId)
            .set(
            {
              'Matches': Get.find<LoginController>().userId,
              'userName': currentUser.name,
              'pictureUrl': (currentUser.imageUrl[0].runtimeType == String)?currentUser.imageUrl[0] : currentUser.imageUrl[0]['url'],
              'isRead': false,
              'timestamp': FieldValue.serverTimestamp()
            },
            SetOptions(merge : true)
        );
      }

      if(!cek){
        Get.find<NotificationController>().sendLikedFCM(
            idUser:users[indexUser].id,
            name: users[indexUser].name
        );
      }

      await docRef
          .doc(Get.find<LoginController>().userId)
          .collection("CheckedUser")
          .doc(users[indexUser].id)
          .set(
          {
            'userName': users[indexUser].name,
            'pictureUrl': (users[indexUser].imageUrl[0].runtimeType == String)?users[indexUser].imageUrl[0] : users[indexUser].imageUrl[0]['url'],
            'LikedUser': users[indexUser].id,
            'timestamp':
            FieldValue.serverTimestamp(),
          },
          SetOptions(merge : true)
      );
      await docRef
          .doc(users[indexUser].id)
          .collection("LikedBy")
          .doc(Get.find<LoginController>().userId)
          .set(
          {
            'userName': Get.find<TabsController>().currentUser.name,
            'pictureUrl': (currentUser.imageUrl[0].runtimeType == String)?currentUser.imageUrl[0] : currentUser.imageUrl[0]['url'],
            'LikedBy': Get.find<LoginController>().userId,
            'timestamp': FieldValue.serverTimestamp()
          },
          SetOptions(merge : true)
      );
      print("Data User index ke : " + indexUser.toString());
      users.removeAt(indexUser);
      indexImage = 0;
      if(indexUser != 0){
        indexUser--;
      }
      // if(data.indexUser+1 == data.users.length){
      //
      //   data.indexUser--;
      // }else{
      //   data.users.removeAt(data.indexUser);
      // }

      // data.userRemoved.clear();
      // data.userRemoved.add(data.users[data.indexUser]);
      print("selesai");
      // if (data.indexUser < (data.users.length + 1)) {
      //   print("clear");
      //   data.userRemoved.clear();
      //   data.userRemoved.add(data.users[data.indexUser]);
      //   data.users.removeAt(data.indexUser);

      //   if(data.users.length == 1){
      //     data.indexUser = 0;
      //   }
      // }

      }else{
      print("length 0");
      }
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