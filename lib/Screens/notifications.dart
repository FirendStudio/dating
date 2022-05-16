import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/NotificationController.dart';
import 'package:hookup4u/Controller/TabsController.dart';
import 'package:hookup4u/Screens/Information.dart';
import 'package:hookup4u/Screens/Widget/CustomSearch.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:intl/intl.dart';
// import 'package:easy_localization/easy_localization.dart';

import '../Controller/LoginController.dart';
import 'Tab.dart';

// class Notifications extends StatefulWidget {
//   final UserModel currentUser;
//   Notifications(this.currentUser);
//
//   @override
//   _NotificationsState createState() => _NotificationsState();
// }

class Notifications extends StatelessWidget {
  NotificationController notificationController = Get.put(NotificationController());
  final UserModel currentUser;
  Notifications(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(builder: (data){

      return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          onPressed: (){
            showSearch(context: context, delegate: CustomSearch());
          },
          child: Icon(Icons.add, color: Colors.white,),
        ),
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
              Icon(Icons.volunteer_activism, size: 30,
                color: Colors.white,
              ),
              Icon(Icons.add_to_photos, size: 30,
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

                  if(data.indexNotif == 0)
                    matchesWidget(data),
                  if(data.indexNotif == 1)
                    pendingWidget(data),

                ],
              ),
            ),
          ));

    });
  }

  Widget pendingWidget(NotificationController data){
    if(data.listPendingReq.isEmpty){
      return Center(
          child: Text(
            "No Pending Request",
            style: TextStyle(color: secondryColor, fontSize: 16),
          ));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: data.listPendingReq.length,
        itemBuilder: (BuildContext context,int index){
          // QueryDocumentSnapshot doc = data.listLikedUser[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(20),
                    color:secondryColor.withOpacity(.15)),
                child:Row(
                  children: [

                    Expanded(
                      flex: 1,
                      child:CircleAvatar(
                        radius: 25,
                        backgroundColor: secondryColor,
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(
                            25,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: data.listPendingReq[index].imageUrl,
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

                    Expanded(
                        flex: 6,
                        child:ListTile(
                          title: Text("You are requested partner by " + data.listPendingReq[index].userName,
                            style: TextStyle(
                                fontSize: 15
                            ),
                          ),
                          subtitle: Text(
                            DateFormat.MMMd('en_US')
                                .add_jm().format(data.listPendingReq[index].createdAt)
                                // doc['timestamp'].toDate())
                                .toString(),
                          ),
                        )
                    ),

                    Expanded(
                        flex: 1,
                        child:Row(
                          children: [

                            Expanded(
                              child: FloatingActionButton(
                                backgroundColor: Colors.greenAccent,
                                onPressed: () async {



                                  // if (Get.find<TabsController>().likedByList.contains(doc['LikedBy'])) {
                                  //   print("Masuk sini");
                                  //   showDialog(
                                  //       context: context,
                                  //       builder: (ctx) {
                                  //         Future.delayed(
                                  //             Duration(milliseconds: 1700),
                                  //                 () {
                                  //               Navigator.pop(ctx);
                                  //             });
                                  //         return Padding(
                                  //           padding: const EdgeInsets.only(
                                  //               top: 80),
                                  //           child: Align(
                                  //             alignment:
                                  //             Alignment.topCenter,
                                  //             child: Card(
                                  //               child: Container(
                                  //                 height: 100,
                                  //                 width: 300,
                                  //                 child: Center(
                                  //                     child: Text(
                                  //                       "It's a match\n With ",
                                  //                       textAlign:
                                  //                       TextAlign.center,
                                  //                       style: TextStyle(
                                  //                           color:
                                  //                           primaryColor,
                                  //                           fontSize: 30,
                                  //                           decoration:
                                  //                           TextDecoration
                                  //                               .none),
                                  //                     )
                                  //                   // .tr(args: ['${widget.users[index].name}']),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         );
                                  //       });
                                  //   print(Get.find<LoginController>().userId);
                                  //   print(doc['LikedBy']);
                                  //   await data.docReference
                                  //       .doc(Get.find<LoginController>().userId)
                                  //       .collection("Matches")
                                  //       .doc(doc['LikedBy'])
                                  //       .set(
                                  //       {
                                  //         'Matches': doc['LikedBy'],
                                  //         'isRead': false,
                                  //         'userName': doc['userName'],
                                  //         'pictureUrl': doc['pictureUrl'],
                                  //         'timestamp': FieldValue.serverTimestamp()
                                  //       },
                                  //       SetOptions(merge : true)
                                  //   );
                                  //   await data.docReference
                                  //       .doc(doc['LikedBy'])
                                  //       .collection("Matches")
                                  //       .doc(Get.find<LoginController>().userId)
                                  //       .set(
                                  //       {
                                  //         'Matches': Get.find<LoginController>().userId,
                                  //         'userName': currentUser.name,
                                  //         'pictureUrl': (currentUser.imageUrl[0].runtimeType == String)?currentUser.imageUrl[0] : currentUser.imageUrl[0]['url'],
                                  //         'isRead': false,
                                  //         'timestamp': FieldValue.serverTimestamp()
                                  //       },
                                  //       SetOptions(merge : true)
                                  //   );
                                  // }
                                  //
                                  // await data.docReference
                                  //     .doc(Get.find<LoginController>().userId)
                                  //     .collection("CheckedUser")
                                  //     .doc(doc['LikedBy'])
                                  //     .set(
                                  //     {
                                  //       'userName': doc['userName'],
                                  //       'pictureUrl': doc['pictureUrl'],
                                  //       'LikedUser': doc['LikedBy'],
                                  //       'timestamp':
                                  //       FieldValue.serverTimestamp(),
                                  //     },
                                  //     SetOptions(merge : true)
                                  // );
                                  // await data.docReference
                                  //     .doc(doc['LikedBy'])
                                  //     .collection("LikedBy")
                                  //     .doc(Get.find<LoginController>().userId)
                                  //     .set(
                                  //     {
                                  //       'userName': doc['userName'],
                                  //       'pictureUrl': doc['pictureUrl'],
                                  //       'LikedBy': Get.find<LoginController>().userId,
                                  //       'timestamp':
                                  //       FieldValue.serverTimestamp()
                                  //     },
                                  //     SetOptions(merge : true)
                                  // );
                                  //
                                  // data.removeUserSwipe(index);

                                },
                                child: Icon(
                                  Icons.add,
                                  size: 25,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            // SizedBox(
                            //   width: 10,
                            // ),
                            //
                            // Expanded(
                            //   child:FloatingActionButton(
                            //     backgroundColor: Colors.redAccent,
                            //     onPressed: () async {
                            //       await data.docReference
                            //           .doc(Get.find<LoginController>().userId)
                            //           .collection("CheckedUser")
                            //           .doc(doc['LikedBy'])
                            //           .set({
                            //         'userName': doc["userName"],
                            //         'pictureUrl': doc["pictureUrl"],
                            //         'DislikedUser': doc['LikedBy'],
                            //         'timestamp': DateTime.now(),
                            //       },
                            //           SetOptions(merge : true)
                            //       );
                            //
                            //       data.removeUserSwipe(index);
                            //
                            //     },
                            //     child: Icon(
                            //       Icons.close,
                            //       size: 25,
                            //       color: Colors.black,
                            //     ),
                            //   ),
                            // ),

                          ],
                        )
                    ),

                  ],
                )
              //  : Container()
            ),
          );
        },
      ),
    );
  }

  Widget matchesWidget(NotificationController data){
    return Expanded(
      child: ListView.builder(
          itemCount: data.listMatchUser.length,
          itemBuilder: (BuildContext context,int index) {
            QueryDocumentSnapshot doc = data.listMatchUser[index];
            // print(doc.id);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(20),
                      // color: !doc.data['isRead']
                      color: !doc['isRead']
                          ? primaryColor.withOpacity(.15)
                          : secondryColor
                          .withOpacity(.15)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(5),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: secondryColor,
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(
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
                          errorWidget:
                              (context, url, error) =>
                              Icon(
                                Icons.error,
                                color: Colors.black,
                              ),
                        ),
                      ),
                    ),
                    title: Text("you are matched with"),
                    subtitle: Text(
                      DateFormat.MMMd('en_US')
                          .add_jm()
                          .format(doc['timestamp']
                          .toDate())
                          .toString(),),
                    // "${(doc.data['timestamp'].toDate())}"),
                    // "${(doc['timestamp'].toDate())}"),
                    //  Text(
                    //     "Now you can start chat with ${notification[index].sender.name}"),
                    // "if you want to match your profile with ${notifications[index].sender.name} just like ${notifications[index].sender.name}'s profile"),
                    trailing: Padding(
                      padding: const EdgeInsets.only(
                          right: 10),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          // !doc.data['isRead']
                          !doc['isRead']
                              ? Container(
                            width: 40.0,
                            height: 20.0,
                            decoration:
                            BoxDecoration(
                              color: primaryColor,
                              borderRadius:
                              BorderRadius
                                  .circular(
                                  30.0),
                            ),
                            alignment:
                            Alignment.center,
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          )
                              : Text(""),
                        ],
                      ),
                    ),
                    onTap: () async {
                      // print(doc.data["Matches"]);
                      print(doc["Matches"]);
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
                      DocumentSnapshot userdoc = await data.db
                          .collection("Users")
                      // .doc(doc.data["Matches"])
                          .doc(doc["Matches"])
                          .get();
                      if (userdoc.exists) {
                        Navigator.pop(context);
                        UserModel tempuser =
                        UserModel.fromDocument(userdoc);
                        tempuser.distanceBW = Get.find<TabsController>().calculateDistance(
                            currentUser.coordinates['latitude'],
                            currentUser.coordinates['longitude'],
                            tempuser.coordinates['latitude'],
                            tempuser.coordinates['longitude']).round();

                        await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {

                              // if (!doc.data["isRead"]) {
                              if (!doc["isRead"]) {
                                FirebaseFirestore.instance
                                    .collection(
                                    "/Users/${Get.find<LoginController>().userId}/Matches")
                                // .doc('${doc.data["Matches"]}')
                                    .doc('${doc["Matches"]}')
                                    .update(
                                    {'isRead': true});
                              }
                              return Info(
                                  tempuser,
                                  currentUser,
                                  null);
                            });
                      }
                    },
                  )
                //  : Container()
              ),
            );

          }
      ),
    );
  }

}
