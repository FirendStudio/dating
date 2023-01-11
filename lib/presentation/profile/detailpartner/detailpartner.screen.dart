import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import 'package:get/get.dart';
// import 'package:flutter_swiper/flutter_swiper.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';
import 'controllers/detailpartner.controller.dart';

class DetailPartnerScreen extends GetView<DetailPartnerController> {
  const DetailPartnerScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(DetailPartnerController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            color: Colors.white),
        child: Stack(
          children: <Widget>[
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
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: () async {
                          await Global()
                              .disloveFunction(controller.userPartner);
                          // Get.back();
                        }),
                    if (!controller.isMe)
                      InkWell(
                        splashColor: Colors.red, // Splash color
                        onTap: () {
                          // TODO
                          // showDialog(
                          //   barrierDismissible: true,
                          //   context: context,
                          //   builder: (context) => ReportUser(
                          //   currentUser: currentUser,
                          //   seconduser: user,
                          // ),
                          // );
                        },
                        child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.flag,
                              size: 40,
                              color: Colors.red,
                            )),
                      ),
                    FloatingActionButton(
                        heroTag: UniqueKey(),
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: () async {
                          await Global()
                              .loveUserFunction(controller.userPartner);
                          // Get.back();
                        }),
                  ],
                ),
              ),
            ),
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
                        return controller.userPartner.imageUrl.isNotEmpty
                            ? Hero(
                                tag: "abc",
                                child: CachedNetworkImage(
                                  imageUrl: (controller.userPartner
                                              .imageUrl[index2].runtimeType ==
                                          String)
                                      ? controller.userPartner.imageUrl[0]
                                      : controller.userPartner.imageUrl[index2]
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
                      itemCount: controller.userPartner.imageUrl.length,
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
                                    text: controller.userPartner.name,
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
                                          color: (controller
                                                      .userPartner.verified !=
                                                  3)
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
                                      )),
                                    ]),
                              ),
                              subtitle: Column(
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                          child: Text(
                                        (!controller.cekpartner)
                                            ? "${controller.userPartner.editInfo?['showMyAge'] != null ? !controller.userPartner.editInfo!['showMyAge'] ? controller.userPartner.age : "" : controller.userPartner.age}" +
                                                ", " +
                                                controller.userPartner.gender +
                                                ", " +
                                                controller.userPartner
                                                    .sexualOrientation +
                                                "\n " +
                                                controller.userPartner.status +
                                                ", " +
                                                "${controller.userPartner.distanceBW} KM away"
                                            : "${controller.userPartner.editInfo?['showMyAge'] != null ? !controller.userPartner.editInfo!['showMyAge'] ? controller.userPartner.age : "" : controller.userPartner.age}" +
                                                ", " +
                                                controller.userPartner.gender +
                                                ", " +
                                                controller.userPartner
                                                    .sexualOrientation +
                                                ", " +
                                                controller.user.age.toString() +
                                                ", " +
                                                controller.user.gender +
                                                ", " +
                                                controller
                                                    .user.sexualOrientation +
                                                "\n\nCouple, " +
                                                "${controller.userPartner.distanceBW} KM away",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal),
                                      )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (controller
                                      .userPartner.countryName.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.pin_drop,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(controller.userPartner.countryName)
                                      ],
                                    ),
                                ],
                              ),
                              trailing: Column(
                                children: [
                                  FloatingActionButton(
                                      backgroundColor: Colors.white,
                                      onPressed: () {
                                        // Get.find<NotificationController>().relationUserPartner = null;
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.arrow_downward,
                                        color: primaryColor,
                                      )),
                                ],
                              )),
                          controller.userPartner.editInfo?['job_title'] != null
                              ? ListTile(
                                  dense: true,
                                  leading:
                                      Icon(Icons.work, color: primaryColor),
                                  title: Text(
                                    "${controller.userPartner.editInfo?['job_title']}${controller.userPartner.editInfo?['company'] != null ? ' at ${controller.userPartner.editInfo?['company']}' : ''}",
                                    style: TextStyle(
                                        color: secondryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              : Container(),
                          if (controller.userPartner.editInfo?['about'] !=
                                  null &&
                              controller.userPartner.editInfo?['about'] != "")
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
                                  controller.userPartner.editInfo?['about'] ??
                                      ""),
                            ),

                          controller.userPartner.editInfo?['living_in'] != null
                              ? ListTile(
                                  dense: true,
                                  leading:
                                      Icon(Icons.home, color: primaryColor),
                                  title: Text(
                                    "Living in " +
                                        controller
                                            .userPartner.editInfo?['living_in'],
                                    style: TextStyle(
                                        color: secondryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  )
                                  // .tr(args: ["${user.editInfo['living_in']}"]),
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
                          //           "${user.editInfo['DistanceVisible'] != null ? user.editInfo['DistanceVisible'] ? 'Less than ${user.distanceBW} KM away' : 'Distance not visible' : 'Less than ${user.distanceBW} KM away'}",
                          //           style: TextStyle(
                          //               color: secondryColor,
                          //               fontSize: 16,
                          //               fontWeight: FontWeight.w500),
                          //         ),
                          //       )
                          //     : Container(),
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

                  if (controller
                      .userPartner.relasi.value!.partner!.partnerId.isNotEmpty)
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
                  if (controller
                      .userPartner.relasi.value!.partner!.partnerId.isNotEmpty)
                    ListTile(
                      dense: true,
                      trailing: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.chevron_right_sharp,
                          size: 40,
                        ),
                      ),
                      title: Text(
                        controller
                            .userPartner.relasi.value!.partner!.partnerName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        controller.user.status +
                            ", " +
                            controller.user.sexualOrientation,
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: secondryColor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            25,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: controller.userPartner.relasi.value!
                                .partner!.partnerImage,
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
                  // !isMe ?
                  // InkWell(
                  //   onTap: () => showDialog(
                  //       barrierDismissible: true,
                  //       context: context,
                  //       builder: (context) => ReportUser(
                  //         currentUser: currentUser,
                  //         seconduser: user,
                  //       )),
                  //   child: Container(
                  //       width: MediaQuery.of(context).size.width,
                  //       child: Center(
                  //         child: Text(
                  //           "REPORT ${user.name}".toUpperCase(),
                  //           textAlign: TextAlign.center,
                  //           style: TextStyle(
                  //               fontSize: 18,
                  //               fontWeight: FontWeight.w600,
                  //               color: secondryColor),
                  //         ),
                  //       )),
                  // )
                  //     : Container(),
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
            controller.isMe
                ? Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.edit,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          //  Navigator.pushReplacement(
                          //   context,
                          //   CupertinoPageRoute(
                          //       builder: (context) => EditProfile(user)))
                        },
                      ),
                    ),
                  )
                : (controller.type != 'like')
                    ? Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.message,
                              color: primaryColor,
                            ),
                            onPressed: () async {
                              // var data = await FirebaseFirestore.instance
                              //     .collection("Relationship")
                              //     .doc(user.id)
                              //     .get();

                              // if (!data.exists) {
                              //   await Get.find<NotificationController>()
                              //       .setNewRelationship(user.id);
                              //   data = await FirebaseFirestore.instance
                              //       .collection("Relationship")
                              //       .doc(user.id)
                              //       .get();
                              // }
                              // Relationship relationshipTemp =
                              //     Relationship.fromDocument(data.data());
                              // if (relationshipTemp.pendingAcc[0].reqUid ==
                              //     Get.find<TabsController>()
                              //         .currentUser
                              //         .id) {
                              //   Get.back();
                              //   // return;
                              // } else {
                              //   if (!Get.find<TabsController>()
                              //       .isPuchased) {
                              //     ArtDialogResponse response =
                              //         await ArtSweetAlert.show(
                              //             barrierDismissible: false,
                              //             context: context,
                              //             artDialogArgs: ArtDialogArgs(
                              //                 denyButtonText: "Cancel",
                              //                 title: "Information",
                              //                 text:
                              //                     "Upgrade now to start chatting with this member!",
                              //                 confirmButtonText:
                              //                     "Subscribe Now",
                              //                 type: ArtSweetAlertType
                              //                     .warning));

                              //     if (response == null) {
                              //       return;
                              //     }

                              //     if (response.isTapDenyButton) {
                              //       return;
                              //     }
                              //     if (response.isTapConfirmButton) {
                              //       Navigator.push(
                              //         context,
                              //         CupertinoPageRoute(
                              //             builder: (context) =>
                              //                 Subscription(
                              //                     Get.find<TabsController>()
                              //                         .currentUser,
                              //                     null,
                              //                     Get.find<TabsController>()
                              //                         .items)),
                              //       );
                              //     }
                              //   } else {
                              //     await Get.find<ChatController>()
                              //         .initChatScreen(
                              //             chatId(user, currentUser));
                              //     Navigator.push(
                              //         context,
                              //         CupertinoPageRoute(
                              //             builder: (context) => ChatPage(
                              //                   sender: currentUser,
                              //                   second: user,
                              //                   chatId: chatId(
                              //                       user, currentUser),
                              //                 )));
                              //   }
                              // }
                            },
                          ),
                        ),
                      )
                    : Container()
          ],
        ),
      ),
    );
  }
}
