import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';

import '../../domain/core/interfaces/custom.dart';
import '../../domain/core/interfaces/loading.dart';
import '../../infrastructure/dal/util/color.dart';
import '../../infrastructure/dal/util/general.dart';
import 'controllers/profile.controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Get.put(ProfileController());
    return Obx(
      () => Scaffold(
        backgroundColor: primaryColor,
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Hero(
                  tag: "abc",
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: secondryColor,
                      child: Material(
                        color: Colors.white,
                        child: Stack(
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                Global().initProfil(
                                  Get.find<GlobalController>()
                                      .currentUser
                                      .value!,
                                );
                              },
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    80,
                                  ),
                                  child: CachedNetworkImage(
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.fill,
                                    imageUrl: (Get.find<GlobalController>()
                                                    .currentUser
                                                    .value
                                                    ?.imageUrl ??
                                                [])
                                            .isNotEmpty
                                        ? Get.find<GlobalController>()
                                                    .currentUser
                                                    .value
                                                    ?.imageUrl[0]
                                                    .runtimeType ==
                                                String
                                            ? Get.find<GlobalController>()
                                                .currentUser
                                                .value
                                                ?.imageUrl[0]
                                            : Get.find<GlobalController>()
                                                    .currentUser
                                                    .value
                                                    ?.imageUrl[0]['url'] ??
                                                ''
                                        : '',
                                    useOldImageOnUrlChange: true,
                                    placeholder: (context, url) =>
                                        loadingWidget(
                                      150,
                                      null,
                                      isloadingText: true,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.error,
                                          color: Colors.black,
                                          size: 30,
                                        ),
                                        Text(
                                          "Enable to load",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                color: primaryColor,
                                child: IconButton(
                                  alignment: Alignment.center,
                                  icon: Icon(
                                    Icons.photo_camera,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (globalController
                                            .reviewModel.value?.status?.value ==
                                        "suspend") {
                                      Global().showInfoDialog(
                                          "Please change your profile picture in setting");
                                      return;
                                    }
                                    if (globalController
                                            .reviewModel.value?.status?.value ==
                                        "review") {
                                      Global().showInfoDialog(
                                          "Your Profile need reviewed by admin first");
                                      return;
                                    }
                                    controller.source(
                                      context,
                                      Get.find<GlobalController>()
                                          .currentUser
                                          .value!,
                                      true,
                                      "true",
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  Get.find<GlobalController>().currentUser.value?.name !=
                              null &&
                          Get.find<GlobalController>().currentUser.value?.age !=
                              null
                      ? "${Get.find<GlobalController>().currentUser.value?.name}, ${Get.find<GlobalController>().currentUser.value?.age}"
                      : "",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .45,
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 70,
                                width: 70,
                                child: FloatingActionButton(
                                  heroTag: UniqueKey(),
                                  splashColor: secondryColor,
                                  backgroundColor: primaryColor,
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: Color.fromARGB(255, 112, 55, 55),
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    if (globalController
                                            .reviewModel.value?.status?.value ==
                                        "suspend") {
                                      Global().showInfoDialog(
                                          "Please change your profile picture in setting area");
                                      return;
                                    }
                                    if (globalController
                                            .reviewModel.value?.status?.value ==
                                        "review") {
                                      Global().showInfoDialog(
                                          "Your Profile need reviewed by admin first");
                                      return;
                                    }
                                    controller.source(
                                      context,
                                      Get.find<GlobalController>()
                                          .currentUser
                                          .value!,
                                      false,
                                      "true",
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Add media",
                                  style: TextStyle(color: secondryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30, top: 30),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: <Widget>[
                              FloatingActionButton(
                                  splashColor: secondryColor,
                                  heroTag: UniqueKey(),
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.settings,
                                    color: secondryColor,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    Get.toNamed(Routes.SETTINGS);
                                  }),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Settings",
                                  style: TextStyle(color: secondryColor),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 30, top: 30),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            children: <Widget>[
                              FloatingActionButton(
                                heroTag: UniqueKey(),
                                splashColor: secondryColor,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.edit,
                                  color: secondryColor,
                                  size: 28,
                                ),
                                onPressed: () {
                                  Get.toNamed(Routes.PROFILE_EDIT);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Edit Info",
                                  style: TextStyle(color: secondryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 210),
                        child: Container(
                          height: 120,
                          child: CustomPaint(
                            painter: CurvePainter(),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            height: 100,
                            width: MediaQuery.of(context).size.width * .85,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Swiper(
                                key: UniqueKey(),
                                curve: Curves.linear,
                                autoplay: true,
                                physics: ScrollPhysics(),
                                itemBuilder:
                                    (BuildContext context, int index2) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          // Icon(
                                          //   adds[index2]["icon"],
                                          //   color: adds[index2]["color"],
                                          // ),
                                          // SizedBox(
                                          //   width: 5,
                                          // ),
                                          Text(
                                            listAdds[index2]["title"],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        listAdds[index2]["subtitle"],
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  );
                                },
                                itemCount: listAdds.length,
                                pagination: new SwiperPagination(
                                  alignment: Alignment.bottomCenter,
                                  builder: DotSwiperPaginationBuilder(
                                    activeSize: 10,
                                    color: secondryColor,
                                    activeColor: primaryColor,
                                  ),
                                ),
                                control: new SwiperControl(
                                  size: 20,
                                  color: primaryColor,
                                  disableColor: secondryColor,
                                ),
                                loop: false,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                          Get.find<GlobalController>().isPurchased.value
                              ? "Check Payment Details"
                              : "Subscribe Plan",
                          style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (globalController.isPurchased.value) {
                        Get.toNamed(Routes.PAYMENT_DETAILS);
                      } else {
                        Get.toNamed(Routes.PAYMENT_SUBCRIPTION);
                      }
                    },
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
