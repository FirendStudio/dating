import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/presentation/notif/controllers/notif.controller.dart';
import 'package:intl/intl.dart';
import '../../../domain/core/model/user_model.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';
import '../../../infrastructure/dal/util/general.dart';

class MatchesWidget extends GetView<NotifController> {
  const MatchesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Expanded(
        child: ListView.builder(
          itemCount: controller.listMatchUser.length,
          itemBuilder: (BuildContext context, int index) {
            Map doc = controller.listMatchUser[index];
            // bool cekLeave = data.filterLeave(doc);
            if (doc['type'] == 2) {
              return blockedWidget(doc, context);
            }
            return normalWidget(doc, context);
          },
        ),
      ),
    );
  }

  normalWidget(Map<dynamic, dynamic> doc, BuildContext context) {
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        extentRatio: 1 / 4,
        motion: const ScrollMotion(),
        dragDismissible: false,
        children: [
          SlidableAction(
            onPressed: (BuildContext context) async {
              var dataUserReceive =
                  await queryCollectionDB("Users").doc(doc['Matches']).get();
              UserModel tempuser;
              if (!dataUserReceive.exists) {
                Global().showInfoDialog("User not exist");
                return;
              }
              tempuser = UserModel.fromJson(dataUserReceive.data()!);
              tempuser.distanceBW = Global()
                  .calculateDistance(
                    Get.find<GlobalController>()
                            .currentUser
                            .value
                            ?.coordinates?['latitude'] ??
                        0,
                    Get.find<GlobalController>()
                        .currentUser
                        .value
                        ?.coordinates?['longitude'],
                    tempuser.coordinates?['latitude'] ?? 0,
                    tempuser.coordinates?['longitude'] ?? 0,
                  )
                  .round();
              String idChat = Global().chatId(
                  Get.find<GlobalController>().currentUser.value!, tempuser);
              var resultChat =
                  await queryCollectionDB("chats").doc(idChat).get();
              if (!resultChat.exists) {
                Global().setNewOptionMessage(idChat);
              }

              if (doc['type'] != 1) {
                Global().leaveWidget(
                  Get.find<GlobalController>().currentUser.value!,
                  tempuser,
                  idChat,
                  "notif",
                );
                return;
              }
              var chatList = await queryCollectionDB("chats")
                  .doc(idChat)
                  .collection("messages")
                  .limit(1)
                  .orderBy('time', descending: true)
                  .get();
              print(chatList.docs.length);
              if (chatList.docs.isEmpty) {
                Global().showInfoDialog("Message Not Found");
              }
              Global().restoreLeaveWidget(
                Get.find<GlobalController>().currentUser.value!,
                tempuser,
                chatList.docs.first.id,
                idChat,
                "notif",
              );
            },
            backgroundColor:
                (doc['type'] != 1) ? Color(0xFFFE4A49) : Colors.green[600]!,
            foregroundColor: Colors.white,
            icon: (doc['type'] != 1) ? Icons.block : Icons.restore,
            // label: 'Delete',
          ),
        ],
      ),
      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        extentRatio: 1 / 4,
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) async {
              var dataUserReceive =
                  await queryCollectionDB("Users").doc(doc['Matches']).get();
              UserModel tempuser;
              if (!dataUserReceive.exists) {
                Global().showInfoDialog("User not exist");
                return;
                // if (mounted) setState(() {});
              }
              tempuser = UserModel.fromJson(dataUserReceive.data()!);
              tempuser.distanceBW = Global()
                  .calculateDistance(
                    Get.find<GlobalController>()
                            .currentUser
                            .value
                            ?.coordinates?['latitude'] ??
                        0,
                    Get.find<GlobalController>()
                            .currentUser
                            .value
                            ?.coordinates?['longitude'] ??
                        0,
                    tempuser.coordinates?['latitude'] ?? 0,
                    tempuser.coordinates?['longitude'] ?? 0,
                  )
                  .round();
              String idChat = Global().chatId(
                  Get.find<GlobalController>().currentUser.value!, tempuser);
              var resultChat =
                  await queryCollectionDB("chats").doc(idChat).get();
              if (!resultChat.exists) {
                Global().setNewOptionMessage(idChat);
              }
              Global().disconnectWidget(
                Get.find<GlobalController>().currentUser.value!,
                tempuser,
                idChat,
                'notif',
              );
            },
            backgroundColor: Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            // label: 'Save',
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // color: !doc.data['isRead']
              color: !doc['isRead']
                  ? primaryColor.withOpacity(.15)
                  : secondryColor.withOpacity(.15)),
          child: ListTile(
            contentPadding: EdgeInsets.all(5),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: secondryColor,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  25,
                ),
                child: CachedNetworkImage(
                  imageUrl: doc['pictureUrl'] ?? "",
                  fit: BoxFit.cover,
                  useOldImageOnUrlChange: true,
                  placeholder: (context, url) => CupertinoActivityIndicator(
                    radius: 20,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            title: Text("You are matched with ${doc['userName'] ?? ""}"),
            subtitle: Text(
              DateFormat.MMMd('en_US')
                  .add_jm()
                  .format(doc['timestamp'].toDate())
                  .toString(),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // !doc.data['isRead']
                  !doc['isRead']
                      ? Container(
                          width: 40.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(30.0),
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
                ],
              ),
            ),
            onTap: () async {
              DocumentSnapshot userdoc =
                  await queryCollectionDB("Users").doc(doc["Matches"]).get();
              if (userdoc.exists) {
                UserModel userModel =
                    UserModel.fromJson(userdoc.data() as Map<String, dynamic>);
                userModel.relasi.value =
                    await Global().getRelationship(userModel.id);
                if (!doc["isRead"]) {
                  queryCollectionDB(
                          "/Users/${Get.find<GlobalController>().currentUser.value?.id}/Matches")
                      .doc('${doc["Matches"]}')
                      .update(
                    {'isRead': true},
                  );
                }
                Global().initProfil(userModel);
              }
            },
          ),
        ),
      ),
    );
  }

  blockedWidget(Map<dynamic, dynamic> doc, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // color: !doc.data['isRead']
            color: secondryColor.withOpacity(.15),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(5),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: secondryColor,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  25,
                ),
                child: CachedNetworkImage(
                  imageUrl: doc['pictureUrl'] ?? "",
                  fit: BoxFit.cover,
                  useOldImageOnUrlChange: true,
                  placeholder: (context, url) => CupertinoActivityIndicator(
                    radius: 20,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            title: Text("You are matched with ${doc['userName'] ?? ""}"),
            subtitle: Column(
              children: [
                SizedBox(
                  height: 6,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: 40.0,
                        height: 25.0,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Disconnected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(flex: 4, child: Text(""))
                  ],
                ),
              ],
            ),
            onTap: () async {
              Global().showInfoDialog("Blocked user");
            },
          )
          //  : Container()
          ),
    );
  }
}
