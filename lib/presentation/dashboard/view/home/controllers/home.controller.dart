import 'package:carousel_slider/carousel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';
import '../../../../../domain/core/model/user_model.dart';
import '../../../../../infrastructure/dal/controller/global_controller.dart';
import '../../../../../infrastructure/dal/util/general.dart';
import '../../../../../infrastructure/dal/util/session.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<UserModel> listUsers = RxList();
  List<String> checkedUser = [];
  List<String> listSwipedUser = [];
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
    listSwipedUser = Session().getSwipedUser();
    List<UserModel> tempList = [];
    UserModel currentUserTemp = Get.find<GlobalController>().currentUser.value!;
    var query =
        await queryCollectionDB('/Users/${currentUserTemp.id}/CheckedUser')
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
    query = await queryCollectionDB('Users')
        .where(
          'age',
          isGreaterThanOrEqualTo:
              int.parse(currentUserTemp.ageRange?['min'] ?? 0),
          isLessThanOrEqualTo:
              int.parse(currentUserTemp.ageRange?['max'] ?? 100),
        )
        .orderBy('age', descending: false)
        .get();
    if (query.docs.isEmpty) {
      return;
    }
    List<QueryDocumentSnapshot<Map<String, dynamic>>> temp = query.docs;
    print("Count All User : " + temp.length.toString());
    temp.removeWhere((element) => checkedUser.contains(element.id));
    for (var doc in temp) {
      Map<String, dynamic> json = doc.data();
      if (json.containsKey("age")) {
        UserModel tempUser = UserModel.fromJson(json);
        double distance = Global().calculateDistance(
          currentUserTemp.coordinates?['latitude'] ?? 0,
          currentUserTemp.coordinates?['longitude'] ?? 0,
          tempUser.coordinates?['latitude'] ?? 0,
          tempUser.coordinates?['longitude'] ?? 0,
        );
        tempUser.distanceBW = distance.round();
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
        if (listSwipedUser.contains(json['userId'])) {
          tempList.add(tempUser);
          if (json['UserName'] == "Yanuardila Liwang") {
            print("Masuk sini 1");
          }
          continue;
        }
        if (json['UserName'] == "Yanuardila Liwang") {
          print("Masuk sini 2");
        }
        listUsers.add(tempUser);
        continue;
      }
    }
    listUsers.sort((a, b) => a.distanceBW.compareTo(b.distanceBW));
    listUsers.addAll(tempList);
    if (listUsers.isEmpty) {
      isLoading.value = false;
      return;
    }
    listUsers.first.relasi.value =
        await Global().getRelationship(listUsers.first.id);
    addLastSwiped(listUsers.first);
    if(kDebugMode){
      print("count User Existing : " + listUsers.length.toString());
    }
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

  addLastSwiped(UserModel userModel) {
    if (kDebugMode) {
      print(listSwipedUser.contains(userModel.id));
    }
    if (listSwipedUser.contains(userModel.id)) {
      if (kDebugMode) {
        print("User already added to last Swiped : " + userModel.id);
      }
      return;
    }
    listSwipedUser.add(userModel.id);
    if (kDebugMode) {
      print("Adding Name to last Swiped : " + userModel.name);
      print("Adding user to last Swiped : " + userModel.id);
      print(listSwipedUser.length);
    }
    Session().saveSwipedUser(listSwipedUser);
  }
}
