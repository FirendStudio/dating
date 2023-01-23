import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../infrastructure/dal/util/Global.dart';
import '../../../../infrastructure/dal/util/color.dart';
import 'controllers/settings_view_verified_profile.controller.dart';

class SettingsViewVerifiedProfileScreen
    extends GetView<SettingsViewVerifiedProfileController> {
  const SettingsViewVerifiedProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(SettingsViewVerifiedProfileController());
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile Verification",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: Container(
          padding: const EdgeInsets.only(
            left: 15.0,
            right: 15,
            bottom: 5,
            top: 10,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                      text: "Status : ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: "Suspend",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ]),
                ),
                SizedBox(
                  height: 20,
                ),
                RichText(
                  text: TextSpan(
                    text: "Reason : \n",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                        text: controller.selectedReviewModel.reason?.value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                SizedBox(height: 30),
                if (controller.currentFile.value != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Image.file(
                        controller.currentFile.value!,
                        height: 200,
                      ),
                    ),
                  ),
                if (controller.currentFile.value == null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Image.network(
                        controller.selectedReviewModel.listImage?.last
                                ?.imageUrl ??
                            "",
                        height: 200,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      iconSize: 50,
                      color: Colors.black,
                      onPressed: () async {
                        controller.currentFile.value = await Global()
                            .pickImage(ImageSource.camera, metode: true);
                      },
                      icon: Icon(Icons.photo_camera),
                    ),
                    IconButton(
                      iconSize: 50,
                      color: Colors.black,
                      onPressed: () async {
                        controller.currentFile.value = await Global()
                            .pickImage(ImageSource.gallery, metode: true);
                      },
                      icon: Icon(Icons.image),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: InkWell(
                    onTap: () async {
                      if (controller.currentFile.value == null) {
                        Get.snackbar(
                            "Information", "Please select your photo first");
                        return;
                      }
                      controller.uploadFile(controller.currentFile.value!);
                    },
                    child: Container(
                      height: Get.size.height * .065,
                      width: Get.size.width * .75,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Replace Photo",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
