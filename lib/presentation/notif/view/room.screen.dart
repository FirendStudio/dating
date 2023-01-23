import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/user_model.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:hookup4u/presentation/notif/controllers/notif.controller.dart';
import 'package:intl/intl.dart';

import '../../../domain/core/interfaces/loading.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';
import '../../../infrastructure/navigation/routes.dart';

class RoomScreen extends GetView<NotifController> {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title: Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        elevation: 0.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            // borderRadius: BorderRadius.only(
            //     topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            color: Colors.white),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                matchesWidget(),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Recent messages',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                recentWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget matchesWidget() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'New Matches',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                    ),
                    iconSize: 30.0,
                    color: Colors.white,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Container(
              height: 120.0,
              child: controller.listMatchNewUser.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.only(left: 10.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.listMatchNewUser.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () async {
                            int cek = controller.filterType(
                                controller.listMatchNewUser[index].matches ??
                                    "");
                            if (cek == 2) {
                              Get.snackbar("Information", "Blocked user");
                              return;
                            }
                            if (!globalController.isPurchased.value) {
                              ArtDialogResponse? response =
                                  await ArtSweetAlert.show(
                                barrierDismissible: false,
                                context: context,
                                artDialogArgs: ArtDialogArgs(
                                  denyButtonText: "Cancel",
                                  title: "Information",
                                  text:
                                      "Upgrade now to start chatting with this member!",
                                  confirmButtonText: "Subscribe Now",
                                  type: ArtSweetAlertType.warning,
                                ),
                              );

                              if (response == null) {
                                return;
                              }

                              if (response.isTapDenyButton) {
                                return;
                              }

                              if (response.isTapConfirmButton) {
                                Get.toNamed(Routes.PAYMENT_SUBCRIPTION);
                              }
                            } else {
                              // await Get.find<ChatController>().initChatScreen(
                              //     chatId(currentUser, data.newmatches[index]));
                              // Navigator.push(
                              //   context,
                              //   CupertinoPageRoute(
                              //     builder: (_) => ChatPage(
                              //       sender: currentUser,
                              //       chatId: chatId(
                              //           currentUser, data.newmatches[index]),
                              //       second: data.newmatches[index],
                              //     ),
                              //   ),
                              // );
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: secondryColor,
                                  radius: 35.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(90),
                                    child: CachedNetworkImage(
                                      imageUrl: controller
                                              .listMatchNewUser[index]
                                              .pictureUrl ??
                                          "",
                                      useOldImageOnUrlChange: true,
                                      placeholder: (context, url) =>
                                          CupertinoActivityIndicator(
                                        radius: 15,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6.0),
                                Text(
                                  controller.listMatchNewUser[index].userName ??
                                      "",
                                  style: TextStyle(
                                    color: secondryColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No match found",
                        style: TextStyle(color: secondryColor, fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recentWidget() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30.0),
          ),
          child: ListView(
            physics: ScrollPhysics(),
            children: controller.listMatchUser
                .map(
                  (index) => GestureDetector(
                    onTap: () async {
                      if (!globalController.isPurchased.value) {
                        ArtDialogResponse? response = await ArtSweetAlert.show(
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
                      UserModel? userSecond;
                      var data = await queryCollectionDB("Users")
                          .doc(index.matches ?? "")
                          .get();
                      if (!data.exists) {
                        Global().showInfoDialog("User not exist");
                        return;
                      }
                      userSecond = UserModel.fromJson(
                          data.data() as Map<String, dynamic>);
                      userSecond.relasi.value =
                          await Global().getRelationship(userSecond.id);
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
                          globalController.currentUser.value?.id ?? "",
                          index.matches ?? "",
                        ),
                        "userSecond": userSecond
                      });
                    },
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("chats")
                          .doc(Global().chatId(
                              globalController.currentUser.value!.id,
                              index.matches ?? ""))
                          .collection('messages')
                          .limit(1)
                          .orderBy('time', descending: true)
                          .snapshots(),
                      builder: (context, AsyncSnapshot snapshot) {
                        // print(snapshot.data.docs[0].data()['time']);
                        if (!snapshot.hasData)
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        else if (snapshot.data.docs.length == 0) {
                          return Container();
                        }
                        // index.lastMsg = snapshot.data.docs[0].data()['time'];
                        return Container(
                          margin: EdgeInsets.only(
                              top: 5.0, bottom: 5.0, right: 20.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: snapshot.data.docs[0].data()['sender_id'] !=
                                        globalController
                                            .currentUser.value?.id &&
                                    !snapshot.data.docs[0].data()['isRead']
                                ? primaryColor.withOpacity(.1)
                                : secondryColor.withOpacity(.2),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: secondryColor,
                              radius: 30.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(90),
                                child: CachedNetworkImage(
                                  imageUrl: index.pictureUrl ?? "",
                                  useOldImageOnUrlChange: true,
                                  placeholder: (context, url) =>
                                      loadingWidget(null, null, isloadingText: true),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            title: Text(
                              index.userName ?? "",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              snapshot.data.docs[0]
                                          .data()['image_url']
                                          .toString()
                                          .length >
                                      0
                                  ? "Photo"
                                  : snapshot.data.docs[0].data()['text'],
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  snapshot.data.docs[0].data()["time"] != null
                                      ? DateFormat.MMMd('en_US')
                                          .add_jm()
                                          .format(snapshot.data.docs[0]
                                              .data()["time"]
                                              .toDate())
                                          .toString()
                                      : "",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                snapshot.data.docs[0].data()['sender_id'] !=
                                            globalController
                                                .currentUser.value?.id &&
                                        !snapshot.data.docs[0].data()['isRead']
                                    ? Container(
                                        width: 40.0,
                                        height: 20.0,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'NEW',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : Text(""),
                                snapshot.data.docs[0].data()['sender_id'] ==
                                        globalController.currentUser.value?.id
                                    ? !snapshot.data.docs[0].data()['isRead']
                                        ? Icon(
                                            Icons.done,
                                            color: secondryColor,
                                            size: 15,
                                          )
                                        : Icon(
                                            Icons.done_all,
                                            color: primaryColor,
                                            size: 15,
                                          )
                                    : Text("")
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
