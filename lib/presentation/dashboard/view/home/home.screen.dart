import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/interfaces/loading.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import '../../../../domain/core/interfaces/report/report_user.dart';
import '../../../../domain/core/model/user_model.dart';
import '../../../../infrastructure/dal/util/color.dart';
import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Obx(
      (() {
        if (controller.isLoading.value) {
          return loadingWidget(Get.height, null);
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    height: Get.height,
                    width: Get.width,
                    child: controller.listUsers.length == 0
                        ? Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    backgroundColor: secondryColor,
                                    radius: 40,
                                  ),
                                ),
                                Text(
                                  "There's no one new around you.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: secondryColor,
                                    decoration: TextDecoration.none,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                            // ) : swiperWidget(),
                          )
                        : carouselWidget(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          FloatingActionButton(
                            heroTag: UniqueKey(),
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.clear,
                              color: primaryColor,
                              size: 30,
                            ),
                            onPressed: () async {
                              await Global().disloveFunction(controller
                                  .listUsers[controller.indexUser.value]);
                              controller.listUsers.remove(controller
                                  .listUsers[controller.indexUser.value]);
                              if (controller.listUsers.length ==
                                  controller.indexUser.value) {
                                controller.indexUser.value--;
                              }
                            },
                          ),
                          FloatingActionButton(
                            heroTag: UniqueKey(),
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.favorite,
                              color: primaryColor,
                              size: 30,
                            ),
                            onPressed: () async {
                              await Global().loveUserFunction(controller
                                  .listUsers[controller.indexUser.value]);
                              controller.listUsers.remove(controller
                                  .listUsers[controller.indexUser.value]);
                              // print("Data User index ke 1 : " +
                              //     controller.indexUser.value.toString());
                              // print(controller.listUsers.length);
                              // print(controller.listUsers.length ==
                              //     controller.indexUser.value);
                              if (controller.listUsers.length ==
                                  controller.indexUser.value) {
                                controller.indexUser.value--;
                                // print("Data User index ke 2 : " +
                                //     controller.indexUser.value.toString());
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }

  Widget carouselWidget() {
    return Obx(() {
      if (globalController.reviewModel.value?.status?.value == "suspend") {
        return Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: secondryColor,
                  radius: 40,
                ),
              ),
              Text(
                "Your account has been suspend",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondryColor,
                  decoration: TextDecoration.none,
                  fontSize: 18,
                ),
              )
            ],
          ),
          // ) : swiperWidget(),
        );
      }
      if (globalController.reviewModel.value?.status?.value == "review") {
        return Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: secondryColor,
                  radius: 40,
                ),
              ),
              Text(
                "Waiting for Admin Verification",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondryColor,
                  decoration: TextDecoration.none,
                  fontSize: 18,
                ),
              )
            ],
          ),
          // ) : swiperWidget(),
        );
      }
      return Material(
        elevation: 5,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: Get.height,
                child: listUserWidget(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget listUserWidget() {
    return Obx(() {
      return CarouselSlider(
        options: CarouselOptions(
          initialPage:
              controller.listUsers.isNotEmpty ? controller.indexUser.value : 0,
          height: Get.height,
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index, reason) async {
            print("Index User : " + index.toString());
            controller.addLastSwiped(controller.listUsers[index]);
            controller.listUsers[index] =
                await controller.initNextSwipe(controller.listUsers[index]);
            controller.indexImage.value = 0;
            controller.indexUser.value = index;
          },
        ),
        carouselController: controller.carouselUserController,
        items: controller.listUsers.map(
          (value) {
            return Obx(
              () {
                bool cekPartner = false;
                UserModel? userPartner;
                if (value.relasi.value?.partner != null &&
                    value.relasi.value!.partner!.partnerId.isNotEmpty) {
                  cekPartner = true;
                  userPartner = controller
                      .getUserSelected(value.relasi.value!.partner!.partnerId);
                  if (userPartner != null) {
                    print("Cek isRelationship : " + userPartner.name);
                  }
                }
                // if (kDebugMode) {
                //   print("Cek isRelationship : " + cekPartner.toString());
                //   print(controller.listUsers.length);
                //   print(value.desires.length);
                //   print("Jarak : " + value.distanceBW.toString());
                // }
                String desiresText = "";
                String interestText = "";
                if (value.desires.isNotEmpty) {
                  for (int index2 = 0;
                      index2 <= value.desires.length - 1;
                      index2++) {
                    if (desiresText.isEmpty) {
                      desiresText = Global().capitalize(value.desires[index2]);
                      print(desiresText);
                    } else {
                      desiresText +=
                          ", " + Global().capitalize(value.desires[index2]);
                    }
                  }
                }

                if (value.interest.isNotEmpty) {
                  for (int index2 = 0;
                      index2 <= value.interest.length - 1;
                      index2++) {
                    if (interestText.isEmpty) {
                      interestText =
                          Global().capitalize(value.interest[index2]);
                    } else {
                      interestText +=
                          ", " + Global().capitalize(value.interest[index2]);
                    }
                  }
                }
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: Get.height * 0.6,
                        child: listImageWidget(value),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: RichText(
                                text: TextSpan(
                                  text: value.name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: SizedBox(
                                        width: 6,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: ClipOval(
                                        child: Material(
                                          color: (value.verified != 3)
                                              ? Colors.grey[400]
                                              : Colors
                                                  .greenAccent, // Button color
                                          child: InkWell(
                                            splashColor:
                                                Colors.red, // Splash color
                                            onTap: () {},
                                            child: SizedBox(
                                              width: 23,
                                              height: 23,
                                              child: Icon(
                                                Icons.check,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 1,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: InkWell(
                                      splashColor: Colors.red, // Splash color
                                      onTap: () {
                                        showDialog(
                                          barrierDismissible: true,
                                          context: Get.context!,
                                          builder: (context) => ReportUser(
                                            currentUser:
                                                Get.find<GlobalController>()
                                                    .currentUser
                                                    .value!,
                                            seconduser: value,
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Icon(
                                          Icons.flag,
                                          size: 40,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    (!cekPartner)
                                        ? "${value.editInfo?['showMyAge'] != null ? !value.editInfo!['showMyAge'] ? value.age : "" : value.age}" +
                                            ", " +
                                            value.gender +
                                            ", " +
                                            value.sexualOrientation +
                                            "\n" +
                                            value.status +
                                            ", " +
                                            "${value.distanceBW} KM away"
                                        : "${value.editInfo?['showMyAge'] != null ? !value.editInfo!['showMyAge'] ? value.age : "" : value.age}" +
                                            ", " +
                                            value.gender +
                                            ", " +
                                            value.sexualOrientation +
                                            ", " +
                                            (userPartner?.age ?? "")
                                                .toString() +
                                            ", " +
                                            (userPartner?.gender ?? "") +
                                            ", " +
                                            (userPartner?.sexualOrientation ??
                                                "") +
                                            "\n\nCouple, " +
                                            "${value.distanceBW} KM away",
                                    style: TextStyle(
                                        // color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal),
                                    // + "${data.selectedUser.address}"
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (value.countryName.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.pin_drop,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(value.countryName)
                                ],
                              ),
                          ],
                        ),
                      ),
                      value.editInfo?['job_title'] != null
                          ? ListTile(
                              dense: true,
                              leading: Icon(Icons.work, color: primaryColor),
                              title: Text(
                                "${value.editInfo?['job_title']}${value.editInfo?['company'] != null ? ' at ${value.editInfo?['company']}' : ''}",
                                style: TextStyle(
                                    color: secondryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          : Container(),
                      if (value.editInfo?['about'] != null &&
                          value.editInfo?['about'] != "")
                        ListTile(
                          dense: true,
                          // leading: Icon(Icons.book, color: primaryColor),
                          title: Text(
                            "About Me",
                            style: TextStyle(
                                color: secondryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(value.editInfo?['about'] ?? ""),
                        ),

                      value.editInfo?['living_in'] != null
                          ? ListTile(
                              dense: true,
                              leading: Icon(Icons.home, color: primaryColor),
                              title: Text(
                                "Living in " + value.editInfo?['living_in'],
                                style: TextStyle(
                                    color: secondryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              )
                              // .tr(args: ["${data.selectedUser.editInfo['living_in']}"]),
                              )
                          : Container(),
                      // !isMe
                      //     ? ListTile(
                      //         dense: true,
                      //         leading: Icon(
                      //           Icons.location_on,
                      //           color: primaryColor,
                      //         ),
                      //         title: Text(
                      //           "${data.selectedUser.editInfo['DistanceVisible'] != null ? data.selectedUser.editInfo['DistanceVisible'] ? 'Less than ${data.selectedUser.distanceBW} KM away' : 'Distance not visible' : 'Less than ${data.selectedUser.distanceBW} KM away'}",
                      //           style: TextStyle(
                      //               color: secondryColor,
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.w500),
                      //         ),
                      //       )
                      //     : Container(),

                      SizedBox(
                        height: 10,
                      ),

                      if (desiresText.isNotEmpty)
                        ListTile(
                          dense: true,
                          title: Text(
                            "Desires",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(desiresText),
                        ),

                      SizedBox(
                        height: 10,
                      ),

                      if (interestText.isNotEmpty)
                        ListTile(
                          dense: true,
                          title: Text(
                            "Interest",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(interestText),
                        ),

                      SizedBox(
                        height: 10,
                      ),

                      if (value.relasi.value != null &&
                          value.relasi.value!.partner!.partnerId.isNotEmpty)
                        ListTile(
                          dense: true,
                          title: Text(
                            "Partner",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (cekPartner)
                        ListTile(
                          dense: true,
                          trailing: IconButton(
                            onPressed: () async {
                              Global().initProfilPartner(value);
                            },
                            icon: Icon(
                              Icons.chevron_right_sharp,
                              size: 40,
                            ),
                          ),
                          title: Text(
                            value.relasi.value!.partner!.partnerName,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(userPartner!.status +
                              ", " +
                              userPartner.sexualOrientation),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: secondryColor,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                25,
                              ),
                              child: CachedNetworkImage(
                                imageUrl:
                                    value.relasi.value!.partner!.partnerImage,
                                fit: BoxFit.cover,
                                useOldImageOnUrlChange: true,
                                placeholder: (context, url) =>
                                    CupertinoActivityIndicator(
                                  radius: 20,
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),

                      SizedBox(
                        height: 10,
                      ),

                      Divider(),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ).toList(),
      );
    });
  }

  Widget listImageWidget(UserModel userModel) {
    return ClipRRect(
      child: (userModel.imageUrl.length == 1)
          ? Stack(
              children: [
                Container(
                  height: Get.height * .78,
                  width: Get.width,
                  child: CachedNetworkImage(
                    imageUrl: userModel.imageUrl[0]['url'] ?? "",
                    fit: BoxFit.cover,
                    useOldImageOnUrlChange: true,
                    placeholder: (context, url) =>
                        loadingWidget(Get.height * .78, null),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: Get.height,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index, reason) {
                      controller.indexImage.value = index;
                    },
                  ),
                  carouselController: controller.carouselImageController,
                  items: userModel.imageUrl.map((value) {
                    return Stack(
                      children: [
                        Container(
                          height: Get.height * .78,
                          width: Get.width,
                          child: CachedNetworkImage(
                            imageUrl: value['url'] ?? "",
                            fit: BoxFit.cover,
                            useOldImageOnUrlChange: true,
                            placeholder: (context, url) =>
                                loadingWidget(Get.height * .78, null),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                if (userModel.imageUrl.length > 1)
                  Positioned(
                    top: Get.height * 0.30,
                    right: 15,
                    child: Container(
                      padding:
                          EdgeInsets.only(top: 4, bottom: 4, right: 4, left: 4),
                      decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: userModel.imageUrl.asMap().entries.map(
                          (entry) {
                            // print(
                            //     "index entry : " + controller.indexImage.value.toString());
                            return Obx(
                              (() => GestureDetector(
                                    onTap: () => controller
                                        .carouselImageController
                                        .animateToPage(entry.key),
                                    child: Container(
                                      width: 4.0,
                                      height: 4.0,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (controller.indexImage.value ==
                                                entry.key)
                                            ? Colors.white
                                            : Colors.white38,
                                      ),
                                    ),
                                  )),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}