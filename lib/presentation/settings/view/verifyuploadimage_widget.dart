import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:hookup4u/presentation/settings/controllers/settings.controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';

class VerifyUploadImageWidget extends GetView<SettingsController> {
  const VerifyUploadImageWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Verification",
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
                    text: "Verification Status : ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: (globalController.currentUser.value?.verified ==
                                0)
                            ? "Unverified"
                            : (globalController.currentUser.value?.verified ==
                                    1)
                                ? "Under Review"
                                : (globalController
                                            .currentUser.value?.verified ==
                                        2)
                                    ? "Rejected"
                                    : "Verified",
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
              if (controller.verifyModel.value == null)
                Text("To get verified we will send you a code which you will need to write down on a A4 sheet of paper." +
                    "\n\nPlease make sure that the numbers are written in large font and can easily be seen." +
                    "\n\nYou will then take a selfie displaying your face alongside the sheet of paper."),
              if (controller.verifyModel.value != null)
                RichText(
                  text: TextSpan(
                    text: "Reason : \n",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                        text: controller.verifyModel.value!.reasonVerified,
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
              Center(
                child: Text(
                  "Your Verification Code",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  controller.codeVerify,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
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
              if (controller.currentFile.value == null &&
                  controller.verifyModel.value == null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: Image.asset(
                      "asset/images/ic_profile.png",
                      height: 200,
                    ),
                  ),
                ),
              if (controller.currentFile.value == null &&
                  controller.verifyModel.value != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: Image.network(
                      controller.verifyModel.value?.imageUrl ?? "",
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
                        (globalController.currentUser.value?.verified == 2)
                            ? "Replace Photo"
                            : "Upload Photo",
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
    );
  }
}
