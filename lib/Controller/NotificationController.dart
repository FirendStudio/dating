import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hookup4u/Controller/ChatController.dart';
import 'package:hookup4u/Service/FCMService.dart';
import 'package:http/http.dart' as http;
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/TabsController.dart';
import 'package:hookup4u/models/user_model.dart';
import '../Screens/Info/InformationPartner.dart';
import '../models/Relationship.dart';
import '../util/color.dart';
import 'HomeController.dart';
import 'LoginController.dart';

class NotificationController extends GetxController {
  final db = FirebaseFirestore.instance;
  CollectionReference matchReference;
  CollectionReference docReference;
  Relationship relationUser;
  Relationship relationUserPartner;
  UserModel userPartner;
  List<Pending> listPendingReq = [];
  List<Pending> listPendingAcc = [];
  int indexNotif = 0;
  List listLikedUserAll = [];
  List listLikedUser = [];
  List listMatchUserAll = [];
  List listChatRole = [];
  String interestText = "";
  String desiresText = "";
  List listLikedTemp = [];
  List listTempMatch = [];
  List listLeave = [];

  @override
  onInit() async {
    super.onInit();
    if (GetPlatform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();

      var iosToken = await FirebaseMessaging.instance.getAPNSToken();
      print("Ios Token : " + iosToken);
    }
  }

  initNotification() {
    // print("Jalankan 1 ");
    if (docReference == null) {
      docReference = FirebaseFirestore.instance.collection("Users");
      // db.collection("Users")
      //   .doc(Get.find<LoginController>().userId)
      //   .collection('Matches')
      //   .orderBy('timestamp', descending: true)
      //   .snapshots()
      //   .listen((event) {
      //     listMatchUserAll = event.docs;
      //     listMatchTemp = event.docs;
      //     filterLiked();
      //     update();
      //   }
      // );
      FirebaseFirestore.instance
          .collection("Relationship")
          .doc(Get.find<LoginController>().userId)
          .snapshots()
          .listen((event) async {
        print("relationship");
        if (!event.exists) {
          await setNewRelationship(Get.find<LoginController>().userId);
          return;
        }
        print(event.data());
        if (event.data() == null) {
          return;
        }
        relationUser = Relationship.fromDocument(event.data());
        listPendingReq.assignAll(relationUser.pendingReq);
        listPendingAcc.assignAll(relationUser.pendingAcc);
        update();
      });

      // initListLikedUser();
    }
  }

  initRelationPartner({@required String Uid}) async {
    var data = await FirebaseFirestore.instance
        .collection("Relationship")
        .doc(Uid)
        .get();
    if (!data.exists) {
      await setNewRelationship(Uid);
      data = await FirebaseFirestore.instance
          .collection("Relationship")
          .doc(Uid)
          .get();
    }
    relationUserPartner = Relationship.fromDocument(data.data());
  }

  initUserPartner({@required String Uid}) async {
    var data =
        await FirebaseFirestore.instance.collection("Users").doc(Uid).get();
    // if(!data.exists){
    //   await setNewRelationship(Uid);
    //   data = await FirebaseFirestore.instance.collection("Relationship").doc(Uid).get();
    // }
    userPartner = UserModel.fromDocument(data);
    print("Cek");
    // print(jsonEncode(userPartner));
  }

