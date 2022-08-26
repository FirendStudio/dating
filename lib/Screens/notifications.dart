import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'Info/InformationPartner.dart';
import 'Tab.dart';

// class Notifications extends StatefulWidget {
//   final UserModel currentUser;
//   Notifications(this.currentUser);
//
//   @override
//   _NotificationsState createState() => _NotificationsState();
// }

class Notifications extends StatelessWidget {
  NotificationController notificationController =
      Get.put(NotificationController());
  final UserModel currentUser;
  Notifications(this.currentUser);

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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // matchesWidget(data),
                  if (data.indexNotif == 0) matchesWidget(data),
                  if (data.indexNotif == 1) likedWidget(data),
                ],
              ),
            ),
          ));
    });
  }

  Widget likedWidget(NotificationController data) {
    if (data.listLikedUserAll.isEmpty) {
      return Center(
          child: Text(
        "No Liked",
        style: TextStyle(color: secondryColor, fontSize: 16),
      ));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: data.listLikedUserAll.length,
        itemBuilder: (BuildContext context, int index) {
          // QueryDocumentSnapshot doc = data.listLikedUser[index];
          return InkWell(
              onTap: () async {
                print(data.listLikedUserAll[index]["LikedBy"]);
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

                await Get.find<NotificationController>().initUserPartner(Uid: data.listLikedUserAll[index]["LikedBy"]);
                var relation = await FirebaseFirestore.instance.collection("Relationship").doc(data.listLikedUserAll[index]["LikedBy"]).get();
                if(!relation.exists){
                  await Get.find<NotificationController>().setNewRelationship(data.listLikedUserAll[index]["LikedBy"]);
                  relation = await FirebaseFirestore.instance.collection("Relationship").doc(data.listLikedUserAll[index]["LikedBy"]).get();
                }
                Relationship relationshipTemp = Relationship.fromDocument(relation.data());
                Get.back();
                Get.find<NotificationController>().userPartner.distanceBW = Get.find<TabsController>().calculateDistance(
                    currentUser.coordinates['latitude'],
                    currentUser.coordinates['longitude'],
                    Get.find<NotificationController>().userPartner.coordinates['latitude'],
                    Get.find<NotificationController>().userPartner.coordinates['longitude']).round();
                await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return InformationPartner(
                      currentUser,
                      currentUser,
                      null,
                      relationshipTemp,
                      Get.find<NotificationController>().userPartner,
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
                                imageUrl: data.listLikedUserAll[index]
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
                                    data.listLikedUserAll[index]['userName'],
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: Text(
                                DateFormat.MMMd('en_US').add_jm().format(
                                    (data.listLikedUserAll[index]['timestamp'])
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

  Widget matchesWidget(NotificationController data) {
    return Expanded(
      child: ListView.builder(
          itemCount: data.listMatchUser.length,
          itemBuilder: (BuildContext context, int index) {
            QueryDocumentSnapshot doc = data.listMatchUser[index];
            // print(doc.id);

            return Padding(
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
                              return Info(tempuser, currentUser, null);
                            });
                      }
                    },
                  )
                  //  : Container()
                  ),
            );
          }),
    );
  }
}
