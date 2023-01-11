import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';

class NotifController extends GetxController {
  RxInt indexNotif = 0.obs;
  List listLikedUserAll = [];
  RxList listLikedUser = RxList();
  List listMatchUserAll = [];
  RxList listMatchUser = RxList();

  getLikedByList() {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(Get.find<GlobalController>().currentUser.value?.id)
        .collection("LikedBy")
        .orderBy('LikedBy', descending: true)
        .snapshots()
        .listen((data) async {
      listLikedUserAll.assignAll(data.docs);
      print("Jumlah LikedBy : " + listLikedUserAll.length.toString());
      filterLiked();
    });
  }

  getMatches() async {
    return FirebaseFirestore.instance
        .collection(
            '/Users/${Get.find<GlobalController>().currentUser.value?.id}/Matches')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((ondata) async {
      print(ondata.docs.length);
      if (ondata.docs.isNotEmpty) {
        listMatchUserAll.assignAll(ondata.docs);
        filterMatches();
        filterLiked();
      }
    });
  }

  filterLiked() {
    listLikedUser.assignAll(listLikedUserAll);
    if (listMatchUserAll.isNotEmpty && listLikedUserAll.isNotEmpty) {
      for (int i = 0; i <= listMatchUserAll.length - 1; i++) {
        if (listLikedUserAll.isEmpty) {
          return;
        }
        for (int j = 0; j <= listLikedUserAll.length - 1; j++) {
          if (listLikedUserAll[j]['LikedBy'] ==
              listMatchUserAll[i]['Matches']) {
            if (listLikedUser.isNotEmpty) {
              listLikedUser.removeWhere((element) =>
                  element['LikedBy'] == listLikedUserAll[j]['LikedBy']);
            }
          }
        }
      }
    }
  }

  filterMatches() async {
    listMatchUser.value = [];
    listMatchUserAll.forEach((element) {
      var mapTemp = {
        "Matches": element['Matches'],
        "isRead": element['isRead'],
        "pictureUrl": element['pictureUrl'],
        "timestamp": element['timestamp'],
        "userName": element['userName'],
        "type": 0,
      };
      listMatchUser.add(mapTemp);
    });
    // if (listMatchUser.isNotEmpty) {
    //   for (var list in listMatchUser) {
    //     list['type'] = await getNotifLeave(Get.find<ChatController>()
    //         .chatIdCustom(
    //             Get.find<TabsController>().currentUser.id, list['Matches']));
    //     print(list['type']);
    //   }
    // }
  }

  initAll() {
    getLikedByList();
    getMatches();
  }

  @override
  void onInit() {
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
  }
}