  Future<bool> deletePartner({@required String Uid}) async {
    try {
      await setNewRelationship(Uid);
      await setNewRelationship(Get.find<LoginController>().userId);
      // Map <String, dynamic> deletePendingUser = {};
      // Map <String, dynamic> deletePendingUserPartner = {};
      // List listDeleteAcc = [];
      // List listDeleteReq = [];
      //
      // listDeleteReq = deleteListPending(
      //     listPendingTemp: listPendingReq, Uid: Uid);
      // deletePendingUser.addAll({
      //   "pendingReq" : listDeleteReq,
      // });
      //
      // if(relationUser.partner.partnerId == Uid){
      //   listDeleteAcc = deleteListPending(
      //       listPendingTemp: listPendingAcc, Uid: Uid);
      //   deletePendingUser.addAll({
      //     "inRelationship" : false,
      //     "pendingAcc" : listDeleteAcc,
      //     "partner" : {
      //       "partnerId" : "",
      //       "partnerImage" : "",
      //       "partnerName" : "",
      //     },
      //   });
      //
      // }
      //
      // var data = await FirebaseFirestore.instance.collection("Relationship").doc(Uid).get();
      // Relationship relationUserRequested = Relationship.fromDocument(data.data());
      //
      // listDeleteAcc = deleteListPending(listPendingTemp: relationUserRequested.pendingAcc,
      //     Uid: Get.find<LoginController>().userId);
      // deletePendingUserPartner.addAll({
      //   "pendingAcc" : listDeleteAcc,
      // });
      //
      // if(relationUser.partner.partnerId == Uid){
      //   listDeleteReq = deleteListPending(listPendingTemp: relationUserRequested.pendingReq,
      //       Uid: Get.find<LoginController>().userId);
      //   deletePendingUserPartner.addAll({
      //     "inRelationship" : false,
      //     "pendingReq" : listDeleteReq,
      //     "partner" : {
      //       "partnerId" : "",
      //       "partnerImage" : "",
      //       "partnerName" : "",
      //     },
      //   });
      //
      // }
      //
      // await FirebaseFirestore.instance.collection("Relationship")
      //     .doc(Get.find<LoginController>().userId)
      //     .set(deletePendingUser, SetOptions(merge : true));
      //
      // await FirebaseFirestore.instance.collection("Relationship")
      //     .doc(Uid)
      //     .set(deletePendingUserPartner, SetOptions(merge : true));

    } catch (e) {
      print(e);
      Get.snackbar("Info", e.toString());
      return false;
    }

    return true;
  }

  List deleteListPending(
      {@required List<Pending> listPendingTemp, @required String Uid}) {
    int indexDelete = 0;
    for (int index = 0; index <= listPendingTemp.length - 1; index++) {
      if (Uid == listPendingTemp[index].reqUid) {
        indexDelete = index;
      }
    }
    List<Pending> listTemp = [];
    listTemp.assignAll(listPendingTemp);
    listTemp.removeAt(indexDelete);
    List listPending = listTemp.map((list) => list.toJson()).toList();
    return listPending ?? [];
  }

