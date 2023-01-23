import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/CustomTapModel.dart';
import 'package:hookup4u/presentation/auth/register/controllers/auth_register.controller.dart';
import '../../../../infrastructure/dal/util/Global.dart';
import '../../../../infrastructure/dal/util/color.dart';
import '../../../../infrastructure/dal/util/general.dart';

class SexualOrientationWidget extends GetView<AuthRegisterController> {
  const SexualOrientationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => controller.onBack(),
      child: Scaffold(
        // key: _scaffoldKey,
        backgroundColor: Colors.white,
        floatingActionButton: AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 50),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: FloatingActionButton(
              elevation: 10,
              child: IconButton(
                color: secondryColor,
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => controller.onBack(),
              ),
              backgroundColor: Colors.white38,
              onPressed: () => controller.onBack(),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: Container(
          height: MediaQuery.of(context).size.height,
          // padding: EdgeInsets.only(
          //   left: Get.width * 0.1,
          //   right: Get.width * 0.1,
          // ),
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Center(
                    child: Text(
                      "My sexual orientation is",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: Global.font,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(
                      left: Get.width * 0.1, right: Get.width * 0.1, top: 100),
                ),
                SizedBox(
                  height: Get.height * 0.7,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: Get.width * 0.1,
                        right: Get.width * 0.1,
                        top: 0,
                        bottom: 50),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: orientationlist.length,
                      itemBuilder: (BuildContext context, index) {
                        CustomTapModel content = orientationlist[index];

                        return Obx(
                          () => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                side: BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: controller.selectedSexual.value?.name
                                              .value ==
                                          content.name.value
                                      ? primaryColor
                                      : secondryColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Container(
                                height: Get.height * .055,
                                child: Center(
                                  child: Text(
                                    "${content.name}".toUpperCase(),
                                    style: TextStyle(
                                      color: controller.selectedSexual.value
                                                  ?.name.value ==
                                              content.name.value
                                          ? primaryColor
                                          : secondryColor,
                                      fontSize: 18,
                                      fontFamily: Global.font,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                controller.selectedSexual.value = content;
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: Get.width * 0.05,
                    right: Get.width * 0.05,
                  ),
                  child: Column(
                    children: <Widget>[
                      Obx(() {
                        return controller.selectedSexual.value != null
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 40),
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
                                        child: Text(
                                          "CONTINUE",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: textColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      controller.indexView++;
                                    },
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      height: Get.height * .065,
                                      width: Get.width * .75,
                                      child: Center(
                                        child: Text(
                                          "CONTINUE",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: secondryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Global().showInfoDialog(
                                        "Please select one",
                                      );
                                    },
                                  ),
                                ),
                              );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
