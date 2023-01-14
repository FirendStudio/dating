import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import '../../../../domain/core/model/CustomTapModel.dart';
import '../../../../domain/core/model/user_model.dart';
import '../../../../infrastructure/dal/util/color.dart';

class ProfileEditController extends GetxController {
  int indexImage = 0;
  final TextEditingController aboutCtlr = new TextEditingController();
  final TextEditingController companyCtlr = new TextEditingController();
  final TextEditingController livingCtlr = new TextEditingController();
  final TextEditingController jobCtlr = new TextEditingController();
  final TextEditingController universityCtlr = new TextEditingController();

  Rxn<CustomTapModel> selectedGender = Rxn();
  Rxn<CustomTapModel> selectedSexual = Rxn();
  Rxn<CustomTapModel> selectedStatus = Rxn();

  List<String> listSelectedDesire = [];
  List<String> listSelectedKinks = [];
  RxList<String> listSelectedInterest = RxList();

  Map<String, dynamic> editInfo = {};
  Map<String, dynamic> orientationMap = {};
  Map<String, dynamic> statusMap = {};
  Map<String, dynamic> desiresMap = {};
  Map<String, dynamic> kinksMap = {};
  Map<String, dynamic> interestMap = {};

  @override
  void onInit() {
    super.onInit();
    aboutCtlr.text =
        globalController.currentUser.value?.editInfo?['about'] ?? "";
    companyCtlr.text =
        globalController.currentUser.value?.editInfo?['company'] ?? "";
    livingCtlr.text =
        globalController.currentUser.value?.editInfo?['living_in'] ?? "";
    universityCtlr.text =
        globalController.currentUser.value?.editInfo?['university'] ?? "";
    jobCtlr.text =
        globalController.currentUser.value?.editInfo?['job_title'] ?? "";
    initData();
  }