  Future<bool> addNewPendingAcc(
      {@required String userName,
      @required String imageUrl,
      @required String UidPartner,
      @required String idUser}) async {
    List<Pending> listNewPendingAcc = [];
    bool cek = false;
    Relationship relationUserRequested;
    Map<String, dynamic> updateAcc = {};

    if (idUser != Get.find<LoginController>().userId) {
      var data = await FirebaseFirestore.instance
          .collection("Relationship")
          .doc(idUser)
          .get();
      relationUserRequested = Relationship.fromDocument(data.data());
      if (relationUserRequested.inRelationship ||
          relationUserRequested.pendingAcc.isNotEmpty ||
          relationUserRequested.pendingReq.isNotEmpty) {
        Get.snackbar("Info", "Partner already in relationship");
        return false;
      }
      listNewPendingAcc.assignAll(relationUserRequested.pendingAcc);
      if (listNewPendingAcc.isNotEmpty) {
        cek = false;
        for (int index = 0; index <= listNewPendingAcc.length - 1; index++) {
          if (Get.find<LoginController>().userId ==
              listNewPendingAcc[index].reqUid) {
            cek = true;
            break;
          }
        }
        if (!cek) {
          listNewPendingAcc.add(Pending(
              userName: userName,
              imageUrl: imageUrl,
              reqUid: UidPartner,
              createdAt: DateTime.now()));
        }
      } else {
        listNewPendingAcc.add(Pending(
            userName: userName,
            imageUrl: imageUrl,
            reqUid: UidPartner,
            createdAt: DateTime.now()));
      }

      cek = false;
      if (relationUserRequested.pendingReq.isNotEmpty) {
        for (int index = 0;
            index <= relationUserRequested.pendingReq.length - 1;
            index++) {
          if (Get.find<LoginController>().userId ==
              relationUserRequested.pendingReq[index].reqUid) {
            cek = true;
            break;
          }
        }
      }
    } else {
      cek = false;
      listNewPendingAcc.assignAll(listPendingAcc);
      if (listNewPendingAcc.isNotEmpty) {
        for (int index = 0; index <= listNewPendingAcc.length - 1; index++) {
          if (UidPartner == listNewPendingAcc[index].reqUid) {
            cek = true;
            break;
          }
        }
        if (!cek) {
          listNewPendingAcc.add(Pending(
              userName: userName,
              imageUrl: imageUrl,
              reqUid: UidPartner,
              createdAt: DateTime.now()));
        }
      } else {
        listNewPendingAcc.add(Pending(
            userName: userName,
            imageUrl: imageUrl,
            reqUid: UidPartner,
            createdAt: DateTime.now()));
      }

      cek = false;
      if (listPendingReq.isNotEmpty) {
        for (int index = 0; index <= listPendingReq.length - 1; index++) {
          if (UidPartner == listPendingReq[index].reqUid) {
            cek = true;
            break;
          }
        }
      }
    }

    List listUpdateAcc =
        listNewPendingAcc.map((player) => player.toJson()).toList();
    updateAcc.addAll({
      "pendingAcc": listUpdateAcc,
    });
    print(updateAcc);

    if (cek) {
      print(idUser);
      updateAcc.addAll({
        "inRelationship": true,
        "partner": {
          "partnerId": UidPartner,
          "partnerImage": imageUrl,
          "partnerName": userName,
        },
        // "updateAt" : FieldValue.serverTimestamp()
      });

      await FirebaseFirestore.instance
          .collection("Relationship")
          .doc(idUser)
          .set(updateAcc, SetOptions(merge: true));
      return true;
    }

    await FirebaseFirestore.instance
        .collection("Relationship")
        .doc(idUser)
        .set(updateAcc, SetOptions(merge: true));
    return true;
  }

