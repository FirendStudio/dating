import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/NotificationController.dart';
import 'package:hookup4u/Screens/Chat/Matches.dart';
import 'package:hookup4u/Screens/Profile/EditProfile.dart';
import 'package:hookup4u/Screens/reportUser.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:swipe_stack/swipe_stack.dart';
// import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Controller/TabsController.dart';
import '../../models/Relationship.dart';
import '../Chat/chatPage.dart';
import '../Payment/subscriptions.dart';

class InformationPartner extends StatelessWidget {
  final UserModel currentUser;
  final UserModel user;
  final Relationship relation;
  final UserModel userPartner;

  final GlobalKey<SwipeStackState> swipeKey;
  InformationPartner(
      this.user,
      this.currentUser,
      this.swipeKey,
      this.relation,
      this.userPartner,
    );
  String interestText = "";
  String desiresText = "";

  TabsController tabsController = Get.put(TabsController());
  // NotificationController notificationController = Get.put(NotificationController());
  bool cekpartner = false;

  @override
  Widget build(BuildContext context) {
    bool isMe = user.id == currentUser.id;
    bool isMatched = swipeKey == null;
    //matches.any((value) => value.id == user.id);
    if(Get.find<NotificationController>().relationUserPartner != null && Get.find<NotificationController>().relationUserPartner.partner.partnerId.isNotEmpty){
      cekpartner = true;
    }
    print(user);
    if(user != null){
      if(user.desires.isNotEmpty){
        for(int index=0; index<= user.desires.length-1; index++){
          if(desiresText.isEmpty){
            desiresText = tabsController.capitalize(user.desires[index]);
            print(desiresText);
          }else{
            desiresText += ", " + tabsController.capitalize(user.desires[index]);
          }
        }
      }

      if(user.interest.isNotEmpty){
        for(int index=0; index<= user.interest.length-1; index++){
          if(interestText.isEmpty){
            interestText = tabsController.capitalize(user.interest[index]);
          }else{
            interestText += ", " + tabsController.capitalize(user.interest[index]);
          }
        }
      }
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              "${user.name},",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: (!cekpartner)?Text(
                                "${user.editInfo['showMyAge'] != null ? !user.editInfo['showMyAge'] ? user.age : "" : user.age}" +
                                    ", " + user.gender + ", " + user.sexualOrientation + "\n " + user.status + ", " + "${user.distanceBW} KM away")
                                :Text(
                                "${user.editInfo['showMyAge'] != null ? !user.editInfo['showMyAge'] ? user.age : "" : user.age}" +
                                    ", " + user.gender + ", " + user.sexualOrientation + ", " +
                                    userPartner.age.toString() + ", " + userPartner.gender + ", " +  userPartner.sexualOrientation
                                    + "\n\nCouple, " + "${user.distanceBW} KM away"
                              // + "${user.address}"
                            ),
                            trailing: FloatingActionButton(
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  // Get.find<NotificationController>().relationUserPartner = null;
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

                  if(desiresText.isNotEmpty)
                    ListTile(
                      dense: true,
                      title: Text(
                        "Desires",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(desiresText),
                    ),

                  SizedBox(
                    height: 10,
                  ),

                  if(interestText.isNotEmpty)
                    ListTile(
                      dense: true,
                      title: Text(
                        "Interest",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(interestText),
                    ),

                  SizedBox(
                    height: 10,
                  ),

                  if(relation.partner.partnerId.isNotEmpty)
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
                  if(relation.partner.partnerId.isNotEmpty)
                    ListTile(
                      dense: true,
                      trailing: IconButton(
                        onPressed: (){
                          Get.back();
                        },
                        icon: Icon(Icons.chevron_right_sharp,
                          size: 40,
                        ),
                      ),
                      title: Text(
                        relation.partner.partnerName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(userPartner.status + ", "
                          + userPartner.sexualOrientation
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: secondryColor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            25,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: relation.partner.partnerImage,
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

                        var data = await FirebaseFirestore.instance.collection("Relationship").doc(user.id).get();

                        if(!data.exists){
                          await Get.find<NotificationController>().setNewRelationship(user.id);
                          data = await FirebaseFirestore.instance.collection("Relationship").doc(user.id).get();
                        }
                        Relationship relationshipTemp = Relationship.fromDocument(data.data());
                        if(relationshipTemp.pendingAcc[0].reqUid == Get.find<TabsController>().currentUser.id){
                          Get.back();
                          // return;
                        }else{

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
                                    builder: (context) => ChatPage(
                                      sender: currentUser,
                                      second: user,
                                      chatId: chatId(user, currentUser),
                                    )));
                          }

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
