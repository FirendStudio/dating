import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/NotificationController.dart';
import 'package:hookup4u/Screens/Chat/Matches.dart';
import 'package:hookup4u/Screens/Info/InformationPartner.dart';
import 'package:hookup4u/Screens/Profile/EditProfile.dart';
import 'package:hookup4u/Screens/reportUser.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:swipe_stack/swipe_stack.dart';
// import 'package:easy_localization/easy_localization.dart';

import '../../Controller/ChatController.dart';
import '../../Controller/TabsController.dart';
import '../../models/Relationship.dart';
import '../Chat/chatPage.dart';
import '../Payment/subscriptions.dart';

class Info extends StatelessWidget {
  final UserModel currentUser;
  final UserModel user;
  final String type;

  final GlobalKey<SwipeStackState> swipeKey;
  Info(
    this.user,
    this.currentUser,
    this.swipeKey,
    this.type,
  );

  TabsController tabsController = Get.put(TabsController());
  NotificationController notificationController = Get.put(NotificationController());
  bool cekpartner = false;

  @override
  Widget build(BuildContext context) {
    bool isMe = user.id == currentUser.id;
    bool isMatched = swipeKey == null;
    //matches.any((value) => value.id == user.id);
    if(Get.find<NotificationController>().relationUserPartner != null && Get.find<NotificationController>().relationUserPartner.partner.partnerId.isNotEmpty){
      cekpartner = true;
    }


    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            color: Colors.white),
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
                        return user.imageUrl.length != null
                            ? Hero(
                                tag: "abc",
                                child: CachedNetworkImage(
                                  imageUrl: (user.imageUrl[index2].runtimeType == String)?user.imageUrl[0] : user.imageUrl[index2]['url'] ?? '',
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
                      itemCount: user.imageUrl.length,
                      pagination: new SwiperPagination(
                          alignment: Alignment.bottomCenter,
                          builder: DotSwiperPaginationBuilder(
                              activeSize: 13,
                              color: secondryColor,
                              activeColor: primaryColor)),
                      control: new SwiperControl(
                        color: primaryColor,
                        disableColor: secondryColor,
                      ),
                      loop: false,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              "${user.name}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              (!cekpartner)
                              ?"${user.editInfo['showMyAge'] != null ? !user.editInfo['showMyAge'] ? user.age : "" : user.age}" +
                                  ", " + user.gender + ", " + user.sexualOrientation + "\n" + user.status + ", " + "${user.distanceBW ?? 0} KM away"

                              : "${user.editInfo['showMyAge'] != null ? !user.editInfo['showMyAge'] ? user.age : "" : user.age}" +
                                  ", " + user.gender + ", " + user.sexualOrientation + ", " +
                                  notificationController.userPartner.age.toString() + ", " + notificationController.userPartner.gender + ", " +  notificationController.userPartner.sexualOrientation
                                  + "\n\nCouple, " + "${user.distanceBW ?? 0} KM away",
                              style: TextStyle(
                                // color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.normal
                              ),
                                    // + "${user.address}"
                            ),
                            trailing: FloatingActionButton(
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  Get.find<NotificationController>().relationUserPartner = null;
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: primaryColor,
                                )),
                          ),
                          user.editInfo['job_title'] != null
                              ? ListTile(
                                  dense: true,
                                  leading: Icon(Icons.work, color: primaryColor),
                                  title: Text(
                                    "${user.editInfo['job_title']}${user.editInfo['company'] != null ? ' at ${user.editInfo['company']}' : ''}",
                                    style: TextStyle(
                                        color: secondryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              : Container(),
                          if(user.editInfo['about'] != null && user.editInfo['about'] != "")
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
                              subtitle: Text(user.editInfo['about'] ?? ""),
                            ),

                          user.editInfo['living_in'] != null
                              ? ListTile(
                                  dense: true,
                                  leading:
                                      Icon(Icons.home, color: primaryColor),
                                  title: Text(
                                    "Living in " + user.editInfo['living_in'],
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

                  if(notificationController.desiresText.isNotEmpty)
                    ListTile(
                      dense: true,
                      title: Text(
                        "Desires",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(notificationController.desiresText),
                    ),

                  SizedBox(
                    height: 10,
                  ),

                  if(notificationController.interestText.isNotEmpty)
                    ListTile(
                      dense: true,
                      title: Text(
                        "Interest",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(notificationController.interestText),
                    ),

                  SizedBox(
                    height: 10,
                  ),

                  if(Get.find<NotificationController>().relationUserPartner != null && Get.find<NotificationController>().relationUserPartner.partner.partnerId.isNotEmpty)
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
                  if(Get.find<NotificationController>().relationUserPartner != null && Get.find<NotificationController>().relationUserPartner.partner.partnerId.isNotEmpty)
                    ListTile(
                      dense: true,
                      trailing: IconButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Center(
                                    child:
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                          Colors.white),
                                    ));
                              });
                          var data = await FirebaseFirestore.instance.collection("Relationship").doc(notificationController.userPartner.id).get();
                          if(!data.exists){
                            await Get.find<NotificationController>().setNewRelationship(notificationController.userPartner.id);
                            data = await FirebaseFirestore.instance.collection("Relationship").doc(notificationController.userPartner.id).get();
                          }
                          Relationship relationshipTemp = Relationship.fromDocument(data.data());
                          Get.back();
                          notificationController.userPartner.distanceBW = Get.find<TabsController>().calculateDistance(
                              currentUser.coordinates['latitude'],
                              currentUser.coordinates['longitude'],
                              notificationController.userPartner.coordinates['latitude'],
                              notificationController.userPartner.coordinates['longitude']).round();
                          await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {

                            return InformationPartner(
                                notificationController.userPartner,
                                currentUser,
                                null,
                                relationshipTemp,
                                user,""
                            );
                          });

                        },
                        icon: Icon(Icons.chevron_right_sharp,
                          size: 40,
                        ),
                      ),
                      title: Text(
                        Get.find<NotificationController>().relationUserPartner.partner.partnerName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(Get.find<NotificationController>().userPartner.status + ", "
                          + Get.find<NotificationController>().userPartner.sexualOrientation
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: secondryColor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            25,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: Get.find<NotificationController>().relationUserPartner.partner.partnerImage,
                            fit: BoxFit.cover,
                            useOldImageOnUrlChange: true,
                            placeholder: (context, url) => CupertinoActivityIndicator(
                              radius: 20,
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(
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
                  !isMe ?
                  InkWell(
                          onTap: () => showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) => ReportUser(
                                    currentUser: currentUser,
                                    seconduser: user,
                                  )),
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Text(
                                  "REPORT ${user.name}".toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: secondryColor),
                                ),
                              )),
                        )
                      : Container(),
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
            !isMatched
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
                              onPressed: () {

                                Navigator.pop(context);
                                swipeKey.currentState.swipeLeft();
                              }),
                          FloatingActionButton(
                              heroTag: UniqueKey(),
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.favorite,
                                color: Colors.lightBlueAccent,
                                size: 30,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                swipeKey.currentState.swipeRight();
                              }),
                        ],
                      ),
                    ),
                  )
                : isMe
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
                                onPressed: () => Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            EditProfile(user))))),
                      )
                    : Padding(
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
                                  if(!Get.find<TabsController>().isPuchased){
                                    ArtDialogResponse response = await ArtSweetAlert.show(
                                        barrierDismissible: false,
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            denyButtonText: "Cancel",
                                            title: "Information",
                                            text: "Upgrade now to start chatting with this member!",
                                            confirmButtonText: "Subscribe Now",
                                            type: ArtSweetAlertType.warning
                                        )
                                    );

                                    if(response==null) {
                                      return;
                                    }

                                    if(response.isTapDenyButton) {
                                      return;
                                    }
                                    if(response.isTapConfirmButton){
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => Subscription(
                                                Get.find<TabsController>().currentUser, null, Get.find<TabsController>().items)),
                                      );
                                    }

                                  }else{
                                    await Get.find<ChatController>().initChatScreen(chatId(user, currentUser));
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => ChatPage(
                                              sender: currentUser,
                                              second: user,
                                              chatId: chatId(user, currentUser),
                                            )));
                                  }

                                }
                            )),
                      )
          ],
        ),
      ),
    );
  }
}