  Future<bool> addNewPendingReq(
      {@required BuildContext context2,
      @required String userName,
      @required String imageUrl,
      @required String Uid,
      @required String idUser}) async {
    bool cek = false;
    List<Pending> listNewPendingReq = [];
    Map<String, dynamic> updateReq = {};

    if (idUser != Get.find<LoginController>().userId) {
      DocumentSnapshot data = await FirebaseFirestore.instance
          .collection("Relationship")
          .doc(idUser)
          .get();

      if (!data.exists) {
        await setNewRelationship(idUser);
        data = await FirebaseFirestore.instance
            .collection("Relationship")
            .doc(idUser)
            .get();
      }
      Relationship relationUserRequested =
          Relationship.fromDocument(data.data());

      cek = false;
      listNewPendingReq.assignAll(relationUserRequested.pendingReq);
      if (relationUserRequested.pendingReq.isNotEmpty) {
        cek = false;
        for (int index = 0;
            index <= relationUserRequested.pendingReq.length - 1;
            index++) {
          if (Get.find<LoginController>().userId ==
              relationUserRequested.pendingReq[index].reqUid) {
            cek = true;
            break;
          }
        }
        if (cek) {
          listNewPendingReq.add(Pending(
              userName: userName,
              imageUrl: imageUrl,
              reqUid: Uid,
              createdAt: DateTime.now()));
        }
      } else {
        listNewPendingReq.add(Pending(
            userName: userName,
            imageUrl: imageUrl,
            reqUid: Uid,
            createdAt: DateTime.now()));
      }

      cek = false;
      if (relationUserRequested.pendingAcc.isNotEmpty) {
        for (int index = 0;
            index <= relationUserRequested.pendingAcc.length - 1;
            index++) {
          if (Get.find<LoginController>().userId ==
              relationUserRequested.pendingAcc[index].reqUid) {
            cek = true;
            break;
          }
        }
      }
    } else {
      cek = false;
      listNewPendingReq.assignAll(listPendingReq);
      if (listNewPendingReq.isNotEmpty) {
        for (int index = 0; index <= listNewPendingReq.length - 1; index++) {
          if (Uid == listNewPendingReq[index].reqUid) {
            cek = true;
            break;
          }
        }
        if (!cek) {
          listNewPendingReq.add(Pending(
              userName: userName,
              imageUrl: imageUrl,
              reqUid: Uid,
              createdAt: DateTime.now()));
        }
      } else {
        listNewPendingReq.add(Pending(
            userName: userName,
            imageUrl: imageUrl,
            reqUid: Uid,
            createdAt: DateTime.now()));
      }

      cek = false;
      if (listPendingAcc.isNotEmpty) {
        for (int index = 0; index <= listPendingAcc.length - 1; index++) {
          if (Uid == listPendingAcc[index].reqUid) {
            cek = true;
            break;
          }
        }
      }
    }

    List listUpdateReq =
        listNewPendingReq.map((value) => value.toJson()).toList();
    updateReq.addAll({"pendingReq": listUpdateReq});
    print(updateReq);
    print("Masuk sini");

    if (cek) {
      showDialog(
          context: context2,
          builder: (ctx) {
            Future.delayed(Duration(milliseconds: 1700), () {
              Navigator.pop(ctx);
            });
            return Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Align(
                alignment: Alignment.topCenter,
                child: Card(
                  child: Container(
                    height: 100,
                    width: 300,
                    child: Center(
                        child: Text(
                      "You are now in relationship with $userName",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 30,
                          decoration: TextDecoration.none),
                    )
                        // .tr(args: ['${widget.users[index].name}']),
                        ),
                  ),
                ),
              ),
            );
          });
      print(idUser);

      updateReq.addAll({
        "inRelationship": true,
        "partner": {
          "partnerId": Uid,
          "partnerImage": imageUrl,
          "partnerName": userName,
        },
        // "updateAt" : FieldValue.serverTimestamp()
      });

