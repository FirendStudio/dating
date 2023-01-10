import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/CustomTapModel.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';

import '../../../../infrastructure/dal/util/session.dart';

class AuthRegisterController extends GetxController {
  Map<String, dynamic> dataUser = {};
  RxInt indexView = 0.obs;
  DateTime? selectedDate;
  Rxn<CustomTapModel> selectedGender = Rxn();
  Rxn<CustomTapModel> selectedSexual = Rxn();
  RxList<String> listSelectedDesire = RxList();
  Rxn<CustomTapModel> selectedStatus = Rxn();
  RxList<String> listSelectedShowMe = RxList();
  Rxn<Map<String, dynamic>> selectedCoordinate = Rxn();
  Rxn<File> croppedFile = Rxn();

  TextEditingController usernameController = TextEditingController();
  TextEditingController dobController = new TextEditingController();

  Future<bool> onBack() async {
    if (indexView.value == 0) {
      Get.back();
      return await true;
    }
    if (indexView.value == 2 && checkDisplayName()) {
      Get.back();
      return await false;
    }
    indexView--;
    return await false;
  }

  process() {
    if (checkDisplayName()) {
      dataUser.addAll(
          {'UserName': "${FirebaseAuth.instance.currentUser!.displayName!}"});
    } else {
      dataUser.addAll({'UserName': "${usernameController.text}"});
    }
    dataUser.addAll({
      'user_DOB': "${selectedDate}",
      'age': ((DateTime.now().difference(selectedDate!).inDays) / 365.2425)
          .truncate(),
    });
    dataUser.addAll(
        {'userGender': selectedGender.value?.name, 'showOnProfile': false});
    dataUser.addAll({
      "sexualOrientation": {
        'orientation': selectedSexual.value?.name,
        'showOnProfile': false
      },
    });
    dataUser.addAll({
      'desires': listSelectedDesire.value,
      'showdesires': false,
    });
    dataUser
        .addAll({'status': selectedStatus.value?.name, 'showstatus': false});
    dataUser.addAll({'showGender': listSelectedShowMe.value});
    dataUser.addAll({
      'editInfo': {
        'university': "",
        'userGender': dataUser['userGender'],
        'showOnProfile': dataUser['showOnProfile']
      }
    });
    dataUser.remove('showOnProfile');
    dataUser.remove('userGender');

    int maxDistance = int.parse(Get.find<GlobalController>().items['free_radius']  ?? 20);
    dataUser.addAll(
      {
        "listSwipedUser": [],
        "verified": 0,
        'location': {
          'latitude': selectedCoordinate.value?['latitude'] ?? 0,
          'longitude': selectedCoordinate.value?['longitude'] ?? 0,
          'address': selectedCoordinate.value?['PlaceName'] ?? "",
          'countryName': selectedCoordinate.value?['countryName'] ?? "",
          'countryID': selectedCoordinate.value?['countryID'] ?? "",
        },
        'maximum_distance': maxDistance,
        'age_range': {
          'min': "18",
          'max': "99",
        },
      },
    );

    Get.find<GlobalController>()
        .firstAddUser(metode: Session().getLoginType(), dataExisting: dataUser);
  }

  bool checkDisplayName() {
    if (FirebaseAuth.instance.currentUser?.displayName != null &&
        FirebaseAuth.instance.currentUser!.displayName!.isNotEmpty) {
      return true;
    }
    return false;
  }

  insertListDesire(String name) {
    bool cek = listSelectedDesire.contains(name);
    if (!cek) {
      listSelectedDesire.add(name);
      return;
    }
    listSelectedDesire.remove(name);
  }

  insertListShowMe(String name) {
    bool cek = listSelectedShowMe.contains(name);
    if (!cek) {
      listSelectedShowMe.add(name);
      return;
    }
    listSelectedShowMe.remove(name);
  }

  @override
  void onInit() {
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
}
