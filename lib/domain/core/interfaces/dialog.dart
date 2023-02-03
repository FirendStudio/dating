import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';

import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';

Future showWelcomDialog(context) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pop(context);
        Get.find<GlobalController>().initAfterLogin();
        Get.toNamed(Routes.DASHBOARD, );
      });
      return Center(
        child: Container(
          width: 150.0,
          height: 100.0,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: <Widget>[
              Image.asset(
                "asset/auth/verified.jpg",
                height: 60,
                color: primaryColor,
                colorBlendMode: BlendMode.color,
              ),
              Text(
                "You're in!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class DialogFirstApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
      height: Get.height,
      padding: EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("asset/images/logo.png"),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "asset/images/ic_right.png",
              height: 50,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Swipe right to see next person",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                // fontFamily: Global.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "asset/images/ic_left.png",
              height: 50,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Swipe left to see previous person",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                // fontFamily: Global.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "asset/images/ic_up.png",
                    height: 50,
                  ),
                  Image.asset(
                    "asset/images/ic_down.png",
                    height: 50,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Swipe up and down to see their gallery",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                // fontFamily: Global.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "asset/images/ic_hearts.png",
              height: 50,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Click heart button to Like",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  // fontFamily: Global.font,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "asset/images/ic_delete.png",
              height: 50,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Click X button to Dislike",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                // fontFamily: Global.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        // primaryColor.withOpacity(.5),
                        // primaryColor.withOpacity(.8),
                        primaryColor,
                        primaryColor
                      ],
                    ),
                  ),
                  height: Get.height * .065,
                  width: Get.width * .75,
                  child: Center(
                    child: AutoSizeText(
                      "Got it",
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: Global.font,
                          color: textColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                onTap: () async {
                  Get.back();
                  Get.toNamed(Routes.DASHBOARD);
                },
              ),
            ),
          ],
        ),
      ),
    )));
  }
}
