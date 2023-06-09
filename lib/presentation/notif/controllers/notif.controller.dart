import 'dart:async';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/MatchModel.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';

import '../../../domain/core/model/Relationship.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/general.dart';

class NotifController extends GetxController {
  RxInt indexNotif = 0.obs;
  List listLikedUserAll = [];
  RxList listLikedUser = RxList();
  List<QueryDocumentSnapshot<Map<String, dynamic>>> listMatchUserAll = [];
  RxList<MatchModel> listMatchUser = RxList();
  RxList<MatchModel> listMatchNewUser = RxList();
  StreamSubscription<QuerySnapshot>? streamLikedBy;
  StreamSubscription<QuerySnapshot>? streamMatches;
  RxList<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?> listStreamRoom = RxList();
  RxBool isLoading = false.obs;

  initAll() {
    debugPrint("call--notification-initAll()");
    getLikedByList();
    getMatches();
  }

  @override
  void onInit() {
    debugPrint("call--notification-onInit()");
    super.onInit();
    initAll();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    streamLikedBy?.cancel();
    streamMatches?.cancel();
    // disposeStreamRoom();
  }

  // disposeStreamRoom() {
  //   if (listStreamRoom.isNotEmpty) {
  //     listStreamRoom.forEach((element) {
  //       element?.cancel();
  //     });
  //   }
  // }

  getLikedByList() {
    streamLikedBy = queryCollectionDB('Users')
        .doc(Get.find<GlobalController>().currentUser.value?.id)
        .collection("LikedBy")
        .orderBy('LikedBy', descending: true)
        .snapshots()
        .listen((data) async {
      listLikedUserAll.assignAll(data.docs);
      print("call-------  getLikedByList : " + listLikedUserAll.length.toString());
      filterLiked();
    });
  }

  getMatches() async {
    streamMatches = queryCollectionDB('/Users/${Get.find<GlobalController>().currentUser.value?.id}/Matches')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((ondata) async {
      print(ondata.docs.length);
      if (ondata.docs.isNotEmpty) {
        listMatchUserAll.assignAll(ondata.docs);
        print("call------- getMatches : " + listLikedUserAll.length.toString());
        filterMatches();
        filterLiked();
      }
    });
  }

  getDeleteMatches(MatchModel matchesModel) async {
    isLoading.value = true;
    await queryCollectionDB('/Users/${Get.find<GlobalController>().currentUser.value?.id}/Matches')
        .doc(matchesModel.matches)
        .delete()
        .then((value) => {debugPrint("success in getDeleteMatches======>")})
        .onError((error, stackTrace) {
      debugPrint("error in getDeleteMatches======>$error");
      Global().showInfoDialog("Error Check Your Internet Connection");
      isLoading.value = false;
      return {};
    });
    await queryCollectionDB('/Users/${matchesModel.matches}/Matches')
        .doc(Get.find<GlobalController>().currentUser.value?.id)
        .set({
          "Matches": "${Get.find<GlobalController>().currentUser.value?.id}",
          "isRead": true,
          "pictureUrl": Get.find<GlobalController>().currentUser.value?.imageUrl.first["url"] ?? "",
          "timestamp": FieldValue.serverTimestamp(),
          "userName": Get.find<GlobalController>().currentUser.value?.name,
          "isDeleted": true
        })
        .then((value) => {debugPrint("success in getDeleteMatches===partner===>")})
        .onError((error, stackTrace) {
          debugPrint("error in getDeleteMatches===partner===>$error");
          Global().showInfoDialog("Error Check Your Internet Connection");
          isLoading.value = false;
          return {};
        });
    await queryCollectionDB('Users')
        .doc(Get.find<GlobalController>().currentUser.value?.id)
        .collection("LikedBy")
        .doc(matchesModel.matches)
        .delete()
        .then((value) => {debugPrint("success in getDeleteMatches===LikedBY===>")})
        .onError((error, stackTrace) {
      debugPrint("error in getDeleteMatches===LikedBY===>$error");
      Global().showInfoDialog("Error Check Your Internet Connection");
      return {};
    });
    String chatId = Global().chatId(Get.find<GlobalController>().currentUser.value!.id, matchesModel.matches!);
    /*await queryCollectionDB("chats").doc(chatId).delete().then((value) {
      debugPrint("success in getDeleteMatches===chats===>");
    }).onError((error, stackTrace) {
      debugPrint("success in getDeleteMatches===chats===>$error");
    });*/
    await queryCollectionDB("chats").doc(chatId).collection('messages').add({
      'type': 'Disconnect',
      'text': "${Get.find<GlobalController>().currentUser.value!.name} has blocked you",
      'sender_id': Get.find<GlobalController>().currentUser.value!.id,
      'receiver_id': matchesModel.matches,
      'isRead': false,
      'image_url': "",
      'time': FieldValue.serverTimestamp(),
    });
    queryCollectionDB("chats")
        .doc(chatId)
        .set({"active": false, "docId": chatId}, SetOptions(merge: true))
        .then((value) {})
        .onError((error, stackTrace) {
          debugPrint("error-delete--set active false in  messages-->$error");
          isLoading.value = false;
          Get.back();
        });
    debugPrint("matches list length=before===${listMatchUser.length}");
    listMatchUserAll.remove(matchesModel);
    listMatchUser.remove(matchesModel);
    listMatchUser.refresh();
    debugPrint("matches list length====${listMatchUser.length}");
    globalController.sendMatchedDeletedFCM(idUser: matchesModel.matches!, name: matchesModel.userName!);
    isLoading.value = false;
  }

