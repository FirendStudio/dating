// import 'dart:math';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_swiper/flutter_swiper.dart';
// import 'package:get/get.dart';
// import 'package:hookup4u/Controller/NotificationController.dart';
// import 'package:hookup4u/Controller/TabsController.dart';
// import 'package:hookup4u/Screens/Info/Information.dart';
// import 'package:hookup4u/Screens/Payment/subscriptions.dart';
// import 'package:hookup4u/models/user_model.dart';
// import 'package:hookup4u/util/color.dart';
// import 'package:swipe_stack/swipe_stack.dart';
//
// import '../Controller/LoginController.dart';
// import 'Widget/DialogFirstApp.dart';
// // import 'package:easy_localization/easy_localization.dart';
//
//
// class CardPictures extends StatefulWidget {
//   // final List<UserModel> users;
//   final UserModel currentUser;
//   final int swipedcount;
//   final Map items;
//   CardPictures(this.currentUser,
//       // this.users,
//       this.swipedcount, this.items);
//
//   @override
//   _CardPicturesState createState() => _CardPicturesState();
// }
//
// class _CardPicturesState extends State<CardPictures>
//     with AutomaticKeepAliveClientMixin<CardPictures> {
//   // TabbarState state = TabbarState();
//   bool onEnd = false;
//   // Ads _ads = new Ads();
//
//   GlobalKey<SwipeStackState> swipeKey = GlobalKey<SwipeStackState>();
//   CarouselController carouselController = CarouselController();
//   CollectionReference docRef = FirebaseFirestore.instance.collection("Users");
//
//   @override
//   bool get wantKeepAlive => true;
//   Widget build(BuildContext context) {
//     super.build(context);
//     int freeSwipe = widget.items['free_swipes'] != null
//         ? int.parse(widget.items['free_swipes']) : 10;
//     bool exceedSwipes = widget.swipedcount >= freeSwipe;
//     return GetBuilder<TabsController>(builder: (data){
//       return Scaffold(
//         backgroundColor: primaryColor,
//         // floatingActionButton: FloatingActionButton(
//         //   onPressed: () async {
//         //     await Future.delayed(Duration(seconds: 2));
//         //     Get.to(()=>DialogFirstApp());
//         //   },
//         //   child: Icon(Icons.add),
//         // ),
//         body: Container(
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(50), topRight: Radius.circular(50)),
//               color: Colors.white),
//           child: ClipRRect(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(50), topRight: Radius.circular(50)),
//             child: Stack(
//               children: [
//                 AbsorbPointer(
//                   absorbing: exceedSwipes,
//                   child: Stack(
//                     children: <Widget>[
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                         ),
//                         height: MediaQuery.of(context).size.height * .78,
//                         width: MediaQuery.of(context).size.width,
//                         child: data.users.length == 0
//                         ? Align(
//                           alignment: Alignment.center,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: <Widget>[
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: CircleAvatar(
//                                   backgroundColor: secondryColor,
//                                   radius: 40,
//                                 ),
//                               ),
//                               Text(
//                                 "There's no one new around you.",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: secondryColor,
//                                     decoration: TextDecoration.none,
//                                     fontSize: 18
//                                 ),
//                               )
//                             ],
//                           ),
//                         // ) : swiperWidget(),
//                         ) : carouselWidget(),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(25),
//                         child: Align(
//                           alignment: Alignment.bottomCenter,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: <Widget>[
//
//                               FloatingActionButton(
//                                   heroTag: UniqueKey(),
//                                   backgroundColor: Colors.white,
//                                   child: Icon(
//                                     Icons.clear,
//                                     color: Colors.red,
//                                     size: 30,
//                                   ),
//                                   onPressed: () async {
//                                     if (data.users.length > 0) {
//                                       print("object 1");
//                                       await docRef
//                                         .doc(Get.find<LoginController>().userId)
//                                         .collection("CheckedUser")
//                                         .doc(data.users[data.indexUser].id)
//                                         .set({
//                                           'userName': data.users[data.indexUser].name,
//                                           'pictureUrl': (data.users[data.indexUser].imageUrl[0].runtimeType == String)
//                                               ?data.users[data.indexUser].imageUrl[0]:data.users[data.indexUser].imageUrl[0]['url'],
//                                           'DislikedUser':
//                                           data.users[data.indexUser].id,
//                                           'timestamp': DateTime.now(),
//                                         }, SetOptions(merge : true)
//                                       );
//
//                                       if (data.indexUser < data.users.length) {
//                                         data.userRemoved.clear();
//                                         setState(() {
//                                           data.userRemoved.add(data.users[data.indexUser]);
//                                           data.users.removeAt(data.indexUser);
//                                         });
//                                       }
//                                       // swipeKey.currentState.swipeLeft();
//
//                                     }
//                                   }),
//                               FloatingActionButton(
//                                 heroTag: UniqueKey(),
//                                 backgroundColor: Colors.white,
//                                 child: Icon(
//                                   Icons.favorite,
//                                   color: Colors.red,
//                                   size: 30,
//                                 ),
//                                 onPressed: () async {
//                                   if (data.users.length > 0) {
//                                     print(data.users[data.indexUser].name);
//                                     // swipeKey.currentState.swipeRight();
//                                     print(data.users[data.indexUser].name);
//                                     if (data.likedByList.contains(data.users[data.indexUser].id)) {
//                                       print("Masuk sini");
//                                       showDialog(
//                                           context: context,
//                                           builder: (ctx) {
//                                             Future.delayed(
//                                                 Duration(milliseconds: 1700),
//                                                     () {
//                                                   Navigator.pop(ctx);
//                                                 });
//                                             return Padding(
//                                               padding: const EdgeInsets.only(
//                                                   top: 80),
//                                               child: Align(
//                                                 alignment:
//                                                 Alignment.topCenter,
//                                                 child: Card(
//                                                   child: Container(
//                                                     height: 100,
//                                                     width: 300,
//                                                     child: Center(
//                                                         child: Text(
//                                                           "It's a match\n With ",
//                                                           textAlign:
//                                                           TextAlign.center,
//                                                           style: TextStyle(
//                                                               color:
//                                                               primaryColor,
//                                                               fontSize: 30,
//                                                               decoration:
//                                                               TextDecoration
//                                                                   .none),
//                                                         )
//                                                       // .tr(args: ['${widget.users[index].name}']),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           });
//                                       await docRef
//                                           .doc(Get.find<LoginController>().userId)
//                                           .collection("Matches")
//                                           .doc(data.users[data.indexUser].id)
//                                           .set(
//                                           {
//                                             'Matches': data.users[data.indexUser].id,
//                                             'isRead': false,
//                                             'userName': data.users[data.indexUser].name,
//                                             'pictureUrl': (data.users[data.indexUser].imageUrl[0].runtimeType == String)?data.users[data.indexUser].imageUrl[0]:data.users[data.indexUser].imageUrl[0]['url'],
//                                             'timestamp': FieldValue.serverTimestamp()
//                                           },
//                                           SetOptions(merge : true)
//                                       );
//                                       await docRef
//                                           .doc(data.users[data.indexUser].id)
//                                           .collection("Matches")
//                                           .doc(Get.find<LoginController>().userId)
//                                           .set(
//                                           {
//                                             'Matches': Get.find<LoginController>().userId,
//                                             'userName': data.currentUser.name,
//                                             'pictureUrl': (data.currentUser.imageUrl[0].runtimeType == String)?data.currentUser.imageUrl[0] : data.currentUser.imageUrl[0]['url'],
//                                             'isRead': false,
//                                             'timestamp': FieldValue.serverTimestamp()
//                                           },
//                                           SetOptions(merge : true)
//                                       );
//                                     }
//
//                                     await docRef
//                                         .doc(Get.find<LoginController>().userId)
//                                         .collection("CheckedUser")
//                                         .doc(data.users[data.indexUser].id)
//                                         .set(
//                                         {
//                                           'userName': data.users[data.indexUser].name,
//                                           'pictureUrl': (data.users[data.indexUser].imageUrl[0].runtimeType == String)?data.users[data.indexUser].imageUrl[0] : data.users[data.indexUser].imageUrl[0]['url'],
//                                           'LikedUser': data.users[data.indexUser].id,
//                                           'timestamp':
//                                           FieldValue.serverTimestamp(),
//                                         },
//                                         SetOptions(merge : true)
//                                     );
//                                     await docRef
//                                         .doc(data.users[data.indexUser].id)
//                                         .collection("LikedBy")
//                                         .doc(Get.find<LoginController>().userId)
//                                         .set(
//                                         {
//                                           'userName': Get.find<TabsController>().currentUser.name,
//                                           'pictureUrl': (data.currentUser.imageUrl[0].runtimeType == String)?data.currentUser.imageUrl[0] : data.currentUser.imageUrl[0]['url'],
//                                           'LikedBy': Get.find<LoginController>().userId,
//                                           'timestamp': FieldValue.serverTimestamp()
//                                         },
//                                         SetOptions(merge : true)
//                                     );
//                                     if(data.indexUser+1 == data.users.length){
//                                       data.users.removeAt(data.indexUser);
//                                       if(data.indexUser != 0){
//                                         data.indexUser--;
//                                       }
//                                     }else{
//                                       data.users.removeAt(data.indexUser);
//                                     }
//                                     data.indexImage = 0;
//                                     // data.userRemoved.clear();
//                                     // data.userRemoved.add(data.users[data.indexUser]);
//                                     print("selesai");
//                                     // if (data.indexUser < (data.users.length + 1)) {
//                                     //   print("clear");
//                                     //   data.userRemoved.clear();
//                                     //   data.userRemoved.add(data.users[data.indexUser]);
//                                     //   data.users.removeAt(data.indexUser);
//                                     //   data.indexImage = 0;
//                                     //   if(data.users.length == 1){
//                                     //     data.indexUser = 0;
//                                     //   }
//                                     // }
//                                     setState(() {
//
//                                     });
//
//                                   }
//                                 }),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 exceedSwipes
//                 ? Align(
//                   alignment: Alignment.center,
//                   child: InkWell(
//                       child: Container(
//                         color: Colors.white.withOpacity(.3),
//                         child: Dialog(
//                           insetAnimationCurve: Curves.bounceInOut,
//                           insetAnimationDuration: Duration(seconds: 2),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20)),
//                           backgroundColor: Colors.white,
//                           child: Container(
//                             height:
//                             MediaQuery.of(context).size.height * .55,
//                             child: Column(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceEvenly,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.error_outline,
//                                   size: 50,
//                                   color: primaryColor,
//                                 ),
//                                 Text(
//                                   "You have already used the maximum number of free available swipes for 24 hrs.",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey,
//                                       fontSize: 20),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Icon(
//                                     Icons.lock_outline,
//                                     size: 120,
//                                     color: primaryColor,
//                                   ),
//                                 ),
//                                 Text(
//                                   "To swipe more users please subscribe to one of our premium plans",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       color: primaryColor,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 20),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   Subscription(null, null, data.items)))),
//                 ) : Container()
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//
//   }
//
//   Widget carouselWidget(){
//     return GetBuilder<TabsController>(
//       builder: (data) {
//         print(data.indexUser);
//         data.selectedUser = data.users[data.indexUser];
//         print(data.users.length);
//         // print(data.users.length);
//         // final double height = Get.height;
//         return Container(
//             padding: EdgeInsets.all(18),
//             child: Material(
//                 elevation: 5,
//                 borderRadius: BorderRadius.all(Radius.circular(30)),
//                 child: Container(
//                   child: Stack(
//                     children: <Widget>[
//                       listUserWidget(),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 0),
//                         child: Align(
//                             alignment:
//                             Alignment.bottomLeft,
//                             child: Stack(
//                               children: [
//
//                                 Container(
//                                   height: 90,
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             gradient: LinearGradient(
//                                                 colors: [
//                                                   Colors.black26,
//                                                   Colors.black12,
//                                                 ],
//                                                 begin: const FractionalOffset(0.0, 0.0),
//                                                 end: const FractionalOffset(1.0, 0.0),
//                                                 stops: [0.0, 1.0],
//                                                 tileMode: TileMode.clamp),
//                                             borderRadius: BorderRadius.all(Radius.circular(20))
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                                 ListTile(
//                                     onTap: () async {
//                                       print("test");
//                                       // await Get.find<NotificationController>().db
//                                       //     .collection("Users").doc(index.id).get();
//                                       // _ads.myInterstitial()
//                                       //   ..load()
//                                       //   ..show();
//                                       await Get.find<NotificationController>().initRelationPartner(Uid: data.selectedUser.id);
//                                       if(Get.find<NotificationController>().relationUser.inRelationship){
//                                         await Get.find<NotificationController>().initUserPartner(Uid: Get.find<NotificationController>().relationUser.partner.partnerId);
//                                       }
//                                       DocumentSnapshot userdoc = await Get.find<NotificationController>().db
//                                           .collection("Users").doc(data.selectedUser.id).get();
//                                       UserModel tempuser = UserModel.fromDocument(userdoc);
//                                       tempuser.distanceBW = Get.find<TabsController>().calculateDistance(
//                                           Get.find<TabsController>().currentUser.coordinates['latitude'],
//                                           Get.find<TabsController>().currentUser.coordinates['longitude'],
//                                           tempuser.coordinates['latitude'],
//                                           tempuser.coordinates['longitude']).round();
//                                       Get.find<NotificationController>().cekFirstInfo(tempuser);
//                                       showDialog(
//                                           barrierDismissible: false,
//                                           context: context,
//                                           builder: (context) {
//                                             return Info(tempuser, data.currentUser, swipeKey);
//                                           });
//                                     },
//                                     title: Text(
//                                       "${data.selectedUser.name}, " + data.selectedUser.age.toString(),
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 25,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     subtitle: Text(
//                                       "${data.selectedUser.address}",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 20,
//                                       ),
//                                     )
//                                 ),
//
//                               ],
//                             )
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//             )
//         );
//
//       },
//     );
//   }
//
//   Widget listUserWidget(){
//     return GetBuilder<TabsController>(builder: (data){
//       return ClipRRect(
//           borderRadius: BorderRadius.all(Radius.circular(30)),
//           child:CarouselSlider(
//             options: CarouselOptions(
//               height: Get.height,
//               viewportFraction: 1.0,
//               enlargeCenterPage: false,
//               scrollDirection: Axis.horizontal,
//               onPageChanged: (index, reason){
//                 print("Index User : " + index.toString());
//                 data.indexUser = index;
//                 data.indexImage = 0;
//                 data.update();
//                 // setState(() {});
//               },
//               // autoPlay: false,
//             ),
//             carouselController: carouselController,
//             items: data.users.map((value) {
//               int index = data.users.indexWhere((element) => value.id == element.id);
//               // print("Index ke : " + index.toString() + " (" +data.users[index].name + ")");
//               return listImageWidget(index);
//             }).toList(),
//           )
//
//       );
//     });
//   }
//
//   Widget listImageWidget(int index){
//     return GetBuilder<TabsController>(builder: (data){
//       print("Selected Name : " + data.selectedUser.name);
//       return ClipRRect(
//         borderRadius: BorderRadius.all(Radius.circular(30)),
//         child:CarouselSlider(
//           options: CarouselOptions(
//             height: Get.height,
//             viewportFraction: 1.0,
//             enlargeCenterPage: false,
//             scrollDirection: Axis.vertical,
//             onPageChanged: (index, reason){
//               print("Index Image : " + index.toString());
//               data.indexImage = index;
//               data.update();
//             },
//             // autoPlay: false,
//           ),
//           carouselController: carouselController,
//           items: data.users[index].imageUrl.map((value) {
//             return Stack(
//               children: [
//
//                 Container(
//                   height: Get.height * .78,
//                   width: Get.width,
//                   child: CachedNetworkImage(
//                     imageUrl: value['url'] ?? "",
//                     fit: BoxFit.cover,
//                     useOldImageOnUrlChange: true,
//                     placeholder: (context, url) =>
//                         CupertinoActivityIndicator(
//                           radius: 20,
//                         ),
//                     errorWidget: (context,
//                         url, error) =>
//                         Icon(Icons.error),
//                   ),
//                 ),
//
//                 if(data.users[index].imageUrl.length > 1)
//                   Positioned(
//                     top: Get.height * 0.35,
//                     right: 15,
//                     child: Container(
//                       padding: EdgeInsets.only(
//                           top: 8, bottom: 8,
//                           right: 8, left: 8
//                       ),
//                       decoration: BoxDecoration(
//                           color: Colors.black45,
//                           borderRadius: BorderRadius.all(Radius.circular(50))
//                       ),
//                       child:Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: data.users[index].imageUrl.asMap().entries.map((entry) {
//                           return GestureDetector(
//                             onTap: () => carouselController.animateToPage(entry.key),
//                             child: Container(
//                               width: 12.0,
//                               height: 12.0,
//                               margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: (data.indexImage == entry.key)?
//                                 Colors.white : Colors.white38,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     )
//                   )
//
//               ],
//             );
//           }).toList(),
//         )
//
//       );
//     });
//   }
//
//   void _adsCheck(count) {
//     print(count);
//     if (count % 5 == 0) {
//       // _ads.myInterstitial()
//       //   ..load()
//       //   ..show();
//       Get.find<TabsController>().countswipe++;
//     } else {
//       Get.find<TabsController>().countswipe++;
//     }
//   }
// }
