import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/ChatController.dart';
import 'package:hookup4u/Controller/NotificationController.dart';
import 'package:hookup4u/Controller/TabsController.dart';
import 'package:hookup4u/Screens/Info/Information.dart';
import 'package:hookup4u/Screens/Widget/CustomSearch.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:intl/intl.dart';
// import 'package:easy_localization/easy_localization.dart';

import '../Controller/LoginController.dart';
import '../models/Relationship.dart';
import 'Chat/Matches.dart';
import 'Info/InformationPartner.dart';
import 'Tab.dart';

// class Notifications extends StatefulWidget {
//   final UserModel currentUser;
//   Notifications(this.currentUser);

//   @override
//   _NotificationsState createState() => _NotificationsState();
// }

class Notifications extends StatelessWidget {
  NotificationController notificationController =
      Get.put(NotificationController());
  
  final UserModel currentUser;
  Notifications(this.currentUser);

  // @override
  // void initState() {
    
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(builder: (data) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            automaticallyImplyLeading: false,
            title: Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            elevation: 0,
          ),
          backgroundColor: primaryColor,
          bottomNavigationBar: CurvedNavigationBar(
            color: Colors.redAccent,
            index: data.indexNotif,
            backgroundColor: Colors.white,
            items: <Widget>[
              Icon(
                Icons.notifications_active,
                size: 30,
                color: Colors.white,
              ),
              Icon(
                Icons.volunteer_activism,
                size: 30,
                color: Colors.white,
              ),
            ],
            onTap: (index) {
              data.indexNotif = index;
              data.update();
              //Handle button tap
            },
          ),
          body: Container(
            width: Get.width,
            decoration: BoxDecoration(
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(50),
                //   topRight: Radius.circular(50),
                // ),
                color: Colors.white),
            child: ClipRRect(
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(50),
              //   topRight: Radius.circular(50),
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // matchesWidget(data),
                  if (data.indexNotif == 1 && data.listLikedTemp.isNotEmpty)
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 15, top: 15,
                        ),
                        child: Text("Members that liked your profile!",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      
                    ]
                  ),
                  if (data.indexNotif == 0) matchesWidget(data),
                  if (data.indexNotif == 1) likedWidget(data),
                ],
              ),
            ),
          ));
    });
  }

  Widget likedWidget(NotificationController data) {
    if (data.listLikedTemp.isEmpty) {
      return Center(
          child: Text(
        "No Liked",
        style: TextStyle(color: secondryColor, fontSize: 16),
      ));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: data.listLikedTemp.length,
        itemBuilder: (BuildContext context, int index) {
          // QueryDocumentSnapshot doc = data.listLikedUser[index];
          var likedUser = data.listLikedTemp[index];
          
          return InkWell(
              onTap: () async {
                print(likedUser["LikedBy"]);
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

                await Get.find<NotificationController>().initUserPartner(Uid: likedUser["LikedBy"]);
                var relation = await FirebaseFirestore.instance.collection("Relationship").doc(likedUser["LikedBy"]).get();
                if(!relation.exists){
                  await Get.find<NotificationController>().setNewRelationship(likedUser["LikedBy"]);
                  relation = await FirebaseFirestore.instance.collection("Relationship").doc(likedUser["LikedBy"]).get();
                }
                Relationship relationshipTemp = Relationship.fromDocument(relation.data());
                
                var result = await FirebaseFirestore.instance.collection('Users').doc(likedUser["LikedBy"]).get();
                print(result);
                UserModel userSelected = UserModel.fromDocument(result);
                Get.back();
                userSelected.distanceBW = Get.find<TabsController>().calculateDistance(
                    currentUser.coordinates['latitude'],
                    currentUser.coordinates['longitude'],
                    Get.find<NotificationController>().userPartner.coordinates['latitude'],
                    Get.find<NotificationController>().userPartner.coordinates['longitude']).round();
                // data.listLikedUserAll[index]["LikedBy"];
                await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return InformationPartner(
                      userSelected,
                      currentUser,
                      null,
                      relationshipTemp,
                      Get.find<NotificationController>().userPartner,
                      "like"
                    );
                  }
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        // color: !doc.data['isRead']
                        color: secondryColor.withOpacity(.15)),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: secondryColor,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                25,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: likedUser
                                    ['pictureUrl'],
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
                        Expanded(
                            flex: 6,
                            child: ListTile(
                              title: Text(
                                "You are liked by " +
                                    likedUser['userName'],
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: Text(
                                DateFormat.MMMd('en_US').add_jm().format(
                                    (likedUser['timestamp'])
                                        .toDate()),
                              ),
                            )),
                      ],
                    )
                    //  : Container()
                    ),
              ));
        },
      ),
    );
  }

  Widget matchesWidget(NotificationController cek) {
    return GetBuilder<NotificationController>(builder: (data){
      print( "Jumlah Matches : " + data.listMatchUserAll.length.toString());
      return Expanded(
        child: ListView.builder(
            itemCount: data.listTempMatch.length,
            itemBuilder: (BuildContext context, int index) {
              Map doc = data.listTempMatch[index];
              // bool cekLeave = data.filterLeave(doc);
              return Slidable(
                key: const ValueKey(0),
                startActionPane: ActionPane(
                  extentRatio: 1/4,
                  motion: const ScrollMotion(),
                  dragDismissible: false,
                  dismissible: DismissiblePane(onDismissed: () {}),
                  children: [
                    SlidableAction(
                      onPressed: (BuildContext context) async {
                        var dataUserReceive = await data.db.collection("Users").doc(doc['Matches']).get();
                        UserModel tempuser;
                        if (!dataUserReceive.exists) {
                          Get.snackbar("Info", "User not exist");
                          return;
                          // if (mounted) setState(() {});
                        }
                        tempuser            = UserModel.fromDocument(dataUserReceive);
                        tempuser.distanceBW = Get.find<TabsController>().calculateDistance(
                            currentUser.coordinates['latitude'],
                            currentUser.coordinates['longitude'],
                            tempuser.coordinates['latitude'],
                            tempuser.coordinates['longitude'])
                            .round();
                        String idChat = chatId(currentUser, tempuser);
                        var resultChat = await FirebaseFirestore.instance.collection("chats").doc(idChat).get();
                        if(!resultChat.exists){
                          Get.find<ChatController>().setNewOptionMessage(idChat);
                        }

                        if(!doc['isLeave']){
                          Get.find<ChatController>().leaveWidget(currentUser, tempuser, idChat, "notif");
                          return;
                        }
                        var chatList = await FirebaseFirestore.instance.collection("chats").doc(idChat).collection("messages").limit(1).orderBy('time', descending: true).get();
                        print(chatList.docs.length);
                        if(chatList.docs.isEmpty){
                          Get.snackbar("Info", "Message Not Found");
                        }
                        Get.find<ChatController>().restoreLeaveWidget(currentUser, tempuser, chatList.docs.first.id, idChat, "notif");
                      },
                      backgroundColor: (!doc['isLeave'])?Color(0xFFFE4A49) : Colors.green[600],
                      foregroundColor: Colors.white,
                      icon: (!doc['isLeave'])?Icons.block : Icons.restore,
                      // label: 'Delete',
                    ),
                  ],
                ),
                // The end action pane is the one at the right or the bottom side.
                endActionPane: ActionPane(
                  extentRatio: 1/4,
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (BuildContext context) async {
                        var dataUserReceive = await data.db.collection("Users").doc(doc['Matches']).get();
                        UserModel tempuser;
                        if (!dataUserReceive.exists) {
                          Get.snackbar("Info", "User not exist");
                          return;
                          // if (mounted) setState(() {});
                        }
                        tempuser            = UserModel.fromDocument(dataUserReceive);
                        tempuser.distanceBW = Get.find<TabsController>().calculateDistance(
                            currentUser.coordinates['latitude'],
                            currentUser.coordinates['longitude'],
                            tempuser.coordinates['latitude'],
                            tempuser.coordinates['longitude'])
                            .round();
                        String idChat = chatId(currentUser, tempuser);
                        var resultChat = await FirebaseFirestore.instance.collection("chats").doc(idChat).get();
                        if(!resultChat.exists){
                          Get.find<ChatController>().setNewOptionMessage(idChat);
                        }
                        Get.find<ChatController>().disconnectWidget(currentUser, tempuser, idChat, 'notif');
                      },
                      backgroundColor: Color(0xFF0392CF),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      // label: 'Save',
                    ),
                  ],
                ),
                child:Padding(
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
                        title:
                            Text("you are matched with ${doc['userName'] ?? ""}"),
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
                          // print(doc.data["Matches"]);

                          showDialog(
                              context: context,
                              builder: (context) {
                                return Center(
                                    child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ));
                              });
                          print(doc["Matches"]);
                          await data.initRelationPartner(Uid: doc['Matches']);
                          print("Cek Relation : " +
                              data.relationUserPartner.inRelationship.toString());
                          if (data.relationUserPartner.inRelationship) {
                            await data.initUserPartner(
                                Uid: data.relationUserPartner.partner.partnerId);
                          }
                          DocumentSnapshot userdoc = await data.db
                              .collection("Users")
                              .doc(doc["Matches"])
                              .get();
                          if (userdoc.exists) {
                            Navigator.pop(context);
                            UserModel tempuser = UserModel.fromDocument(userdoc);
                            tempuser.distanceBW = Get.find<TabsController>()
                                .calculateDistance(
                                    currentUser.coordinates['latitude'],
                                    currentUser.coordinates['longitude'],
                                    tempuser.coordinates['latitude'],
                                    tempuser.coordinates['longitude'])
                                .round();

                            await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  // if (!doc.data["isRead"]) {
                                  if (!doc["isRead"]) {
                                    FirebaseFirestore.instance
                                        .collection(
                                            "/Users/${Get.find<LoginController>().userId}/Matches")
                                        .doc('${doc["Matches"]}')
                                        .update({'isRead': true});
                                  }
                                  Get.find<NotificationController>()
                                      .cekFirstInfo(tempuser);
                                  return Info(tempuser, currentUser, null, "");
                                });
                          }
                        },
                      )
                      //  : Container()
                      ),
                  )
              );
            }),
      );
    });
  }
}