  deletedMatchesDeleted(MatchModel matchesModel) async {
    isLoading.value = true;
    await queryCollectionDB('/Users/${Get.find<GlobalController>().currentUser.value?.id}/Matches')
        .doc(matchesModel.matches)
        .delete()
        .then((value) => {debugPrint("success in deletedMatchesDeleted======>")})
        .onError((error, stackTrace) {
      debugPrint("error in deletedMatchesDeleted======>$error");
      Global().showInfoDialog("Error Check Your Internet Connection");
      isLoading.value = false;
      return {

      };
    });
    await queryCollectionDB('Users')
        .doc(Get.find<GlobalController>().currentUser.value?.id)
        .collection("LikedBy")
        .doc(matchesModel.matches)
        .delete()
        .then((value) => {debugPrint("success in deletedMatchesDeleted===LikedBY===>")})
        .onError((error, stackTrace) {
      Global().showInfoDialog("Error Check Your Internet Connection");
      isLoading.value = false;
      debugPrint("error in deletedMatchesDeleted===LikedBY===>$error");
      return {};
    });

    listMatchUserAll.remove(matchesModel);
    listMatchUser.remove(matchesModel);
    listMatchUser.refresh();

    isLoading.value = false;
  }

  filterLiked() {
    listLikedUser.assignAll(listLikedUserAll);
    if (listMatchUserAll.isNotEmpty && listLikedUserAll.isNotEmpty) {
      for (int i = 0; i <= listMatchUserAll.length - 1; i++) {
        if (listLikedUserAll.isEmpty) {
          return;
        }
        for (int j = 0; j <= listLikedUserAll.length - 1; j++) {
          if (listLikedUserAll[j]['LikedBy'] == listMatchUserAll[i]['Matches']) {
            if (listLikedUser.isNotEmpty) {
              listLikedUser.removeWhere((element) => element['LikedBy'] == listLikedUserAll[j]['LikedBy']);
            }
          }
        }
      }
    }
    listLikedUser.refresh();
  }

