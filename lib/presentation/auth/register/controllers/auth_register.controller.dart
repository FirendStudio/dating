import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/CustomTapModel.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../domain/core/interfaces/dialog.dart';
import '../../../../infrastructure/dal/util/color.dart';
import '../../../../infrastructure/dal/util/general.dart';
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
  ImagePicker imagePicker = ImagePicker();

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

  Future<void> pickImage(ImageSource source, {bool metode = false}) async {
    XFile? file = await imagePicker.pickImage(source: source, imageQuality: 50);

    if (file == null) {
      return;
    }
    if (metode) {
      croppedFile.value = await ImageCropper().cropImage(
        sourcePath: file.path,
        cropStyle: CropStyle.circle,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );
    }
  }

  processRegister() async {
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
    dataUser.addAll({
      'userGender': selectedGender.value?.name.value,
      'showOnProfile': false
    });
    dataUser.addAll({
      "sexualOrientation": {
        'orientation': selectedSexual.value?.name.value,
        'showOnProfile': false
      },
    });
    dataUser.addAll({
      'desires': listSelectedDesire.value,
      'showdesires': false,
    });
    dataUser.addAll(
        {'status': selectedStatus.value?.name.value, 'showstatus': false});
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

    int maxDistance =
        int.parse(Get.find<GlobalController>().items['free_radius'] ?? 20);
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

    await Get.find<GlobalController>()
        .firstAddUser(metode: Session().getLoginType(), dataExisting: dataUser);
    await uploadFile(
        croppedFile.value!, Get.find<GlobalController>().auth.currentUser!.uid);
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

  Future uploadFile(File image, String idUser) async {
    Get.dialog(Obx(() {
      return CircularPercentIndicator(
        radius: 120.0,
        lineWidth: 13.0,
        animation: true,
        percent: progressLoading.value,
        center: Text(
          "${(progressLoading.value * 100)}%",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
        ),
        footer: Text(
          "Uploading......",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 17.0, color: Colors.white),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: Colors.purple,
      );
    }));
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('users/$idUser/${image.hashCode}.jpg');
    UploadTask uploadTask = ref.putFile(File(image.path));
    // var stream = uploadTask.asStream();
    uploadTask.snapshotEvents.listen((event) {
      print("Progress : " +
          (event.bytesTransferred / event.totalBytes).toString());
      progressLoading.value =
          (event.bytesTransferred / event.totalBytes).toDouble();
    });

    uploadTask.then((res) async {
      String fileURL = await res.ref.getDownloadURL();

      try {
        Map<String, dynamic> updateObject = {
          "Pictures": [
            {"url": fileURL, "show": "true"}
          ],
        };
        print("object");
        await queryCollectionDB("Users").doc(idUser).set(
              updateObject,
              SetOptions(merge: true),
            );
        Get.back();
        await Future.delayed(Duration(seconds: 1));
        progressLoading.value = 0.0;
        await showWelcomDialog(Get.context);
        // if (mounted) setState(() {});
      } catch (err) {
        print("Error: $err");
      }
    });
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
