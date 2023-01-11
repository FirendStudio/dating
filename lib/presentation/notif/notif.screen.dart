import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hookup4u/presentation/notif/view/liked_widget.dart';
import 'package:hookup4u/presentation/notif/view/matches_widget.dart';
import '../../infrastructure/dal/util/color.dart';
import 'controllers/notif.controller.dart';

class NotifScreen extends GetView<NotifController> {
  const NotifScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(NotifController());
    return Obx(
      () => Scaffold(
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
          color: primaryColor,
          index: controller.indexNotif.value,
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
            controller.indexNotif.value = index;
          },
        ),
        body: Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (controller.indexNotif.value == 1 && controller.listLikedUser.isNotEmpty)
                Row(children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                      top: 15,
                    ),
                    child: Text(
                      "Members that liked your profile!",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
              if (controller.indexNotif.value == 0) MatchesWidget(),
              if (controller.indexNotif.value == 0 && controller.listMatchUser.length < 5)
              Container(
                padding:
                    EdgeInsets.only(top: 20, bottom: 20, right: 15, left: 15),
                margin: EdgeInsets.only(right: 15, left: 15, bottom: 30),
                decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Swipe the match to the left if you would like to permanently delete it or swipe right if you would like to block this member." +
                          "\n\nYou can unblock the member at any time if you choose.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal),
                    ),
                  ],
                ),
              ),
              if (controller.indexNotif.value == 1) LikedWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
