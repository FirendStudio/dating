import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';
import 'package:hookup4u/presentation/dashboard/view/home/controllers/home.controller.dart';
import 'package:hookup4u/presentation/notif/controllers/notif.controller.dart';
import '../../../domain/core/interfaces/report/report_user.dart';
import '../../../domain/core/model/user_model.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';
import '../../../infrastructure/dal/util/general.dart';
import '../../../infrastructure/navigation/routes.dart';
import 'controllers/detail.controller.dart';

class DetailScreen extends GetView<DetailController> {
  const DetailScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(DetailController());
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
            color: Colors.white,
          ),
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 500,
                      width: MediaQuery.of(context).size.width,
                      child: Swiper(
                        key: UniqueKey(),
                        physics: ScrollPhysics(),
                        itemBuilder: (BuildContext context, int index2) {
                          return controller.user.imageUrl.isNotEmpty
                              ? Hero(
                                  tag: "abc",
                                  child: CachedNetworkImage(
                                    imageUrl: (controller.user.imageUrl[index2]
                                                .runtimeType ==
                                            String)
                                        ? controller.user.imageUrl[0]
                                        : controller.user.imageUrl[index2]
                                                ['url'] ??
                                            '',
                                    fit: BoxFit.cover,
                                    useOldImageOnUrlChange: true,
                                    placeholder: (context, url) =>
                                        CupertinoActivityIndicator(
                                      radius: 20,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                )
                              : Container();
                        },
                        itemCount: controller.user.imageUrl.length,
                        pagination: new SwiperPagination(
                          alignment: Alignment.bottomCenter,
                          builder: DotSwiperPaginationBuilder(
                            activeSize: 13,
                            color: secondryColor,
                            activeColor: primaryColor,
                          ),
                        ),
                        control: new SwiperControl(
                          color: primaryColor,
                          disableColor: secondryColor,
                        ),
                        loop: false,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: RichText(
                                text: TextSpan(
                                  text: controller.user.name,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                  children: [
                                    WidgetSpan(
                                      child: SizedBox(
                                        width: 6,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: ClipOval(
                                        child: Material(
                                          color: (controller.user.verified != 3)
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
                                                )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Column(
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          (!controller.cekpartner)
                                              ? "${controller.user.editInfo?['showMyAge'] != null ? !controller.user.editInfo!['showMyAge'] ? controller.user.age : "" : controller.user.age}" +
                                                  ", " +
                                                  controller.user.gender +
                                                  ", " +
                                                  controller
                                                      .user.sexualOrientation +
                                                  "\n" +
                                                  controller.user.status +
                                                  ", " +
                                                  "${controller.user.distanceBW ?? 0} KM away"
                                              : "${controller.user.editInfo?['showMyAge'] != null ? !controller.user.editInfo!['showMyAge'] ? controller.user.age : "" : controller.user.age}" +
                                                  ", " +
                                                  controller.user.gender +
                                                  ", " +
                                                  controller
                                                      .user.sexualOrientation +
                                                  ", " +
                                                  (controller.userPartner
                                                              ?.age ??
                                                          0)
                                                      .toString() +
                                                  ", " +
                                                  (controller.userPartner
                                                          ?.gender ??
                                                      "") +
                                                  ", " +
                                                  (controller.userPartner
                                                          ?.sexualOrientation ??
                                                      "") +
                                                  "\n\nCouple, " +
                                                  "${controller.user.distanceBW ?? 0} KM away",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (controller.user.countryName.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.pin_drop,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(controller.user.countryName)
                                      ],
                                    )
                                ],
                              ),
                              trailing: FloatingActionButton(
                                heroTag: UniqueKey(),
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  // Get.find<NotificationController>()
                                  //     .relationUserPartner = null;
                                  Get.back();
                                },
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            controller.user.editInfo?['job_title'] != null
                                ? ListTile(
                                    dense: true,
                                    leading:
                                        Icon(Icons.work, color: primaryColor),
                                    title: Text(
                                      "${controller.user.editInfo?['job_title']}${controller.user.editInfo?['company'] != null ? ' at ${controller.user.editInfo?['company']}' : ''}",
                                      style: TextStyle(
                                          color: secondryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                : Container(),
                            if (controller.user.editInfo?['about'] != null &&
                                controller.user.editInfo?['about'] != "")
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
                                subtitle: Text(
                                    controller.user.editInfo?['about'] ?? ""),
                              ),
                            controller.user.editInfo?['living_in'] != null
                                ? ListTile(
                                    dense: true,
                                    leading:
                                        Icon(Icons.home, color: primaryColor),
                                    title: Text(
                                      "Living in " +
                                          controller
                                              .user.editInfo?['living_in'],
                                      style: TextStyle(
                                          color: secondryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    )
                                    // .tr(args: ["${user.editInfo['living_in']}"]),
                                    )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (controller.desiresText.isNotEmpty)
                      ListTile(
                        dense: true,
                        title: Text(
                          "Desires",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(controller.desiresText),
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    if (controller.interestText.isNotEmpty)
                      ListTile(
                        dense: true,
                        title: Text(
                          "Interest",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(controller.interestText),
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    if (controller.user.relasi.value != null &&
                        (controller.user.relasi.value?.partner?.partnerId ?? "")
                            .isNotEmpty)
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
                    if (controller.user.relasi.value != null &&
                        (controller.user.relasi.value?.partner?.partnerId ?? "")
                            .isNotEmpty)
                      ListTile(
                        dense: true,
                        trailing: IconButton(
                          onPressed: () async {
                            Global().initProfilPartner(controller.user);
                          },
                          icon: Icon(
                            Icons.chevron_right_sharp,
                            size: 40,
                          ),
                        ),
                        title: Text(
                          controller.user.relasi.value?.partner?.partnerName ??
                              "",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          (controller.userPartner?.status ?? "") +
                              ", " +
                              (controller.userPartner?.sexualOrientation ?? ""),
                        ),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: secondryColor,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              25,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: controller.userPartner?.relasi.value
                                      ?.partner?.partnerImage ??
                                  "",
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
                    !controller.isMe
                        ? InkWell(
                            onTap: () => showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) => ReportUser(
                                currentUser: controller.currentUser,
                                seconduser: controller.user,
                              ),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Text(
                                  "REPORT ${controller.user.name}"
                                      .toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: secondryColor),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
              !controller.isMatched
                  ? Padding(
                      padding: const EdgeInsets.all(25.0),
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
                                color: Colors.red,
                                size: 30,
                              ),
                              onPressed: () async {
                                bool cek = Global().searchFirstUser(
                                  Get.find<HomeController>().checkedUser,
                                  controller.user.id,
                                );
                                if (!cek) {
                                  Global().showInfoDialog("User not Found");
                                  return;
                                }
                                // Get.back();
                                await Global().disloveFunction(controller.user);
                              },
                            ),
                            FloatingActionButton(
                              heroTag: UniqueKey(),
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.favorite,
                                color: Colors.lightBlueAccent,
                                size: 30,
                              ),
                              onPressed: () async {
                                bool cek = Global().searchFirstUser(
                                  Get.find<HomeController>().checkedUser,
                                  controller.user.id,
                                );
                                if (!cek) {
                                  Global().showInfoDialog("User not Found");
                                  return;
                                }
                                // Get.back();
                                await Global()
                                    .loveUserFunction(controller.user);
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : controller.isMe
                      ? Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                              heroTag: UniqueKey(),
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.edit,
                                color: primaryColor,
                              ),
                              onPressed: () {
                                Get.toNamed(Routes.PROFILE_EDIT);
                              },
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                              heroTag: UniqueKey(),
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.message,
                                color: primaryColor,
                              ),
                              onPressed: () async {
                                if (!globalController.isPurchased.value) {
                                  ArtDialogResponse? response =
                                      await ArtSweetAlert.show(
                                    barrierDismissible: false,
                                    context: Get.context!,
                                    artDialogArgs: ArtDialogArgs(
                                      denyButtonText: "Cancel",
                                      title: "Information",
                                      text:
                                          "Upgrade now to start chatting with this member!",
                                      confirmButtonText: "Subscribe Now",
                                      type: ArtSweetAlertType.warning,
                                    ),
                                  );

                                  if (response?.isTapConfirmButton == true) {
                                    Get.toNamed(Routes.PAYMENT_SUBCRIPTION);
                                    return;
                                  }
                                  return;
                                }
                                UserModel? userSecond = controller.user;
                                userSecond.relasi.value = await Global()
                                    .getRelationship(userSecond.id);
                                userSecond.distanceBW = Global()
                                    .calculateDistance(
                                      globalController.currentUser.value
                                              ?.coordinates?['latitude'] ??
                                          0,
                                      globalController.currentUser.value
                                              ?.coordinates?['longitude'] ??
                                          0,
                                      userSecond.coordinates?['latitude'] ?? 0,
                                      userSecond.coordinates?['longitude'] ?? 0,
                                    )
                                    .round();
                                Get.toNamed(Routes.NOTIF_VIEW_CHAT, arguments: {
                                  "chatId": Global().chatId(
                                    globalController.currentUser.value?.id ??
                                        "",
                                    userSecond.id,
                                  ),
                                  "userSecond": userSecond
                                });
                              },
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
