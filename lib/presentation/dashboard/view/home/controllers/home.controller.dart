import 'package:carousel_slider/carousel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/SuspendModel.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';
import 'package:hookup4u/presentation/settings/controllers/settings.controller.dart';
import 'package:translator/translator.dart';

import '../../../../../domain/core/model/user_model.dart';
import '../../../../../infrastructure/dal/controller/global_controller.dart';
import '../../../../../infrastructure/dal/util/general.dart';
import '../../../../../infrastructure/dal/util/session.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<UserModel> listUsers = RxList();
  RxList<ReviewModel> listReviewUser = RxList();
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

  ///-- search only verified user and  location base user display
  initUser() async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    listUsers.value = [];
    listReviewUser.value = [];
    checkedUser = [];
    listSwipedUser = Session().getSwipedUser();
    List<UserModel> tempList = [];
    UserModel currentUserTemp = Get.find<GlobalController>().currentUser.value!;

    var query = await queryCollectionDB('/Users/${currentUserTemp.id}/CheckedUser').get();

    if (query.docs.isNotEmpty) {
      query.docs.forEach((element) {
        // print(element.data()["LikedUser"]);
        if (element.data()["LikedUser"] == null) {
          checkedUser.add(element.data()["DislikedUser"]);
        } else {
          checkedUser.add(element.data()["LikedUser"]);
        }
      });
    }

    query = await queryCollectionDB('Users')
        .where(
          'age',
          isGreaterThanOrEqualTo: int.parse(currentUserTemp.ageRange?['min'] ?? 0),
          isLessThanOrEqualTo: int.parse(currentUserTemp.ageRange?['max'] ?? 100),
        )
        .orderBy('age', descending: false)
        .get();
    if (query.docs.isEmpty) {
      return;
    }
    List<QueryDocumentSnapshot<Map<String, dynamic>>> temp = query.docs;
    // temp.removeWhere((element) => checkedUser.contains(element.id));
    query = await queryCollectionDB("Review").get();
    query.docs.forEach((element) {
      listReviewUser.add(ReviewModel.fromJson(element.data()));
    });
    print("Count All User : " + temp.length.toString());



    for (var doc in temp) {
      Map<String, dynamic> json = doc.data();
      if (json.containsKey("age")) {
        UserModel tempUser = UserModel.fromJson(json);
        double distance = Global().calculateDistance(
          currentUserTemp.coordinates?['latitude'] ?? 0.0,
          currentUserTemp.coordinates?['longitude'] ?? 0.0,
          tempUser.coordinates?['latitude'] ?? 0.0,
          tempUser.coordinates?['longitude'] ?? 0.0,
        );
        tempUser.distanceBW = distance.round();

        if (filterUser(tempUser, currentUserTemp, distance)) {
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
          continue;
        }
        listUsers.add(tempUser);
        listUsers.refresh();
        continue;
      }
    }

    listUsers.sort((a, b) => a.distanceBW.compareTo(b.distanceBW));
    listUsers.addAll(tempList);
    final googleTranslator = GoogleTranslator();
    listUsers.forEach((element) async {
      if (element.countryName.isNotEmpty && element.countryName != "") {
        try {

          googleTranslator.translate(element.countryName, to: 'en').then((value) => {
            element.countryName = value.toString()??"",

              });
        } on Exception catch (e) {
          debugPrint("translatedName--error---$e");
        }
      }
    });

    if (listUsers.isEmpty) {
      isLoading.value = false;
      return;
    }
    listUsers.first.relasi.value = await Global().getRelationship(listUsers.first.id);
    //  addLastSwiped(listUsers.first);
    if (kDebugMode) {
      print("count User Existing : " + listUsers.length.toString());
    }
    isLoading.value = false;
    listUsers.sort((a, b) => a.distanceBW.compareTo(b.distanceBW));
    listUsers.refresh();

    if (SettingsController.isVerifiedUserOnly.value) {
      listUsers.removeWhere((element) => element.verified != 3);
      listUsers.sort((a, b) => a.distanceBW.compareTo(b.distanceBW));
      listUsers.refresh();
    }
  }

  ///-- client initUser();

  initUserClient() async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    listUsers.value = [];
    listReviewUser.value = [];
    checkedUser = [];
    listSwipedUser = Session().getSwipedUser();
    List<UserModel> tempList = [];
    UserModel currentUserTemp = Get.find<GlobalController>().currentUser.value!;
    var query =
    await queryCollectionDB('/Users/${currentUserTemp.id}/CheckedUser')
        .get();
    if (query.docs.isNotEmpty) {
      query.docs.forEach((element) {
        // print(element.data()["LikedUser"]);
        if (element.data()["LikedUser"] == null) {
          checkedUser.add(element.data()["DislikedUser"]);
        } else {
          checkedUser.add(element.data()["LikedUser"]);
        }
      });
    }
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
    // temp.removeWhere((element) => checkedUser.contains(element.id));
    query = await queryCollectionDB("Review").get();
    query.docs.forEach((element) {
      listReviewUser.add(ReviewModel.fromJson(element.data()));
    });
    print("Count All User : " + temp.length.toString());
    for (var doc in temp) {
      if (doc.id == "5VZ3Fp0NMgX5X3iDYW4vnCCxni22") {
        print("Masuk sni woy");
      }
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
        if (filterUser(tempUser, currentUserTemp, distance)) {
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
          continue;
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
    if (kDebugMode) {
      print("count User Existing : " + listUsers.length.toString());
    }
    isLoading.value = false;
    listUsers.sort((a, b) => a.distanceBW.compareTo(b.distanceBW));
    listUsers.refresh();

    if (SettingsController.isVerifiedUserOnly.value) {
      listUsers.removeWhere((element) => element.verified != 3);
      listUsers.sort((a, b) => a.distanceBW.compareTo(b.distanceBW));
      listUsers.refresh();
    }
  }

  bool filterUser(UserModel tempUser, UserModel currentUserTemp, double distance) {
    if (checkedUser.contains(tempUser.id)) {
      if (tempUser.name == "arjun") {
        debugPrint("call filterUser---checked-->");
      }
      return true;
    }
    if (cekShowMe(currentUserTemp, tempUser)) {
      if (tempUser.name == "arjun") {
        debugPrint("call filterUser---cekshowme-->");
      }
      return true;
    }
    if (cekDistance(distance, tempUser, currentUserTemp)) {
      if (tempUser.name == "arjun") {
        debugPrint("call filterUser---cek ditsnce-->");
      }
      return true;
    }
    if (cekReview(tempUser)) {
      if (tempUser.name == "arjun") {
        debugPrint("call filterUser---cekreview-->");
      }
      return true;
    }
    if (tempUser.name == "arjun") {
      debugPrint("call filterUser---outter-->");
    }
    return false;
  }

  bool cekShowMe(UserModel currentUser, UserModel tempUser) {
    if (currentUser.showMe.isEmpty) {
      return false;
    }
    if (currentUser.showMe.contains(cekGender(tempUser.editInfo?['userGender']))) {
      // print("Masuk cek Show Me");
      return false;
    }
    return true;
  }

  String? cekGender(String? gender) {
    if (gender == null) {
      return gender;
    }
    if (gender == "man") {
      return "men";
    }
    if (gender == "woman") {
      return "women";
    }
    return gender;
  }

  bool cekReview(UserModel tempUser) {
    if (listReviewUser.isEmpty) {
      return true;
    }
    for (var temp in listReviewUser) {
      if (tempUser.id == temp.idUser) {
        return true;
      }
    }
    return false;
  }

  bool cekDistance(double distance, UserModel tempUser, UserModel currentUserTemp) {
    if (distance <= currentUserTemp.maxDistance && tempUser.id != currentUserTemp.id && !tempUser.isBlocked) {
      return false;
    }
    return true;
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
