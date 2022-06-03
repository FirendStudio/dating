import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Chat/chatPage.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';

import '../../Controller/TabsController.dart';
import '../Payment/subscriptions.dart';
// import 'package:easy_localization/easy_localization.dart';

class Matches extends StatelessWidget {
  final UserModel currentUser;
  final List<UserModel> matches;

  Matches(this.currentUser, this.matches);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              child: matches.length > 0
                  ? ListView.builder(
                      padding: EdgeInsets.only(left: 10.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: matches.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () async {
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
                                    sender: currentUser,
                                    chatId: chatId(currentUser, matches[index]),
                                    second: matches[index],
                                  ),
                                ),
                              );
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
                                      imageUrl:
                                      (matches[index].imageUrl[0].runtimeType == String)?
                                          matches[index].imageUrl[0]
                                          :matches[index].imageUrl[0]['url']?? '',
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
                                  matches[index].name,
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
                    ))),
        ],
      ),
    );
  }
}

var groupChatId;
chatId(currentUser, sender) {
  if (currentUser.id.hashCode <= sender.id.hashCode) {
    return groupChatId = '${currentUser.id}-${sender.id}';
  } else {
    return groupChatId = '${sender.id}-${currentUser.id}';
  }
}
