import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../domain/core/model/user_model.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';

class ProfileController extends GetxController {
  Rxn<Map<String, dynamic>> newAddress = Rxn();
  
  @override
  Future<void> onInit() async {
    super.onInit();
    newAddress.value = await Global().getLocationCoordinates() ?? {};
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void updateAddress(Map _address) {
    showCupertinoModalPopup(
        context: Get.context!,
        builder: (ctx) {
          return Container(
            color: Colors.white,
            width: Get.width,
            height: Get.height * .4,
            child: Column(
              children: <Widget>[
                Material(
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'New address:',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.black26,
                      ),
                      onPressed: () => Navigator.pop(Get.context!),
                    ),
                    subtitle: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _address['PlaceName'] ?? '',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Confirm",
                    style: TextStyle(color: primaryColor),
                  ),
                  onPressed: () async {
                    Get.back();
                    await queryCollectionDB("Users")
                        .doc('${globalController.currentUser.value?.id}')
                        .update(
                      {
                        'location': {
                          'latitude': _address['latitude'],
                          'longitude': _address['longitude'],
                          'address': _address['PlaceName']
                        },
                      },
                    );
                    showDialog(
                      barrierDismissible: false,
                      context: Get.context!,
                      builder: (_) {
                        Future.delayed(Duration(seconds: 3), () {
                          Get.back();
                        });
                        return Center(
                          child: Container(
                            width: 160.0,
                            height: 120.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                  "asset/auth/verified.jpg",
                                  height: 60,
                                  color: primaryColor,
                                  colorBlendMode: BlendMode.color,
                                ),
                                Text(
                                  "location\nchanged",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          );
        });
  }

  Future source(BuildContext context, UserModel currentUser,
      bool isProfilePicture, String show) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text(
                  isProfilePicture ? "Update profile picture" : "Add pictures"),
              content: StatefulBuilder(
                builder: (BuildContext context2, StateSetter setState2) {
                  return Column(
                    children: [
                      Text(
                        "Select source",
                      ),
                    ],
                  );
                },
              ),
              insetAnimationCurve: Curves.decelerate,
              actions: currentUser.imageUrl.length < 9
                  ? <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.photo_camera,
                                size: 28,
                              ),
                              Text(
                                " Camera",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            getImage(ImageSource.camera, context, currentUser,
                                isProfilePicture, show);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.photo_library,
                                size: 28,
                              ),
                              Text(
                                " Gallery",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            getImage(ImageSource.gallery, context, currentUser,
                                isProfilePicture, show);
                          },
                        ),
                      ),
                    ]
                  : [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Center(
                            child: Column(
                          children: <Widget>[
                            Icon(Icons.error),
                            Text(
                              "Can't uplaod more than 9 pictures",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  decoration: TextDecoration.none),
                            ),
                          ],
                        )),
                      )
                    ]);
        });
  }

  Future getImage(ImageSource imageSource, context, currentUser,
      isProfilePicture, String show) async {
    try {
      var image =
          await ImagePicker().pickImage(source: imageSource, imageQuality: 10);
      if (image != null) {
        File? croppedFile = await ImageCropper().cropImage(
            sourcePath: image.path,
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
            ));
        if (croppedFile != null) {
          await uploadFile(
            await Global().compressimage(croppedFile) ?? croppedFile,
            currentUser,
            isProfilePicture,
            show,
          );
        }
      }
      // Navigator.pop(context);
    } catch (e) {
      Global().showInfoDialog(e.toString());
      // Navigator.pop(context);
    }
  }

  Future uploadFile(
      File image, UserModel currentUser, isProfilePicture, String show) async {
    Get.dialog(
      Obx(() {
        return CircularPercentIndicator(
          radius: 120.0,
          lineWidth: 13.0,
          animation: true,
          percent: progressLoading.value,
          center: Text(
            "${(progressLoading.value * 100)}%",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.white),
          ),
          footer: Text(
            "Uploading......",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
                color: Colors.white),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: Colors.purple,
        );
      }),
      barrierDismissible: false,
    );
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref =
        storage.ref().child('users/${currentUser.id}/${image.hashCode}.jpg');
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
        if (isProfilePicture) {
          currentUser.imageUrl.insert(0, {"url": fileURL, "show": show});
          if (kDebugMode) {
            print(currentUser.imageUrl);
          }
          await queryCollectionDB("Users")
              .doc(currentUser.id)
              .set({"Pictures": currentUser.imageUrl}, SetOptions(merge: true));
        } else {
          currentUser.imageUrl.add({"url": fileURL, "show": show});
          if (kDebugMode) {
            print(currentUser.imageUrl[currentUser.imageUrl.length - 1]['url']);
          }
          await queryCollectionDB("Users")
              .doc(currentUser.id)
              .set({"Pictures": currentUser.imageUrl}, SetOptions(merge: true));
        }
        Get.back();
        await Future.delayed(Duration(seconds: 1));
        progressLoading.value = 0.0;
      } catch (err) {
        print("Error: $err");
      }
    });
  }
}
