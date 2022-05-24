import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/NotificationController.dart';
import 'package:hookup4u/Controller/TabsController.dart';
import 'package:hookup4u/Screens/Information.dart';
import 'package:hookup4u/Screens/Payment/subscriptions.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:hookup4u/ads/ads.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:swipe_stack/swipe_stack.dart';

import '../Controller/LoginController.dart';
// import 'package:easy_localization/easy_localization.dart';


class CardPictures extends StatefulWidget {
  final List<UserModel> users;
  final UserModel currentUser;
  final int swipedcount;
  final Map items;
  CardPictures(this.currentUser, this.users, this.swipedcount, this.items);

  @override
  _CardPicturesState createState() => _CardPicturesState();
}

class _CardPicturesState extends State<CardPictures>
    with AutomaticKeepAliveClientMixin<CardPictures> {
  // TabbarState state = TabbarState();
  bool onEnd = false;
  // Ads _ads = new Ads();

  GlobalKey<SwipeStackState> swipeKey = GlobalKey<SwipeStackState>();
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    super.build(context);
    int freeSwipe = widget.items['free_swipes'] != null
        ? int.parse(widget.items['free_swipes'])
        : 10;
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
                        height: MediaQuery.of(context).size.height * .78,
                        width: MediaQuery.of(context).size.width,
                        child:
                        //onEnd ||
                        widget.users.length == 0
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
                                    fontSize: 18),
                              )
                            ],
                          ),
                        )
                            : SwipeStack(
                          key: swipeKey,
                          children: widget.users.map((index) {
                            // User user;
                            return SwiperItem(builder:
                                (SwiperPosition position,
                                double progress) {
                              return Material(
                                  elevation: 5,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(30)),
                                  child: Container(
                                    child: Stack(
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(30)),
                                          child: Swiper(
                                            customLayoutOption:
                                            CustomLayoutOption(
                                              startIndex: 0,
                                            ),
                                            key: UniqueKey(),
                                            physics: NeverScrollableScrollPhysics(),
                                            itemBuilder: (BuildContext context, int index2) {
                                              return Container(
                                                height: MediaQuery.of(context).size.height * .78,
                                                width: MediaQuery.of(context).size.width,
                                                child: CachedNetworkImage(
                                                  imageUrl: index.imageUrl[index2]['url'] ?? "",
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
                                                // child: Image.network(
                                                //   index.imageUrl[index2],
                                                //   fit: BoxFit.cover,
                                                // ),
                                              );
                                            },
                                            itemCount: index.imageUrl.length,
                                            pagination: new SwiperPagination(
                                                alignment: Alignment.bottomCenter,
                                                builder: DotSwiperPaginationBuilder(
                                                    activeSize: 13,
                                                    color: secondryColor,
                                                    activeColor: primaryColor)),
                                            control: new SwiperControl(
                                              color: primaryColor,
                                              disableColor:
                                              secondryColor,
                                            ),
                                            loop: false,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              48.0),
                                          child: position.toString() ==
                                              "SwiperPosition.Left"
                                              ? Align(
                                            alignment: Alignment
                                                .topRight,
                                            child:
                                            Transform.rotate(
                                              angle: pi / 8,
                                              child: Container(
                                                height: 40,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape
                                                        .rectangle,
                                                    border: Border.all(
                                                        width: 2,
                                                        color: Colors
                                                            .red)),
                                                child: Center(
                                                  child: Text(
                                                      "NOPE",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .red,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize:
                                                          32)),
                                                ),
                                              ),
                                            ),
                                          )
                                              : position.toString() ==
                                              "SwiperPosition.Right"
                                              ? Align(
                                            alignment:
                                            Alignment
                                                .topLeft,
                                            child: Transform
                                                .rotate(
                                              angle: -pi / 8,
                                              child:
                                              Container(
                                                height: 40,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape
                                                        .rectangle,
                                                    border: Border.all(
                                                        width:
                                                        2,
                                                        color:
                                                        Colors.lightBlueAccent)),
                                                child: Center(
                                                  child: Text(
                                                      "LIKE",
                                                      style: TextStyle(
                                                          color:
                                                          Colors.lightBlueAccent,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 32)),
                                                ),
                                              ),
                                            ),
                                          )
                                              : Container(),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              bottom: 10),
                                          child: Align(
                                              alignment:
                                              Alignment.bottomLeft,
                                              child: ListTile(
                                                  onTap: () async {
                                                    print("test");
                                                    await Get.find<NotificationController>().db
                                                        .collection("Users").doc(index.id).get();
                                                    // _ads.myInterstitial()
                                                    //   ..load()
                                                    //   ..show();
                                                    DocumentSnapshot userdoc = await Get.find<NotificationController>().db
                                                        .collection("Users").doc(index.id).get();
                                                    UserModel tempuser = UserModel.fromDocument(userdoc);
                                                    tempuser.distanceBW = Get.find<TabsController>().calculateDistance(
                                                        Get.find<TabsController>().currentUser.coordinates['latitude'],
                                                        Get.find<TabsController>().currentUser.coordinates['longitude'],
                                                        tempuser.coordinates['latitude'],
                                                        tempuser.coordinates['longitude']).round();
                                                    showDialog(
                                                        barrierDismissible: false,
                                                        context: context,
                                                        builder: (context) {
                                                          return Info(
                                                              tempuser,
                                                              widget.currentUser,
                                                              swipeKey);
                                                        });
                                                  },
                                                  title: Text(
                                                    // "${index.name}, ${index.editInfo['showMyAge'] != null ? !index.editInfo['showMyAge'] ? index.age : "" : index.age}",
                                                    index.age.toString(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 25,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                  subtitle: Text(
                                                    "${index.address}",
                                                    style: TextStyle(
                                                      color:
                                                      Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ))),
                                        ),
                                      ],
                                    ),
                                  ));
                            });
                          }).toList(growable: true),
                          threshold: 30,
                          maxAngle: 100,
                          //animationDuration: Duration(milliseconds: 400),
                          visibleCount: 5,
                          historyCount: 1,
                          stackFrom: StackFrom.Right,
                          translationInterval: 5,
                          scaleInterval: 0.08,
                          onSwipe: (int index, SwiperPosition position) async {
                            _adsCheck(data.countswipe);
                            print(position);
                            print(widget.users[index].name);
                            CollectionReference docRef = FirebaseFirestore.instance.collection("Users");
                            if (position == SwiperPosition.Left) {
                              await docRef
                                  .doc(Get.find<LoginController>().userId)
                                  .collection("CheckedUser")
                                  .doc(widget.users[index].id)
                                  .set({
                                'userName': widget.users[index].name,
                                'pictureUrl': (widget.users[index].imageUrl[0].runtimeType == String)?widget.users[index].imageUrl[0]:widget.users[index].imageUrl[0]['url'],
                                'DislikedUser':
                                widget.users[index].id,
                                'timestamp': DateTime.now(),
                              },
                                  SetOptions(merge : true)
                              );

                              if (index < widget.users.length) {
                                data.userRemoved.clear();
                                setState(() {
                                  data.userRemoved.add(widget.users[index]);
                                  widget.users.removeAt(index);
                                });
                              }
                            } else if (position == SwiperPosition.Right) {
                              if (data.likedByList.contains(widget.users[index].id)) {
                                print("Masuk sini");
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
                                    .doc(widget.users[index].id)
                                    .set(
                                    {
                                      'Matches': widget.users[index].id,
                                      'isRead': false,
                                      'userName': widget.users[index].name,
                                      'pictureUrl': (widget.users[index].imageUrl[0].runtimeType == String)?widget.users[index].imageUrl[0]:widget.users[index].imageUrl[0]['url'],
                                      'timestamp': FieldValue.serverTimestamp()
                                    },
                                    SetOptions(merge : true)
                                );
                                await docRef
                                    .doc(widget.users[index].id)
                                    .collection("Matches")
                                    .doc(Get.find<LoginController>().userId)
                                    .set(
                                    {
                                      'Matches': Get.find<LoginController>().userId,
                                      'userName': widget.currentUser.name,
                                      'pictureUrl': (widget.currentUser.imageUrl[0].runtimeType == String)?widget.currentUser.imageUrl[0] : widget.currentUser.imageUrl[0]['url'],
                                      'isRead': false,
                                      'timestamp': FieldValue.serverTimestamp()
                                    },
                                    SetOptions(merge : true)
                                );
                              }

                              await docRef
                                  .doc(Get.find<LoginController>().userId)
                                  .collection("CheckedUser")
                                  .doc(widget.users[index].id)
                                  .set(
                                  {
                                    'userName': widget.users[index].name,
                                    'pictureUrl': (widget.users[index].imageUrl[0].runtimeType == String)?widget.users[index].imageUrl[0] : widget.users[index].imageUrl[0]['url'],
                                    'LikedUser': widget.users[index].id,
                                    'timestamp':
                                    FieldValue.serverTimestamp(),
                                  },
                                  SetOptions(merge : true)
                              );
                              await docRef
                                  .doc(widget.users[index].id)
                                  .collection("LikedBy")
                                  .doc(Get.find<LoginController>().userId)
                                  .set(
                                  {
                                    'userName': Get.find<TabsController>().currentUser.name,
                                    'pictureUrl': (widget.currentUser.imageUrl[0].runtimeType == String)?widget.currentUser.imageUrl[0] : widget.currentUser.imageUrl[0]['url'],
                                    'LikedBy': Get.find<LoginController>().userId,
                                    'timestamp': FieldValue.serverTimestamp()
                                  },
                                  SetOptions(merge : true)
                              );
                              if (index < widget.users.length) {
                                data.userRemoved.clear();
                                setState(() {
                                  data.userRemoved.add(widget.users[index]);
                                  widget.users.removeAt(index);
                                });
                              }
                            } else
                              debugPrint("onSwipe $index $position");
                          },
                          onRewind: (int index, SwiperPosition position) {
                            swipeKey.currentContext.dependOnInheritedWidgetOfExactType();
                            widget.users.insert(index, data.userRemoved[0]);
                            setState(() {
                              data.userRemoved.clear();
                            });
                            debugPrint("onRewind $index $position");
                            print(widget.users[index].id);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              widget.users.length != 0
                                  ? FloatingActionButton(
                                  heroTag: UniqueKey(),
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    data.userRemoved.length > 0
                                        ? Icons.replay
                                        : Icons.not_interested,
                                    color: data.userRemoved.length > 0
                                        ? Colors.amber
                                        : secondryColor,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (data.userRemoved.length > 0) {
                                      swipeKey.currentState.rewind();
                                    }
                                  })
                                  : FloatingActionButton(
                                heroTag: UniqueKey(),
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                onPressed: () {},
                              ),
                              FloatingActionButton(
                                  heroTag: UniqueKey(),
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    if (widget.users.length > 0) {
                                      print("object");
                                      swipeKey.currentState.swipeLeft();
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
                                  onPressed: () {
                                    if (widget.users.length > 0) {
                                      swipeKey.currentState.swipeRight();
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
                                  Subscription(null, null, widget.items)))),
                )
                    : Container()
              ],
            ),
          ),
        ),
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
