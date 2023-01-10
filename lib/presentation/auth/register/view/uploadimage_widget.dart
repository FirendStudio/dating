import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/presentation/auth/register/controllers/auth_register.controller.dart';

import '../../../../infrastructure/dal/util/Global.dart';
import '../../../../infrastructure/dal/util/color.dart';

class UploadImageWidget extends GetView<AuthRegisterController> {
  const UploadImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.onBack,
      child: Obx(
        (() => SafeArea(
              child: Scaffold(
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.startTop,
                floatingActionButton: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 50),
                        child: FloatingActionButton(
                          heroTag: UniqueKey(),
                          elevation: 10,
                          child: IconButton(
                            color: secondryColor,
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: controller.onBack,
                          ),
                          backgroundColor: Colors.white38,
                          onPressed: controller.onBack,
                        ),
                      ),
                    ],
                  ),
                ),
                body: Container(
                  padding:
                      EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: (controller.croppedFile.value == null)
                                  ? Image.asset(
                                      "asset/images/ic_profile.png",
                                      height: 200,
                                    )
                                  : Image.file(
                                      controller.croppedFile.value!,
                                      height: 200,
                                    ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  iconSize: 50,
                                  color: Colors.black,
                                  onPressed: () {
                                    // data.pickImage(ImageSource.camera,
                                    //     metode: true);
                                  },
                                  icon: Icon(Icons.photo_camera),
                                ),
                                IconButton(
                                  iconSize: 50,
                                  color: Colors.black,
                                  onPressed: () {
                                    // data.pickImage(ImageSource.gallery,
                                    //     metode: true);
                                  },
                                  icon: Icon(Icons.image),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "You need to upload at least one image as part of the " +
                                  "registration process. Once you have completed the registration" +
                                  " you will be able to add more photos to your profile." +
                                  "\n\n Your profile image must not contain any nudity and be only of yourself.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: Global.font,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      primaryColor.withOpacity(.5),
                                      primaryColor.withOpacity(.8),
                                      primaryColor,
                                      primaryColor
                                    ],
                                  ),
                                ),
                                height:
                                    Get.height * .065,
                                width: Get.width * .75,
                                child: Center(
                                  child: Text(
                                    "CONTINUE",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: textColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              onTap: () async {
                                // print(userData);
                                // // Get.to(() => UploadImageScreen(userData));
                                // if (data.croppedFile == null) {
                                //   Get.snackbar("Information",
                                //       "You Must Choose Image First",
                                //       snackPosition: SnackPosition.TOP);
                                //   return;
                                // }
                                // await Get.find<LoginController>()
                                //     .setUserData(userData);
                                // await Get.find<LoginController>()
                                //     .updateFirstImageProfil(data.croppedFile);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
