import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Chat/Matches.dart';
import 'package:hookup4u/Screens/Chat/chatPage.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:intl/intl.dart';

import '../../Controller/TabsController.dart';
import '../Payment/subscriptions.dart';

class RecentChats extends StatelessWidget {
  final db = FirebaseFirestore.instance;
  final UserModel currentUser;
  final List<UserModel> matches;

  RecentChats(this.currentUser, this.matches);

  @override
  Widget build(BuildContext context) {
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
                //   topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: ListView(
                  physics: ScrollPhysics(),
                  children: matches
                      .map((index) => GestureDetector(
                            onTap: () async {
                              // Navigator.push(
                              //   context,
                              //   CupertinoPageRoute(
                              //     builder: (_) => ChatPage(
                              //       chatId: chatId(currentUser, index),
                              //       sender: currentUser,
                              //       second: index,
                              //     ),
                              //   ),
                              // );
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
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => ChatPage(
                                      chatId: chatId(currentUser, index),
                                      sender: currentUser,
                                      second: index,
                                    ),
                                  ),
                                );
                              }

                            },
                            child: StreamBuilder(
                                stream: db.collection("chats")
                                    .doc(chatId(currentUser, index))
                                    .collection('messages')
                                    .orderBy('time', descending: true)
                                    // .get()
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
                                  bool cek = index.imageUrl[0].runtimeType == String;
                                  // print("Cek");
                                  // print(cek);
                                  index.lastmsg = snapshot.data.docs[0].data()['time'];
                                  return Container(
                                    margin: EdgeInsets.only(
                                        top: 5.0, bottom: 5.0, right: 20.0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: snapshot.data.docs[0].data()['sender_id'] !=
                                                  currentUser.id &&
                                              !snapshot.data.docs[0].data()
                                                  ['isRead']
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
                                          borderRadius:
                                              BorderRadius.circular(90),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                            (cek)?
                                            index.imageUrl[0]:
                                            index.imageUrl[0]['url'] ?? '',
                                            useOldImageOnUrlChange: true,
                                            placeholder: (context, url) =>
                                                CupertinoActivityIndicator(
                                              radius: 15,
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        index.name,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        snapshot.data.docs[0].data()['image_url']
                                                    .toString().length >
                                                0
                                            ? "Photo"
                                            : snapshot.data.docs[0].data()
                                                ['text'],
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            snapshot.data.docs[0].data()
                                            ["time"] !=
                                                    null
                                                ? DateFormat.MMMd('en_US')
                                                    .add_jm()
                                                    .format(snapshot.data.docs[0].data()["time"]
                                                        .toDate())
                                                    .toString()
                                                : "",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          snapshot.data.docs[0].data()
                                                          ['sender_id'] !=
                                                      currentUser.id &&
                                                  !snapshot.data.docs[0].data()
                                                      ['isRead']
                                              ? Container(
                                                  width: 40.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    color: primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                  ),
                                                  alignment: Alignment.center,
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
                                          snapshot.data.docs[0].data()
                                                      ['sender_id'] ==
                                                  currentUser.id
                                              ? !snapshot.data.docs[0].data()
                                                      ['isRead']
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
                                }),
                          ))
                      .toList()),
            )));
  }
}
