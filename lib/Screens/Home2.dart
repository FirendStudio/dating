import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/NotificationController.dart';
import 'package:hookup4u/Controller/TabsController.dart';
import 'package:hookup4u/Screens/Info/Information.dart';
import 'package:hookup4u/Screens/Payment/subscriptions.dart';
import 'package:hookup4u/Screens/reportUser.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:swipe_stack/swipe_stack.dart';

import '../Controller/LoginController.dart';
import '../models/Relationship.dart';
import 'Info/InformationPartner.dart';
import 'Widget/DialogFirstApp.dart';
// import 'package:easy_localization/easy_localization.dart';


class CardPictures2 extends StatefulWidget {
  // final List<UserModel> users;
  final UserModel currentUser;
  final int swipedcount;
  final Map items;
  CardPictures2(this.currentUser,
      // this.users,
      this.swipedcount, this.items);

  @override
  _CardPicturesState2 createState() => _CardPicturesState2();
}

class _CardPicturesState2 extends State<CardPictures2>
    with AutomaticKeepAliveClientMixin<CardPictures2> {
  // TabbarState state = TabbarState();
  bool onEnd = false;
  // Ads _ads = new Ads();

  GlobalKey<SwipeStackState> swipeKey = GlobalKey<SwipeStackState>();
  CarouselController carouselController = CarouselController();
  CollectionReference docRef = FirebaseFirestore.instance.collection("Users");

  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    super.build(context);
    int freeSwipe = widget.items['free_swipes'] != null
        ? int.parse(widget.items['free_swipes']) : 10;
    bool exceedSwipes = widget.swipedcount >= freeSwipe;
    return GetBuilder<TabsController>(builder: (data){
      return Scaffold(

        backgroundColor: primaryColor,
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              color: Colors.white),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            child: Stack(
              children: [
                AbsorbPointer(
                  absorbing: exceedSwipes,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        // height: MediaQuery.of(context).size.height * .78,
                        height: Get.height,
                        width: MediaQuery.of(context).size.width,
                        child: data.users.length == 0
                            ? Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  backgroundColor: secondryColor,
                                  radius: 40,
                                ),
                              ),
                              Text(
                                "There's no one new around you.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: secondryColor,
                                    decoration: TextDecoration.none,
                                    fontSize: 18
                                ),
                              )
                            ],
                          ),
                          // ) : swiperWidget(),
                        ) : carouselWidget(),
                      ),
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
                                    if (data.users.length > 0) {
                                      print("object 1");
                                      await docRef
                                          .doc(Get.find<LoginController>().userId)
                                          .collection("CheckedUser")
                                          .doc(data.users[data.indexUser].id)
                                          .set({
                                        'userName': data.users[data.indexUser].name,
                                        'pictureUrl': (data.users[data.indexUser].imageUrl[0].runtimeType == String)
                                            ?data.users[data.indexUser].imageUrl[0]:data.users[data.indexUser].imageUrl[0]['url'],
                                        'DislikedUser':
                                        data.users[data.indexUser].id,
                                        'timestamp': DateTime.now(),
                                      }, SetOptions(merge : true)
                                      );

                                      if (data.indexUser < data.users.length) {
                                        data.userRemoved.clear();
                                        setState(() {
                                          data.userRemoved.add(data.users[data.indexUser]);
                                          data.users.removeAt(data.indexUser);
                                        });
                                      }
                                      // swipeKey.currentState.swipeLeft();

                                    }
                                  }),
                              FloatingActionButton(
                                  heroTag: UniqueKey(),
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    if (data.users.length > 0) {
                                      print(data.users[data.indexUser].name);
                                      // swipeKey.currentState.swipeRight();
                                      print(data.users[data.indexUser].name);
                                      if (data.likedByList.contains(data.users[data.indexUser].id)) {
                                        print("Masuk sini");
                                        Get.find<NotificationController>().sendMatchedFCM(
                                          idUser:data.users[data.indexUser].id,
                                          name: data.users[data.indexUser].name
                                        );
                                        showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              Future.delayed(
                                                  Duration(milliseconds: 1700),
                                                      () {
                                                    Navigator.pop(ctx);
                                                  });
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 80),
                                                child: Align(
                                                  alignment:
                                                  Alignment.topCenter,
                                                  child: Card(
                                                    child: Container(
                                                      height: 100,
                                                      width: 300,
                                                      child: Center(
                                                          child: Text(
                                                            "It's a match\n With ",
                                                            textAlign:
                                                            TextAlign.center,
                                                            style: TextStyle(
                                                                color:
                                                                primaryColor,
                                                                fontSize: 30,
                                                                decoration:
                                                                TextDecoration
                                                                    .none),
                                                          )
                                                        // .tr(args: ['${widget.users[index].name}']),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                        await docRef
                                            .doc(Get.find<LoginController>().userId)
                                            .collection("Matches")
                                            .doc(data.users[data.indexUser].id)
                                            .set(
                                            {
                                              'Matches': data.users[data.indexUser].id,
                                              'isRead': false,
                                              'userName': data.users[data.indexUser].name,
                                              'pictureUrl': (data.users[data.indexUser].imageUrl[0].runtimeType == String)?data.users[data.indexUser].imageUrl[0]:data.users[data.indexUser].imageUrl[0]['url'],
                                              'timestamp': FieldValue.serverTimestamp()
                                            },
                                            SetOptions(merge : true)
                                        );
                                        await docRef
                                            .doc(data.users[data.indexUser].id)
                                            .collection("Matches")
                                            .doc(Get.find<LoginController>().userId)
                                            .set(
                                            {
                                              'Matches': Get.find<LoginController>().userId,
                                              'userName': data.currentUser.name,
                                              'pictureUrl': (data.currentUser.imageUrl[0].runtimeType == String)?data.currentUser.imageUrl[0] : data.currentUser.imageUrl[0]['url'],
                                              'isRead': false,
                                              'timestamp': FieldValue.serverTimestamp()
                                            },
                                            SetOptions(merge : true)
                                        );
                                      }

                                      await docRef
                                          .doc(Get.find<LoginController>().userId)
                                          .collection("CheckedUser")
                                          .doc(data.users[data.indexUser].id)
                                          .set(
                                          {
                                            'userName': data.users[data.indexUser].name,
                                            'pictureUrl': (data.users[data.indexUser].imageUrl[0].runtimeType == String)?data.users[data.indexUser].imageUrl[0] : data.users[data.indexUser].imageUrl[0]['url'],
                                            'LikedUser': data.users[data.indexUser].id,
                                            'timestamp':
                                            FieldValue.serverTimestamp(),
                                          },
                                          SetOptions(merge : true)
                                      );
                                      await docRef
                                          .doc(data.users[data.indexUser].id)
                                          .collection("LikedBy")
                                          .doc(Get.find<LoginController>().userId)
                                          .set(
                                          {
                                            'userName': Get.find<TabsController>().currentUser.name,
                                            'pictureUrl': (data.currentUser.imageUrl[0].runtimeType == String)?data.currentUser.imageUrl[0] : data.currentUser.imageUrl[0]['url'],
                                            'LikedBy': Get.find<LoginController>().userId,
                                            'timestamp': FieldValue.serverTimestamp()
                                          },
                                          SetOptions(merge : true)
                                      );
                                      print("Data User index ke : " + data.indexUser.toString());
                                      data.users.removeAt(data.indexUser);
                                      data.indexImage = 0;
                                      if(data.indexUser != 0){
                                        data.indexUser--;
                                      }
                                      // if(data.indexUser+1 == data.users.length){
                                      //
                                      //   data.indexUser--;
                                      // }else{
                                      //   data.users.removeAt(data.indexUser);
                                      // }

                                      // data.userRemoved.clear();
                                      // data.userRemoved.add(data.users[data.indexUser]);
                                      print("selesai");
                                      // if (data.indexUser < (data.users.length + 1)) {
                                      //   print("clear");
                                      //   data.userRemoved.clear();
                                      //   data.userRemoved.add(data.users[data.indexUser]);
                                      //   data.users.removeAt(data.indexUser);

                                      //   if(data.users.length == 1){
                                      //     data.indexUser = 0;
                                      //   }
                                      // }
                                      setState(() {

                                      });

                                    }else{
                                      print("length 0");
                                    }

                                  }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                exceedSwipes
                    ? Align(
                  alignment: Alignment.center,
                  child: InkWell(
                      child: Container(
                        color: Colors.white.withOpacity(.3),
                        child: Dialog(
                          insetAnimationCurve: Curves.bounceInOut,
                          insetAnimationDuration: Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          backgroundColor: Colors.white,
                          child: Container(
                            height:
                            MediaQuery.of(context).size.height * .55,
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 50,
                                  color: primaryColor,
                                ),
                                Text(
                                  "You have already used the maximum number of free available swipes for 24 hrs.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontSize: 20),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.lock_outline,
                                    size: 120,
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  "To swipe more users please subscribe to one of our premium plans",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Subscription(null, null, data.items)))),
                ) : Container()
              ],
            ),
          ),
        ),
      );
    });

  }

  Widget carouselWidget(){
    return GetBuilder<TabsController>(
      builder: (data) {
        print("Index User : " + data.indexUser.toString());
        print(data.indexUser);
        data.selectedUser = data.users[data.indexUser];
        // print(data.users.length);
        // final double height = Get.height;
        return Material(
            elevation: 5,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30)
            ),
            // borderRadius: BorderRadius.all(Radius.circular(30)),
            child: SingleChildScrollView(
                child: Column(
                  children: [

                    SizedBox(
                      height: Get.height,
                      child: listUserWidget(),
                    ),

                  ],
                )
            )

        );

      },
    );
  }

  Widget listUserWidget(){
    return GetBuilder<TabsController>(builder: (data){

      return ClipRRect(
          // borderRadius: BorderRadius.all(Radius.circular(30)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)
          ),
          child:CarouselSlider(
            options: CarouselOptions(
              height: Get.height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason){
                print("Index User : " + index.toString());
                data.indexUser = index;
                data.indexImage = 0;
                data.update();
                // setState(() {});
              },
              // autoPlay: false,
            ),
            carouselController: carouselController,
            items: data.users.map((value) {
              int index = data.users.indexWhere((element) => value.id == element.id);

              bool cekPartner = false;
              UserModel userPartner;
              if(data.users[index].relasi != null && data.users[index].relasi.partner.partnerId.isNotEmpty){
                cekPartner = true;
                userPartner = data.getUserSelected(data.users[index].relasi.partner.partnerId);
                print("Cek isRelationship : " + userPartner.name);
              }
              print("Cek isRelationship : " + cekPartner.toString());
              print(index);
              print(data.users.length);
              print(data.indexUser);
              print(data.users[index].desires.length);
              print("Jarak : " + data.users[index].distanceBW.toString());


              String desiresText = "";
              String interestText = "";
              if(data.users[index] != null){
                if(data.users[index].desires.isNotEmpty){
                  for(int index2=0; index2<= data.users[index].desires.length-1; index2++){
                    if(desiresText.isEmpty){
                      desiresText = Get.find<TabsController>().capitalize(data.users[index].desires[index2]);
                      print(desiresText);
                    }else{
                      desiresText += ", " + Get.find<TabsController>().capitalize(data.users[index].desires[index2]);
                    }
                  }
                }

                if(data.users[index].interest.isNotEmpty){
                  for(int index2=0; index2<= data.users[index].interest.length-1; index2++){
                    if(interestText.isEmpty){
                      interestText = Get.find<TabsController>().capitalize(data.users[index].interest[index2]);
                    }else{
                      interestText += ", " + Get.find<TabsController>().capitalize(data.users[index].interest[index2]);
                    }
                  }
                }
              }

              // print("Index ke : " + index.toString() + " (" +data.users[index].name + ")");
              return Column(
                children: <Widget>[

                  SizedBox(
                    height: Get.height * 0.4,
                    child: listImageWidget(index)
                  ),

                  ListTile(
                    title: Text(
                      "${data.users[index].name},",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      (!cekPartner)
                          ? "${data.users[index].editInfo['showMyAge'] != null ? !data.users[index].editInfo['showMyAge'] ? data.users[index].age : "" : data.users[index].age}" +
                          ", " + data.users[index].gender + ", " + data.users[index].sexualOrientation + "\n " + data.users[index].status + ", " + "${data.users[index].distanceBW} KM away"
                          :"${data.users[index].editInfo['showMyAge'] != null ? !data.users[index].editInfo['showMyAge'] ? data.users[index].age : "" : data.users[index].age}" +
                          ", " + data.users[index].gender + ", " + data.users[index].sexualOrientation + ", " +
                          userPartner.age.toString() + ", " + userPartner.gender + ", " +  userPartner.sexualOrientation +
                          "\n\nCouple, " + "${data.users[index].distanceBW} KM away",
                      style: TextStyle(
                        // color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.normal
                      ),
                      // + "${data.selectedUser.address}"
                    ),
                  ),
                  data.users[index].editInfo['job_title'] != null
                      ? ListTile(
                    dense: true,
                    leading: Icon(Icons.work, color: primaryColor),
                    title: Text(
                      "${data.users[index].editInfo['job_title']}${data.users[index].editInfo['company'] != null ? ' at ${data.users[index].editInfo['company']}' : ''}",
                      style: TextStyle(
                          color: secondryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                      : Container(),
                  if(data.users[index].editInfo['about'] != null && data.users[index].editInfo['about'] != "")
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
                      subtitle: Text(data.users[index].editInfo['about'] ?? ""),
                    ),

                  data.users[index].editInfo['living_in'] != null
                      ? ListTile(
                      dense: true,
                      leading:
                      Icon(Icons.home, color: primaryColor),
                      title: Text(
                        "Living in " + data.users[index].editInfo['living_in'],
                        style: TextStyle(
                            color: secondryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      )
                    // .tr(args: ["${data.selectedUser.editInfo['living_in']}"]),
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
                  //           "${data.selectedUser.editInfo['DistanceVisible'] != null ? data.selectedUser.editInfo['DistanceVisible'] ? 'Less than ${data.selectedUser.distanceBW} KM away' : 'Distance not visible' : 'Less than ${data.selectedUser.distanceBW} KM away'}",
                  //           style: TextStyle(
                  //               color: secondryColor,
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.w500),
                  //         ),
                  //       )
                  //     : Container(),

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
                  if(cekPartner)
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

                          await Get.find<NotificationController>().initRelationPartner(Uid: data.users[index].relasi.partner.partnerId);
                          if(Get.find<NotificationController>().relationUser.inRelationship){
                            await Get.find<NotificationController>().initUserPartner(Uid: Get.find<NotificationController>().relationUser.partner.partnerId);
                          }
                          DocumentSnapshot userdoc = await Get.find<NotificationController>().db
                              .collection("Users").doc(data.users[index].relasi.partner.partnerId).get();
                          UserModel tempuser = UserModel.fromDocument(userdoc);
                          tempuser.distanceBW = Get.find<TabsController>().calculateDistance(
                              Get.find<TabsController>().currentUser.coordinates['latitude'],
                              Get.find<TabsController>().currentUser.coordinates['longitude'],
                              tempuser.coordinates['latitude'],
                              tempuser.coordinates['longitude']).round();
                          Get.find<NotificationController>().cekFirstInfo(tempuser);
                          Get.back();
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return Info(tempuser, data.currentUser, swipeKey);
                              });

                        },
                        icon: Icon(Icons.chevron_right_sharp,
                          size: 40,
                        ),
                      ),
                      title: Text(
                        data.users[index].relasi.partner.partnerName,
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
                            imageUrl: data.users[index].relasi.partner.partnerImage,
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

                  InkWell(
                    onTap: () => showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) => ReportUser(
                          currentUser: widget.currentUser,
                          seconduser: data.users[index],
                        )),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text(
                            "REPORT ${data.users[index].name}".toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: secondryColor),
                          ),
                        )),
                  )

                ],
              );
              // return ;
            }).toList(),
          )

      );
    });
  }

  Widget listImageWidget(int index){
    return GetBuilder<TabsController>(builder: (data){
      print("Selected Name : " + data.selectedUser.name);
      return ClipRRect(
          // borderRadius: BorderRadius.all(Radius.circular(30)),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)
          ),
          child:(data.users[index].imageUrl.length == 1)
              ?Stack(
            children: [

              Container(
                height: Get.height * .78,
                width: Get.width,
                child: CachedNetworkImage(
                  imageUrl: data.users[index].imageUrl[0]['url'] ?? "",
                  fit: BoxFit.cover,
                  useOldImageOnUrlChange: true,
                  placeholder: (context, url) =>
                      CupertinoActivityIndicator(
                        radius: 20,
                      ),
                  errorWidget: (context,
                      url, error) =>
                      Icon(Icons.error),
                ),
              ),

              if(data.users[index].imageUrl.length > 1)
                Positioned(
                    top: Get.height * 0.15,
                    right: 15,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: 4, bottom: 4,
                          right: 4, left: 4
                      ),
                      decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.all(Radius.circular(50))
                      ),
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: data.users[index].imageUrl.asMap().entries.map((entry) {
                          // print("index entry : " + entry.key.toString());
                          return GestureDetector(
                            onTap: () => carouselController.animateToPage(entry.key),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (data.indexImage == entry.key)?
                                Colors.white : Colors.white38,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                )

            ],
          )
              :
          Stack(
            children: [

              CarouselSlider(
                options: CarouselOptions(
                  height: Get.height,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index, reason){
                    print("Index Image : " + index.toString());
                    data.indexImage = index;
                    print("Index Image : " + data.indexImage.toString());
                    data.update();
                  },
                  // autoPlay: false,
                ),
                carouselController: carouselController,
                items: data.users[index].imageUrl.map((value) {

                  return Stack(
                    children: [
                      Container(
                        height: Get.height * .78,
                        width: Get.width,
                        child: CachedNetworkImage(
                          imageUrl: value['url'] ?? "",
                          fit: BoxFit.cover,
                          useOldImageOnUrlChange: true,
                          placeholder: (context, url) =>
                              CupertinoActivityIndicator(
                                radius: 20,
                              ),
                          errorWidget: (context,
                              url, error) =>
                              Icon(Icons.error),
                        ),
                      ),

                    ],
                  );
                }).toList(),
              ),

              if(data.users[index].imageUrl.length > 1)
                Positioned(
                    top: Get.height * 0.15,
                    right: 15,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: 4, bottom: 4,
                          right: 4, left: 4
                      ),
                      decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.all(Radius.circular(50))
                      ),
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: data.users[index].imageUrl.asMap().entries.map((entry) {
                          print("index entry : " + data.indexImage.toString());
                          return GestureDetector(
                            onTap: () => carouselController.animateToPage(entry.key),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (data.indexImage == entry.key)?
                                Colors.white : Colors.white38,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                )

            ],
          )

      );
    });
  }

  void _adsCheck(count) {
    print(count);
    if (count % 5 == 0) {
      // _ads.myInterstitial()
      //   ..load()
      //   ..show();
      Get.find<TabsController>().countswipe++;
    } else {
      Get.find<TabsController>().countswipe++;
    }
  }
}