  initData() {
    // print(widget.currentUser.gender);
    selectedGender.value = listGender.firstWhere((element) =>
        globalController.currentUser.value?.gender == element.name.value);
    selectedSexual.value = orientationlist.firstWhere((element) =>
        globalController.currentUser.value?.sexualOrientation ==
        element.name.value);
    selectedStatus.value = listStatus.firstWhere((element) =>
        globalController.currentUser.value?.status == element.name.value);
    //init Desires
    if ((globalController.currentUser.value?.desires ?? []).isNotEmpty) {
      for (int i = 0;
          i <= globalController.currentUser.value!.desires.length - 1;
          i++) {
        listSelectedDesire.add(globalController.currentUser.value!.desires[i]);

        for (int j = 0; j <= listDesire.length - 1; j++) {
          if (globalController.currentUser.value?.desires[i] ==
              listDesire[j].name.value) {
            listDesire[j].onTap.value = true;
            break;
          }
        }
      }
    }

    //init Interest
    if ((globalController.currentUser.value?.interest ?? []).isNotEmpty) {
      for (int i = 0;
          i <= globalController.currentUser.value!.interest.length - 1;
          i++) {
        listSelectedInterest
            .add(globalController.currentUser.value!.interest[i]);
      }
    }

    //init kinks
    if ((globalController.currentUser.value?.kinks ?? []).isNotEmpty) {
      for (int i = 0;
          i <= globalController.currentUser.value!.kinks.length - 1;
          i++) {
        listSelectedKinks.add(globalController.currentUser.value!.kinks[i]);

        for (int j = 0; j <= listKinks.length - 1; j++) {
          if (globalController.currentUser.value!.kinks[i] ==
              listKinks[j].name.value) {
            listKinks[j].onTap.value = true;
            break;
          }
        }
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    updateData();
  }

  Future updateData() async {
    Map<String, dynamic> updateMap = {};

    if (editInfo.length > 0) {
      updateMap.addAll({
        'editInfo': editInfo,
        'age': globalController.currentUser.value?.age
      });
    }
    if (orientationMap.length > 0) {
      updateMap.addAll(orientationMap);
    }

    if (statusMap.length > 0) {
      updateMap.addAll(statusMap);
    }

    if (desiresMap.length > 0) {
      updateMap.addAll(desiresMap);
    }

    if (interestMap.length > 0) {
      updateMap.addAll(interestMap);
    }

    if (kinksMap.length > 0) {
      updateMap.addAll(kinksMap);
    }

    if (updateMap.length > 0) {
      queryCollectionDB("Users")
          .doc(globalController.currentUser.value?.id)
          .set(updateMap, SetOptions(merge: true));
    }
  }

  Future showPrivateImageDialog(BuildContext context2, bool isProfilePicture,
      UserModel userModel, bool deleted, bool show) async {
    // print(show);
    await showDialog<String>(
      context: context2,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context3, StateSetter setState2) {
          return CupertinoAlertDialog(
            content: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        var url = "";
                        if (globalController.currentUser.value
                                ?.imageUrl[indexImage].runtimeType ==
                            String) {
                          url = globalController
                              .currentUser.value!.imageUrl[indexImage];
                        } else {
                          url = globalController
                              .currentUser.value?.imageUrl[indexImage]['url'];
                        }
                        var data = {"url": url, "show": "true"};

                        globalController.currentUser.value?.imageUrl
                            .removeAt(indexImage);
                        globalController.currentUser.value?.imageUrl
                            .insert(0, data);
                        await queryCollectionDB("Users")
                            .doc(globalController.currentUser.value?.id)
                            .set({
                          "Pictures":
                              globalController.currentUser.value?.imageUrl
                        }, SetOptions(merge: true));
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 18,
                          right: 18,
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          "Set as my profile image",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    InkWell(
                      onTap: () async {
                        var url = "";
                        if (globalController.currentUser.value
                                ?.imageUrl[indexImage].runtimeType ==
                            String) {
                          url = globalController
                              .currentUser.value?.imageUrl[indexImage];
                        } else {
                          url = globalController
                              .currentUser.value?.imageUrl[indexImage]['url'];
                        }
                        bool showPhotos = !show;
                        var data = {"url": url, "show": showPhotos.toString()};

                        globalController
                            .currentUser.value?.imageUrl[indexImage] = data;
                        if (kDebugMode) {
                          print(globalController.currentUser.value?.imageUrl);
                        }
                        await queryCollectionDB("Users")
                            .doc(globalController.currentUser.value?.id)
                            .set({
                          "Pictures":
                              globalController.currentUser.value?.imageUrl
                        }, SetOptions(merge: true));
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 18,
                          right: 18,
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          (!show)
                              ? "Set this image to public"
                              : "Set this image to private",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    InkWell(
                      onTap: () async {
                        await deletePicture(indexImage);
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 18,
                          right: 18,
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          "Delete this image",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
      barrierDismissible: true,
    );
  }

  Future<void> deletePicture(index) async {
    if (globalController.currentUser.value?.imageUrl[index] != null) {
      try {
        var _ref = FirebaseStorage.instance
            .ref(globalController.currentUser.value?.imageUrl[index]);
        print(_ref.fullPath);
        await _ref.delete();
      } catch (e) {
        print(e);
      }
    }
    globalController.currentUser.value?.imageUrl.removeAt(index);
    var temp = [];
    temp.add(globalController.currentUser.value?.imageUrl);
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(globalController.currentUser.value?.id)
        .set(
      {"Pictures": temp[0]},
      SetOptions(merge: true),
    );
  }

  dialogInterest(BuildContext context2) async {
    TextEditingController interestText = TextEditingController();
    ArtDialogResponse? response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context2,
        artDialogArgs: ArtDialogArgs(
            showCancelBtn: true,
            // denyButtonText: "Cancel",
            title: "Enter your interest",
            confirmButtonText: "Save",
            customColumns: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.red)),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: "Your interest",
                  ),
                  controller: interestText,
                ),
              ),
              SizedBox(
                height: 20,
              )
            ]));
    if (response == null) {
      // FocusScope.of(Get.context!).requestFocus(FocusNode());
      return;
    }

    if (response.isTapConfirmButton) {
      listSelectedInterest.add(interestText.text);

      interestMap.addAll({
        'interest': listSelectedInterest.value,
      });
      ArtSweetAlert.show(
          context: Get.context!,
          artDialogArgs:
              ArtDialogArgs(type: ArtSweetAlertType.success, title: "Saved!"));
      // FocusScope.of(Get.context!).requestFocus(FocusNode());
      return;
    }
  }
}
