import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/presentation/auth/register/view/allowlocation_widget.dart';
import 'package:hookup4u/presentation/auth/register/view/desire_widget.dart';
import 'package:hookup4u/presentation/auth/register/view/gender_widget.dart';
import 'package:hookup4u/presentation/auth/register/view/sexualorientation_widget.dart';
import 'package:hookup4u/presentation/auth/register/view/showme_widget.dart';
import 'package:hookup4u/presentation/auth/register/view/status_widget.dart';
import 'package:hookup4u/presentation/auth/register/view/uploadimage_widget.dart';
import 'package:hookup4u/presentation/auth/register/view/userdob_widget.dart';
import 'package:hookup4u/presentation/auth/register/view/username_widget.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';
import 'controllers/auth_register.controller.dart';

class AuthRegisterScreen extends GetView<AuthRegisterController> {
  const AuthRegisterScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.indexView.value == 0) {
          return body();
        }
        if (controller.indexView.value == 1) {
          return UsernameWidget();
        }
        if (controller.indexView.value == 2) {
          return UserDOBWidget();
        }
        if (controller.indexView.value == 3) {
          return GenderWidget();
        }
        if (controller.indexView.value == 4) {
          return SexualOrientationWidget();
        }
        if (controller.indexView.value == 5) {
          return DesireWidget();
        }
        if (controller.indexView.value == 6) {
          return StatusWidget();
        }
        if (controller.indexView.value == 7) {
          return ShowMeWidget();
        }
        if (controller.indexView.value == 8) {
          return AllowLocationWidget();
        }
        if (controller.indexView.value == 9) {
          return UploadImageWidget();
        }
        return body();
      },
    );
  }

  Widget body() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Container(
                height: Get.height * 0.83,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Image.asset(
                          "asset/images/logo1.png",
                          // height: Get.height * 0.1,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8),
                        title: AutoSizeText(
                          "This is a community for unvaccinated singles looking to meet like-minded people for love, fun and friendship.",
                          style: TextStyle(
                              fontSize: Get.height * 0.03,
                              fontFamily: Global.font,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8),
                        title: AutoSizeText(
                          "Be yourself.",
                          style: TextStyle(
                              fontSize: Get.height * 0.027,
                              fontFamily: Global.font,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: AutoSizeText(
                          "Please make sure that your photos, age and bio are accurate and a true representation of who you are.",
                          style: TextStyle(
                            fontSize: Get.height * 0.025,
                            fontFamily: Global.font,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8),
                        title: AutoSizeText(
                          "Play it cool.",
                          style: TextStyle(
                              fontSize: Get.height * 0.027,
                              fontFamily: Global.font,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: AutoSizeText(
                          "Respect others and treat them as you would like to be treated.",
                          style: TextStyle(
                            fontSize: Get.height * 0.025,
                            fontFamily: Global.font,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8),
                        title: AutoSizeText(
                          "Stay safe.",
                          style: TextStyle(
                              fontSize: Get.height * 0.027,
                              fontFamily: Global.font,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: AutoSizeText(
                          "Don't be too quick to give out personal information.",
                          style: TextStyle(
                            fontSize: Get.height * 0.025,
                            fontFamily: Global.font,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8),
                        title: AutoSizeText(
                          "Be proactive.",
                          style: TextStyle(
                            fontSize: Get.height * 0.027,
                            fontWeight: FontWeight.bold,
                            fontFamily: Global.font,
                          ),
                        ),
                        subtitle: AutoSizeText(
                          "Always report bad behavior.",
                          style: TextStyle(
                            fontSize: Get.height * 0.025,
                            fontFamily: Global.font,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 50),
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
                    height: Get.height * .065,
                    width: Get.width * .75,
                    child: Center(
                      child: AutoSizeText(
                        "GOT IT",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: Global.font,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  onTap: () async {
                    // User user = FirebaseAuth.instance.currentUser!;
                    if (controller.checkDisplayName()) {
                      // controller.dataUser
                      //     .addAll({'UserName': "${user.displayName}"});
                      controller.indexView.value = 2;
                      return;
                    }
                    controller.indexView.value++;
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
