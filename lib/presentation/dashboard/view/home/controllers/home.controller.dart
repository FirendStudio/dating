import 'package:carousel_slider/carousel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';
import 'package:hookup4u/presentation/screens.dart';

import '../../../../../domain/core/model/Relationship.dart';
import '../../../../../domain/core/model/user_model.dart';
import '../../../../../infrastructure/dal/controller/global_controller.dart';
import '../../../../../infrastructure/dal/util/color.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<UserModel> listUsers = RxList();
  List<String> checkedUser = [];
  RxInt indexImage = 0.obs;
  RxInt indexUser = 0.obs;
  CarouselController carouselUserController = CarouselController();
  CarouselController carouselImageController = CarouselController();
  @override
  void onInit() {
    initAllHome();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  initAllHome() {
    initUser();
  }

  initUser() async {
    isLoading.value = true;
    listUsers.value = [];
    checkedUser = [];
    List<UserModel> tempList = [];
    UserModel currentUserTemp = Get.find<GlobalController>().currentUser.value!;
    var query = await FirebaseFirestore.instance
        .collection('/Users/${currentUserTemp.id}/CheckedUser')
        .get();
    if (query.docs.isEmpty) {
      isLoading.value = false;
      return;
    }
    query.docs.forEach((element) {
      // print(element.data()["LikedUser"]);
      if (element.data()["LikedUser"] == null) {
        checkedUser.add(element.data()["DislikedUser"]);
      } else {
        checkedUser.add(element.data()["LikedUser"]);
      }
    });
    // checkedUser.addAll(currentUserTemp.listSwipedUser);
    query = await FirebaseFirestore.instance
        .collection('Users')
        .where("userId", whereNotIn: checkedUser)
        .get();
    for (var doc in query.docs) {
      Map<String, dynamic> json = doc.data();

      if (json.containsKey("age") &&
          json["age"] < int.parse(currentUserTemp.ageRange?['max']) &&
          json["age"] > int.parse(currentUserTemp.ageRange?['min'])) {
        UserModel tempUser = UserModel.fromJson(json);
        double distance = Global().calculateDistance(
          currentUserTemp.coordinates?['latitude'] ?? 0,
          currentUserTemp.coordinates?['longitude'] ?? 0,
          tempUser.coordinates?['latitude'] ?? 0,
          tempUser.coordinates?['longitude'] ?? 0,
        );
        tempUser.distanceBW = distance.round();
        // if (kDebugMode) {
        //   print("Jarak : " + distance.toString());
        //   print(tempUser.maxDistance);
        // }
        if (!cekDistance(distance, tempUser, currentUserTemp)) {
          continue;
        }
        if (tempUser.imageUrl.isNotEmpty) {
          List imageUrlTemp = [];
          for (int i = 0; i <= tempUser.imageUrl.length - 1; i++) {
            if (tempUser.imageUrl[i].runtimeType == String) {
              imageUrlTemp.add({"url": tempUser.imageUrl[i], "show": "true"});
            } else {
              if (tempUser.imageUrl[i]['show'] == "true") {
                imageUrlTemp.add(tempUser.imageUrl[i]);
              }
            }
          }
        }
        if (currentUserTemp.listSwipedUser.contains(json['userId'])) {
          tempList.add(tempUser);
          continue;
        }
        listUsers.add(tempUser);
        continue;
      }
    }
    listUsers.addAll(tempList);
    if (listUsers.isEmpty) {
      isLoading.value = false;
      return;
    }
    listUsers.first.relasi.value =
        await Global().getRelationship(listUsers.first.id);
    addLastSwiped(listUsers.first.id);
    print("count User : " + listUsers.length.toString());
    isLoading.value = false;
  }

  bool cekDistance(
      double distance, UserModel tempUser, UserModel currentUserTemp) {
    if (distance <= currentUserTemp.maxDistance &&
        tempUser.id != currentUserTemp.id &&
        !tempUser.isBlocked) {
      return true;
    }
    return false;
  }

  Future<UserModel> initNextSwipe(UserModel userModel) async {
    userModel.relasi.value = await Global().getRelationship(listUsers.first.id);
    return userModel;
  }

  UserModel? getUserSelected(String idUser) {
    UserModel? selected;
    selected = listUsers.firstWhereOrNull((element) => element.id == idUser);
    return selected;
  }

  addLastSwiped(String idUID) {
    if (kDebugMode) {
      print("Adding user to last Swiped : " + idUID);
      print(Get.find<GlobalController>()
          .currentUser
          .value!
          .listSwipedUser
          .contains(idUID));
    }
    if (Get.find<GlobalController>()
        .currentUser
        .value!
        .listSwipedUser
        .contains(idUID)) {
      return;
    }
    Get.find<GlobalController>().currentUser.value!.listSwipedUser.add(idUID);
    print(Get.find<GlobalController>().currentUser.value!.listSwipedUser);
    FirebaseFirestore.instance
        .collection("Users")
        .doc(Get.find<GlobalController>().currentUser.value!.id)
        .set(
      {
        "listSwipedUser":
            Get.find<GlobalController>().currentUser.value!.listSwipedUser
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  
}