  filterMatches() async {
    listMatchNewUser.clear();
    listMatchUser.value = [];
    listMatchUserAll.forEach((element) {
      Timestamp timeStamp = element['timestamp'] ?? Timestamp.now();
      var mapTemp = MatchModel(
        matches: element['Matches'],
        isRead: element['isRead'],
        pictureUrl: element['pictureUrl'],
        timeStamp: (timeStamp.toDate()),
        userName: element['userName'],
        type: 0.obs,
        isDeleted: element.data().keys.toList().contains("isDeleted")? element['isDeleted']: false,
      );
      if (!element['isRead']) {
        listMatchNewUser.add(mapTemp);
      }
      listMatchUser.add(mapTemp);
    });
    if (listMatchUser.isNotEmpty) {
      for (var list in listMatchUser) {
        list.type.value = await getNotifLeave(
          Global().chatId(
            globalController.currentUser.value!.id,
            list.matches ?? "",
          ),
        );
        if (kDebugMode) {
          print(list.type.value);
        }
      }
    }
    listMatchUser.refresh();
  }

  Future<int> getNotifLeave(String idChat) async {
    var result = await queryCollectionDB("chats")
        .doc(idChat)
        .collection("messages")
        .limit(1)
        .orderBy('time', descending: true)
        .get();

    if (result.docs.isNotEmpty && result.docs.first['type'] == "Leave") {
      return 1;
    }
    if (result.docs.isNotEmpty && result.docs.first['type'] == "Disconnect") {
      return 2;
    }

    return 0;
  }

  int filterType(String idMatch) {
    if (listMatchUser.isNotEmpty) {
      var data = listMatchUser.firstWhereOrNull((element) => element.matches == idMatch);
      if (kDebugMode) {
        print(data);
      }
      if (data != null) {
        return data.type.value;
      }
    }
    return 0;
  }

  acceptPartner(
      {required BuildContext context2, required String Uid, required String imageUrl, required String userName}) async {
    ArtDialogResponse? response;
    if (globalController.currentUser.value?.relasi.value?.inRelationship == true &&
        globalController.currentUser.value?.relasi.value?.partner?.partnerId == Uid) {
      ArtSweetAlert.show(
        context: context2,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.info,
          title: "You already in relationship with $userName",
        ),
      );

      return;
    }

    if (globalController.currentUser.value?.relasi.value?.inRelationship == true &&
        globalController.currentUser.value?.relasi.value?.partner?.partnerId != Uid) {
      response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context2,
        artDialogArgs: ArtDialogArgs(
          // showCancelBtn: true,
          denyButtonText: "No",
          title: "You are already in relationship, do you want change to another partner?",
          confirmButtonText: "Yes",
        ),
      );

      if (response == null) {
        return;
      }

