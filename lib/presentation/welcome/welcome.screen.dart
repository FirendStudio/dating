import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';
import '../../infrastructure/dal/util/color.dart';
import 'controllers/welcome.controller.dart';

class WelcomeScreen extends GetView<WelcomeController> {
  const WelcomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: Get.width * 0.1,
                right: Get.width * 0.1,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * .6,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: Get.height * 0.1,
                      ),
                      Container(
                          padding: EdgeInsets.all(12),
                          child: Image.asset(
                            "asset/images/logo1.png",
                          )),
                      ListTile(
                        contentPadding: EdgeInsets.all(8),
                        title: Text(
                          "Are you 18 years of age? In order to use this app you must be 18 years old or over.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Get.height * 0.027,
                              fontFamily: "Arial",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: Get.height * 0.01,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.all(8),
                        title: Text(
                          "If you aren't please leave and do not continue.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Get.height * 0.027,
                              fontFamily: "Arial",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 0),
              child: Align(
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
                                primaryColor.withOpacity(.5),
                                primaryColor.withOpacity(.8),
                                primaryColor,
                                primaryColor
                              ])),
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                          child: Text(
                        "I'm 18+",
                        style: TextStyle(
                            fontSize: Get.height * 0.025,
                            color: textColor,
                            fontFamily: "Arial",
                            fontWeight: FontWeight.bold),
                      ))),
                  onTap: () async {
                    Get.toNamed(Routes.AUTH_LOGIN);

                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