      await FirebaseFirestore.instance
          .collection("Relationship")
          .doc(idUser)
          .set(updateReq, SetOptions(merge: true));
      return false;
    }
    await FirebaseFirestore.instance
        .collection("Relationship")
        .doc(idUser)
        .set(updateReq, SetOptions(merge: true));
    return true;
  }

  setNewRelationship(String uid) async {
    Map<String, dynamic> newRelation = {
      "userId": uid,
      "partner": {
        "partnerId": "",
        "partnerImage": "",
        "partnerName": "",
      },
      "inRelationship": false,
      "pendingReq": [],
      "pendingAcc": [],
      "updateAt": FieldValue.serverTimestamp()
    };

    await FirebaseFirestore.instance
        .collection("Relationship")
        .doc(uid)
        .set(newRelation, SetOptions(merge: true));
  }

  acceptPartner(
      {@required BuildContext context2,
      @required String Uid,
      @required String imageUrl,
      @required String userName}) async {
    ArtDialogResponse response;

    bool cek = false;
    if (relationUser.inRelationship && relationUser.partner.partnerId == Uid) {
      ArtSweetAlert.show(
          context: context2,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.info,
              title: "You already in releationship with $userName"));

      return;
    }

    if (relationUser.inRelationship && relationUser.partner.partnerId != Uid) {
      response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context2,
        artDialogArgs: ArtDialogArgs(
          // showCancelBtn: true,
          denyButtonText: "No",
          title:
              "You are already in relationship, do you want change to another partner?",
          confirmButtonText: "Yes",
        ),
      );

      if (response.isTapDenyButton) {
        return;
      }
    }

    cek = await addNewPendingAcc(
        userName: userName,
        imageUrl: imageUrl,
        UidPartner: Uid,
        idUser: Get.find<LoginController>().userId);

    // print(cek);
    cek = await addNewPendingReq(
        context2: context2,
        userName: Get.find<TabsController>().currentUser.name,
        imageUrl: Get.find<TabsController>().currentUser.imageUrl[0]['url'],
        Uid: Get.find<TabsController>().currentUser.id,
        idUser: Uid);
  }

  addNewPartner(
      {@required BuildContext context2,
      @required String userName,
      @required String imageUrl,
      @required String Uid}) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
      barrierDismissible: false,
      context: context2,
      artDialogArgs: ArtDialogArgs(
          showCancelBtn: false,
          denyButtonText: "Cancel",
          title: "Would you like to add " + userName + " as your partner?",
          confirmButtonText: "Add",
          customColumns: [
            Container(
              margin: EdgeInsets.only(bottom: 12.0),
              child: Image.network(
                imageUrl,
                errorBuilder: (context, url, error) => Icon(Icons.error),
              ),
            )
          ]),
    );

    if (response == null) {
      return;
    }

    if (response.isTapDenyButton) {
      return;
    }

    if (response.isTapConfirmButton) {
      if (relationUser.inRelationship ||
          relationUser.pendingReq.isNotEmpty ||
          relationUser.pendingAcc.isNotEmpty) {
        response = await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context2,
          artDialogArgs: ArtDialogArgs(
            // showCancelBtn: true,
            denyButtonText: "No",
            title:
                "You are already in relationship, do you want change to another partner?",
            confirmButtonText: "Yes",
          ),
        );

        if (response.isTapDenyButton) {
          return;
        }

        if (response.isTapConfirmButton) {
          await deletePartner(Uid: Uid);
        }
      }

      bool cek = false;

      print(listPendingAcc);
      if (listPendingAcc.isNotEmpty) {
        cek = false;
        for (int index = 0; index <= listPendingAcc.length - 1; index++) {
          if (Uid == listPendingAcc[index].reqUid) {
            cek = true;
            break;
          }
        }
        if (cek) {
          FocusScope.of(context2).requestFocus(FocusNode());
          Get.snackbar("Information", "User already exist");
          return;
        }
      }

      var data = await FirebaseFirestore.instance
          .collection("Relationship")
          .doc(Uid)
          .get();
      if (!data.exists) {
        await setNewRelationship(Uid);
        data = await FirebaseFirestore.instance
            .collection("Relationship")
            .doc(Uid)
            .get();
      }
      Relationship relationUserPartnerReq =
          Relationship.fromDocument(data.data());
      if (relationUserPartnerReq.pendingReq.isNotEmpty ||
          relationUserPartnerReq.pendingAcc.isNotEmpty) {
        Get.snackbar("Information", "User partner already requested partner");
        return;
      }

      cek = await addNewPendingAcc(
          userName: userName,
          imageUrl: imageUrl,
          UidPartner: Uid,
          idUser: Get.find<LoginController>().userId);

      if (!cek) {
        return;
      }
      // print(cek);
      cek = await addNewPendingReq(
          context2: context2,
          userName: Get.find<TabsController>().currentUser.name,
          imageUrl: Get.find<TabsController>().currentUser.imageUrl[0]['url'],
          Uid: Get.find<TabsController>().currentUser.id,
          idUser: Uid);

      if (cek) {
        ArtSweetAlert.show(
            context: context2,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success, title: "Success"));
      }
      update();
      await Future.delayed(Duration(seconds: 2));
      Get.back();
      Get.back();
    }
  }

  removeUserSwipe(int indexNotif) {
    bool cek = false;
    int cekIndex = 0;
    for (int index = 0;
        index <= Get.find<TabsController>().users.length - 1;
        index++) {
      if (Get.find<TabsController>().users[index].id ==
          listLikedUser[indexNotif]['LikedBy']) {
        cekIndex = index;
        cek = true;
        break;
      }
    }
    listLikedUser.removeAt(indexNotif);
    update();
    if (!cek) {
      return;
    }
    Get.find<TabsController>().userRemoved.clear();
    Get.find<TabsController>()
        .userRemoved
        .add(Get.find<TabsController>().users[cekIndex]);
    Get.find<TabsController>().users.removeAt(cekIndex);
    Get.find<TabsController>().update();
  }

  cekFirstInfo(UserModel user) {
    desiresText = "";
    interestText = "";
    print(user);
    if (user != null) {
      if (user.desires.isNotEmpty) {
        for (int index = 0; index <= user.desires.length - 1; index++) {
          if (desiresText.isEmpty) {
            desiresText =
                Get.find<TabsController>().capitalize(user.desires[index]);
            print(desiresText);
          } else {
            desiresText += ", " +
                Get.find<TabsController>().capitalize(user.desires[index]);
          }
        }
      }

      if (user.interest.isNotEmpty) {
        for (int index = 0; index <= user.interest.length - 1; index++) {
          if (interestText.isEmpty) {
            interestText =
                Get.find<TabsController>().capitalize(user.interest[index]);
          } else {
            interestText += ", " +
                Get.find<TabsController>().capitalize(user.interest[index]);
          }
        }
      }
    }
  }

  sendMatchedFCM({String idUser, String name}) async {
    Get.find<HomeController>().showSimpleNotification(
        title: "Matched", body: "You are matched with $name");
    // UserModel userFCM = Get.find<TabsController>().getUserSelected(idUser);
    String toParams = "/topics/" + idUser;
    var data = {"title": "Matched", "body": "You are matched with ${Get.find<TabsController>().currentUser.name}"};
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

  sendLikedFCM({String idUser, String name}) async {
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

  sendChatFCM({String idUser, String name}) async {
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

  sendLeaveFCM({String idUser, String name}) async {
    // UserModel userFCM = Get.find<TabsController>().getUserSelected(idUser);
    if (kDebugMode) {
      print("Send Leave FCM");
    }
    String toParams = "/topics/" + idUser;
    var data = {"title": "Leaving Chat", "body": "$name has left the conversation"};
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

  sendRestoreLeaveFCM({String idUser, String name}) async {
    // UserModel userFCM = Get.find<TabsController>().getUserSelected(idUser);
    if (kDebugMode) {
      print("Send Restore Leave FCM");
    }
    String toParams = "/topics/" + idUser;
    var data = {"title": "Resume Chat", "body": "$name has resumed the conversation"};
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

  sendDisconnectFCM({String idUser, String name}) async {
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

  initPayload(String payload) async {
    var split = payload.split("/");
    if (split[0] == "liked") {
      String idUser = split[1];
      await initUserPartner(Uid: idUser);
      var relation = await FirebaseFirestore.instance
          .collection("Relationship")
          .doc(idUser)
          .get();
      if (!relation.exists) {
        await setNewRelationship(idUser);
        relation = await FirebaseFirestore.instance
            .collection("Relationship")
            .doc(idUser)
            .get();
      }
      Relationship relationshipTemp =
          Relationship.fromDocument(relation.data());

      var result = await FirebaseFirestore.instance
          .collection('Users')
          .doc(idUser)
          .get();
      print(result);
      UserModel userSelected = UserModel.fromDocument(result);
      // Get.back();
      userSelected.distanceBW = Get.find<TabsController>()
          .calculateDistance(
              Get.find<TabsController>().currentUser.coordinates['latitude'],
              Get.find<TabsController>().currentUser.coordinates['longitude'],
              userPartner.coordinates['latitude'],
              userPartner.coordinates['longitude'])
          .round();
      // data.listLikedUserAll[index]["LikedBy"];
      await showDialog(
          barrierDismissible: false,
          context: Get.context,
          builder: (context) {
            return InformationPartner(
              userSelected,
              Get.find<TabsController>().currentUser,
              null,
              relationshipTemp,
              Get.find<NotificationController>().userPartner,
            );
          });
    }
  }

  filterMatches() async {
    
    // listMatchTemp.assignAll(listMatchUserAll);
    listTempMatch = [];
    listMatchUserAll.forEach((element) {
      var mapTemp = {
        "Matches"     : element['Matches'],
        "isRead"      : element['isRead'],
        "pictureUrl"  : element['pictureUrl'],
        "timestamp"   : element['timestamp'],
        "userName"    : element['userName'],
        "isLeave"     : false,
      };
      listTempMatch.add(mapTemp);
    });
    Get.find<TabsController>().newmatches.assignAll(Get.find<TabsController>().Allmatches);
    Get.find<TabsController>().matches.assignAll(Get.find<TabsController>().Allmatches);
    if(Get.find<ChatController>().listChatSnapshot.isEmpty || listMatchUserAll.isEmpty){
      if(listTempMatch.isNotEmpty){
        print("Masuk sini");
        for(var list in listTempMatch){
          list['isLeave'] = await getNotifLeave(Get.find<ChatController>().
          chatIdCustom(Get.find<TabsController>().currentUser.id, list['Matches']));
          print(list['isLeave']);
          // var map = {
          //   "id" : list.id,
          //   "isLeave" : cek
          // };
          // listLeave.add(map);
        }
      }
      return;
    }
    for(var list in Get.find<ChatController>().listChatSnapshot){
      listTempMatch.removeWhere((element) => 
        Get.find<ChatController>().chatIdCustom(Get.find<TabsController>().currentUser.id, element.id) == list['docId']
      );
      Get.find<TabsController>().newmatches.removeWhere((element) {
          // print("Masuk sini : ${element.id}");
          return Get.find<ChatController>().chatIdCustom(Get.find<TabsController>().currentUser.id, element.id) == list['docId'];
      });
      Get.find<TabsController>().matches.removeWhere((element) {
          print("Masuk sini : ${element.id}");
          return Get.find<ChatController>().chatIdCustom(Get.find<TabsController>().currentUser.id, element.id) == list['docId'];
      });
    }
    if(listTempMatch.isNotEmpty){
      for(var list in listTempMatch){
          list['isLeave'] = await getNotifLeave(Get.find<ChatController>().
          chatIdCustom(Get.find<TabsController>().currentUser.id, list['Matches']));
          print(list['isLeave']);
          // var map = {
          //   "id" : list.id,
          //   "isLeave" : cek
          // };
          // listLeave.add(map);
        }
    }
  }

  bool filterLeave(String idMatch){
    if(listLeave.isNotEmpty){
      var data = listLeave.firstWhereOrNull((element) => element['id'] == idMatch);
      print(data);
      if(data != null){
        return data['isLeave'];
      }
    }
    return false;
  }

  filterLiked(){
    listLikedTemp.assignAll(listLikedUserAll);
    if(listMatchUserAll.isNotEmpty && listLikedUserAll.isNotEmpty){
      for(int i=0; i<=listMatchUserAll.length-1; i++){
        // print("Masuk sini 1");
        if(listLikedUserAll.isEmpty){
          return;
        }
        for(int j=0; j<=listLikedUserAll.length-1; j++){
          // print("Masuk sini 2");
          if(listLikedUserAll[j]['LikedBy'] == listMatchUserAll[i]['Matches']){
            // print("Masuk sini 3");
            if(listLikedTemp.isNotEmpty){
              listLikedTemp.removeWhere((element) => element['LikedBy'] == listLikedUserAll[j]['LikedBy']);
            }
            
          }
        }

      }
      
    }
  }

  Future <bool> getNotifLeave(String idChat) async {
    var result = await FirebaseFirestore.instance.collection("chats").
    doc(idChat).collection("messages").limit(1).orderBy('time', descending: true).get();
    if(result.docs.isNotEmpty && result.docs.first['type'] == "Leave"){
      return true;
    }

    return false;
  }

}