      if (response.isTapDenyButton) {
        return;
      }
    }

    bool cek = await addNewPendingAcc(
      userName: userName,
      imageUrl: imageUrl,
      UidPartner: Uid,
      idUser: globalController.currentUser.value?.id ?? "",
    );

    print(cek);
    cek = await addNewPendingReq(
      context2: context2,
      userName: globalController.currentUser.value?.name ?? "",
      imageUrl: globalController.currentUser.value?.imageUrl[0]['url'],
      Uid: globalController.currentUser.value?.id ?? "",
      idUser: Uid,
    );
  }

  addNewPartner(
      {required BuildContext context2, required String userName, required String imageUrl, required String Uid}) async {
    ArtDialogResponse? response = await ArtSweetAlert.show(
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
          ),
        ],
      ),
    );

    if (response == null) {
      return;
    }

    if (response.isTapDenyButton) {
      return;
    }

    if (response.isTapConfirmButton) {
      if (globalController.currentUser.value?.relasi.value?.inRelationship == true ||
          (globalController.currentUser.value?.relasi.value?.pendingReq ?? []).isNotEmpty ||
          (globalController.currentUser.value?.relasi.value?.pendingAcc ?? []).isNotEmpty) {
        response = await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context2,
          artDialogArgs: ArtDialogArgs(
            // showCancelBtn: true,
            denyButtonText: "No",
            title: "You are already in relationship, do you want change to another partner?",
            confirmButtonText: "Yes",
          ),
        );
        if (response == null) {
          return;
        }
        if (response.isTapDenyButton) {
          return;
        }

        if (response.isTapConfirmButton) {
          await Global().deletePartner(Uid: Uid);
        }
      }

      bool cek = false;

      print(globalController.currentUser.value?.relasi.value?.pendingAcc);
      if ((globalController.currentUser.value?.relasi.value?.pendingAcc ?? []).isNotEmpty) {
        cek = false;
        for (int index = 0;
            index <= (globalController.currentUser.value?.relasi.value?.pendingAcc ?? []).length - 1;
            index++) {
          if (Uid == globalController.currentUser.value?.relasi.value?.pendingAcc[index].reqUid) {
            cek = true;
            break;
          }
        }
        if (cek) {
          FocusScope.of(context2).requestFocus(FocusNode());
          Global().showInfoDialog("User already exist");
          return;
        }
      }

      var data = await queryCollectionDB("Relationship").doc(Uid).get();
      if (!data.exists) {
        await Global().setNewRelationship(Uid);
        data = await queryCollectionDB("Relationship").doc(Uid).get();
      }
      Relationship relationUserPartnerReq = Relationship.fromDocument(data.data()!);
      if (relationUserPartnerReq.pendingReq.isNotEmpty || relationUserPartnerReq.pendingAcc.isNotEmpty) {
        Get.snackbar("Information", "User partner already requested partner");
        return;
      }

      cek = await addNewPendingAcc(
        userName: userName,
        imageUrl: imageUrl,
        UidPartner: Uid,
        idUser: globalController.currentUser.value?.id ?? "",
      );

      if (!cek) {
        return;
      }
      // print(cek);
      cek = await addNewPendingReq(
        context2: context2,
        userName: globalController.currentUser.value?.name ?? "",
        imageUrl: globalController.currentUser.value?.imageUrl[0]['url'],
        Uid: globalController.currentUser.value?.id ?? "",
        idUser: Uid,
      );

      if (cek) {
        ArtSweetAlert.show(
            context: context2, artDialogArgs: ArtDialogArgs(type: ArtSweetAlertType.success, title: "Success"));
      }
      update();

      await Future.delayed(Duration(seconds: 2));
      Get.back();
      Get.back();
    }
  }

  // removeUserSwipe(int indexNotif) {
  //   bool cek = false;
  //   int cekIndex = 0;
  //   if(Get.find<HomeController>().listUsers.isNotEmpty){
  //     return;
  //   }
  //   for (int index = 0;
  //       index <= Get.find<HomeController>().listUsers.length - 1;
  //       index++) {
  //     if (Get.find<HomeController>().listUsers[index].id ==
  //         listLikedUser[indexNotif]['LikedBy']) {
  //       cekIndex = index;
  //       cek = true;
  //       break;
  //     }
  //   }
  //   listLikedUser.removeAt(indexNotif);
  //   update();
  //   if (!cek) {
  //     return;
  //   }
  //   Get.find<TabsController>().userRemoved.clear();
  //   Get.find<TabsController>()
  //       .userRemoved
  //       .add(Get.find<TabsController>().users[cekIndex]);
  //   Get.find<TabsController>().users.removeAt(cekIndex);
  //   Get.find<TabsController>().update();
  // }

  Future<bool> addNewPendingAcc(
      {required String userName, required String imageUrl, required String UidPartner, required String idUser}) async {
    List<Pending> listNewPendingAcc = [];
    bool cek = false;
    Relationship relationUserRequested;
    Map<String, dynamic> updateAcc = {};
    Map<String, dynamic> updatePartnerAcc = {};

    if (idUser != globalController.currentUser.value?.id) {
      var data = await queryCollectionDB("Relationship").doc(idUser).get();
      relationUserRequested = Relationship.fromDocument(data.data()!);
      if (relationUserRequested.inRelationship == true ||
          relationUserRequested.pendingAcc.isNotEmpty ||
          relationUserRequested.pendingReq.isNotEmpty) {
        Get.snackbar("Info", "Partner already in relationship");
        return false;
      }
      listNewPendingAcc.assignAll(relationUserRequested.pendingAcc);
      if (listNewPendingAcc.isNotEmpty) {
        cek = false;
        for (int index = 0; index <= listNewPendingAcc.length - 1; index++) {
          if (globalController.currentUser.value?.id == listNewPendingAcc[index].reqUid) {
            cek = true;
            break;
          }
        }
        if (!cek) {
          listNewPendingAcc
              .add(Pending(userName: userName, imageUrl: imageUrl, reqUid: UidPartner, createdAt: DateTime.now()));
        }
      } else {
        listNewPendingAcc
            .add(Pending(userName: userName, imageUrl: imageUrl, reqUid: UidPartner, createdAt: DateTime.now()));
      }

      cek = false;
      if (relationUserRequested.pendingReq.isNotEmpty) {
        for (int index = 0; index <= relationUserRequested.pendingReq.length - 1; index++) {
          if (globalController.currentUser.value?.id == relationUserRequested.pendingReq[index].reqUid) {
            cek = true;
            break;
          }
        }
      }
    } else {
      cek = false;
      listNewPendingAcc.assignAll(globalController.currentUser.value?.relasi.value?.pendingAcc ?? []);
      if (listNewPendingAcc.isNotEmpty) {
        for (int index = 0; index <= listNewPendingAcc.length - 1; index++) {
          if (UidPartner == listNewPendingAcc[index].reqUid) {
            cek = true;
            break;
          }
        }
        if (!cek) {
          listNewPendingAcc.add(
            Pending(
              userName: userName,
              imageUrl: imageUrl,
              reqUid: UidPartner,
              createdAt: DateTime.now(),
            ),
          );
        }
      } else {
        listNewPendingAcc.add(
          Pending(
            userName: userName,
            imageUrl: imageUrl,
            reqUid: UidPartner,
            createdAt: DateTime.now(),
          ),
        );
      }

      cek = false;
      if ((globalController.currentUser.value?.relasi.value?.pendingReq ?? []).isNotEmpty) {
        for (int index = 0;
            index <= (globalController.currentUser.value?.relasi.value?.pendingReq ?? []).length - 1;
            index++) {
          if (UidPartner == globalController.currentUser.value?.relasi.value?.pendingReq[index].reqUid) {
            cek = true;
            break;
          }
        }
      }
    }

    List listUpdateAcc = listNewPendingAcc.map((player) => player.toJson()).toList();
    updateAcc.addAll({
      "pendingAcc": listUpdateAcc,
    });
    print(updateAcc);
    debugPrint("partner id cek---$cek->");
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
      bool resultPartner = false;
      await queryCollectionDB("Relationship")
          .doc(idUser)
          .set(updateAcc, SetOptions(merge: true))
          .then((value) => {debugPrint("--add partner successfully 481--->"), resultPartner = true})
          .onError(
        (error, stackTrace) {
          debugPrint("error--add partner 484--$error>");
          resultPartner = false;
          return {};
        },
      );

      updatePartnerAcc.addAll({
        "inRelationship": true,
        "partner": {
          "partnerId": globalController.currentUser.value?.id ?? "",
          "partnerImage": globalController.currentUser.value?.imageUrl[0]['url'] ?? "",
          "partnerName": globalController.currentUser.value?.name ?? "",
        },
        // "updateAt" : FieldValue.serverTimestamp()
      });
      debugPrint("opposite user data --$updatePartnerAcc>");
      await queryCollectionDB("Relationship")
          .doc(UidPartner)
          .set(updatePartnerAcc, SetOptions(merge: true))
          .then((value) => {debugPrint("opposite--add partner successfully --->"), resultPartner = true})
          .onError(
        (error, stackTrace) {
          debugPrint("error-opposite-add partner --$error>");
          resultPartner = false;
          return {};
        },
      );
      return resultPartner;
    }
    debugPrint("partner data=outer===$updateAcc=======partner id===$idUser ");
    await queryCollectionDB("Relationship")
        .doc(idUser)
        .set(updateAcc, SetOptions(merge: true))
        .then((value) => {debugPrint("--add partner successfully -outer-->")})
        .onError(
      (error, stackTrace) {
        debugPrint("error--add partner outer--$error>");
        return {};
      },
    );
    return true;
  }

  Future<bool> addNewPendingReq(
      {required BuildContext context2,
      required String userName,
      required String imageUrl,
      required String Uid,
      required String idUser}) async {
    bool cek = false;
    List<Pending> listNewPendingReq = [];
    Map<String, dynamic> updateAcc = {};

    if (idUser != globalController.currentUser.value?.id) {
      DocumentSnapshot data = await queryCollectionDB("Relationship").doc(idUser).get();

      if (!data.exists) {
        await Global().setNewRelationship(idUser);
        data = await queryCollectionDB("Relationship").doc(idUser).get();
      }
      Relationship relationUserRequested = Relationship.fromDocument(data.data() as Map<String, dynamic>);

      cek = false;
      listNewPendingReq.assignAll(relationUserRequested.pendingReq);
      if (relationUserRequested.pendingReq.isNotEmpty) {
        cek = false;
        for (int index = 0; index <= relationUserRequested.pendingReq.length - 1; index++) {
          if (globalController.currentUser.value?.id == relationUserRequested.pendingReq[index].reqUid) {
            cek = true;
            break;
          }
        }
        if (cek) {
          listNewPendingReq
              .add(Pending(userName: userName, imageUrl: imageUrl, reqUid: Uid, createdAt: DateTime.now()));
        }
      } else {
        listNewPendingReq.add(Pending(userName: userName, imageUrl: imageUrl, reqUid: Uid, createdAt: DateTime.now()));
      }

      cek = false;
      if (relationUserRequested.pendingAcc.isNotEmpty) {
        for (int index = 0; index <= relationUserRequested.pendingAcc.length - 1; index++) {
          if (globalController.currentUser.value?.id == relationUserRequested.pendingAcc[index].reqUid) {
            cek = true;
            break;
          }
        }
      }
    } else {
      cek = false;
      listNewPendingReq.assignAll(globalController.currentUser.value?.relasi.value?.pendingReq ?? []);
      if (listNewPendingReq.isNotEmpty) {
        for (int index = 0; index <= listNewPendingReq.length - 1; index++) {
          if (Uid == listNewPendingReq[index].reqUid) {
            cek = true;
            break;
          }
        }
        if (!cek) {
          listNewPendingReq
              .add(Pending(userName: userName, imageUrl: imageUrl, reqUid: Uid, createdAt: DateTime.now()));
        }
      } else {
        listNewPendingReq.add(Pending(userName: userName, imageUrl: imageUrl, reqUid: Uid, createdAt: DateTime.now()));
      }

      cek = false;
      if ((globalController.currentUser.value?.relasi.value?.pendingAcc ?? []).isNotEmpty) {
        for (int index = 0;
            index <= (globalController.currentUser.value?.relasi.value?.pendingAcc ?? []).length - 1;
            index++) {
          if (Uid == (globalController.currentUser.value?.relasi.value?.pendingAcc ?? [])[index].reqUid) {
            cek = true;
            break;
          }
        }
      }
    }
    List listUpdateAcc = listNewPendingReq.map((player) => player.toJson()).toList();
    updateAcc.addAll({
      "pendingReq": listUpdateAcc,
    });

    debugPrint("partner data===request =$updateAcc=======partner id===$idUser ");
    bool result = false;
    await queryCollectionDB("Relationship")
        .doc(idUser)
        .set(updateAcc, SetOptions(merge: true))
        .then((value) => {debugPrint("--add partner request successfully 589--->"), result = true})
        .onError(
      (error, stackTrace) {
        debugPrint("error--add partner request592--$error>");
        result = false;
        return {};
      },
    );
    return result;
  }
}
