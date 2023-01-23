import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/SuspendModel.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../infrastructure/dal/util/general.dart';
import '../../../../../infrastructure/navigation/routes.dart';

class SettingsViewVerifiedProfileController extends GetxController {
  late ReviewModel selectedReviewModel;
  Rxn<File> currentFile = Rxn();
  @override
  void onInit() {
    super.onInit();
    selectedReviewModel = Get.arguments['reviewModel'];
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future uploadFile(File image) async {
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
    Reference ref = storage.ref().child(
        'verify/${globalController.currentUser.value?.id}/${image.hashCode}.jpg');
    UploadTask uploadTask = ref.putFile(File(image.path));
    uploadTask.snapshotEvents.listen((event) {
      print("Progress : " +
          (event.bytesTransferred / event.totalBytes).toString());
      progressLoading.value =
          (event.bytesTransferred / event.totalBytes).toDouble();
    });

    uploadTask.then((res) async {
      String fileURL = await res.ref.getDownloadURL();

      try {
        selectedReviewModel.listImage?.add(ListImage(
          imageUrl: fileURL,
          status: "review",
          reason: "",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        await queryCollectionDB("Review")
            .doc(selectedReviewModel.idUser)
            .set(selectedReviewModel.toJson());
        Get.back();
        await Future.delayed(Duration(seconds: 1));
        progressLoading.value = 0.0;
        await showDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return Material(
              color: Colors.transparent,
              child: CupertinoAlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text("Account Verification")],
                ),
                content: Column(
                  children: [
                    Text(
                      "Thanks for submitting your photo! Please allow up to 24 hours for our staff to manually verify your profile.",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(Get.context!);
                              Get.offAllNamed(Routes.DASHBOARD);
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 0,
                                top: 4,
                                bottom: 4,
                                right: 6,
                              ),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                ),
                              ),
                              child: Text(
                                "Okay",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                insetAnimationCurve: Curves.decelerate,
                actions: [],
              ),
            );
          },
        );
      } catch (err) {
        print("Error: $err");
      }
    });
  }
}
