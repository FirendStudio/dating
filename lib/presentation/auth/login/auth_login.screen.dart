import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';
// import 'package:apple_sign_in/apple_signs_in.dart' as i;
import 'package:the_apple_sign_in/apple_sign_in_button.dart' as i;
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';
import '../../../infrastructure/dal/util/session.dart';
import 'controllers/auth_login.controller.dart';

class AuthLoginScreen extends GetView<AuthLoginController> {
  const AuthLoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Get.put(AuthLoginController());
    return WillPopScope(
      child: Scaffold(
        appBar: new PreferredSize(
          child: new Container(
            padding: new EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            decoration: BoxDecoration(color: Colors.black),
          ),
          preferredSize: new Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.1,
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
            color: Colors.white,
          ),
          child: ListView(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: Get.width * 0.1,
                      right: Get.width * 0.1,
                    ),
                    // padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        Image.asset(
                          "asset/hookup4u-Logo-BW.png",
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(color: Colors.black
                        // gradient: LinearGradient(
                        //     colors: [primaryColor, primaryColor])),
                        ),
                  ),
                ],
              ),
              Column(children: <Widget>[
                SizedBox(
                  //height: MediaQuery.of(context).size.height * .1,
                  height: Get.height * .02,
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: Get.width * 0.1,
                    right: Get.width * 0.1,
                  ),
                  child: Text(
                    // "By tapping 'Log in', you agree with our \n Terms.Learn how we process your data in \n our Privacy Policy and Cookies Policy.".toString(),
                    "By signing in, you are indicating that you have read the Privacy Policy and agree to the Terms of Service",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: Get.height * 0.02,
                    ),
                  ),
                ),
                if (Platform.isIOS)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10.0,
                      left: Get.width * 0.1,
                      right: Get.width * 0.1,
                    ),
                    child: i.AppleSignInButton(
                      style: i.ButtonStyle.black,
                      cornerRadius: 50,
                      type: i.ButtonType.defaultButton,
                      onPressed: () => controller.handleAppleLogin(),
                    ),
                  ),
                if (Platform.isAndroid)
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: Get.width * 0.1,
                      right: Get.width * 0.1,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            // color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Colors.blue[600]!,
                                Colors.blue[600]!,
                                // Colors.lightBlue,
                                // Colors.lightBlue
                              ],
                            ),
                          ),
                          height: MediaQuery.of(context).size.height * .065,
                          width: MediaQuery.of(context).size.width * .8,
                          child: Center(
                            child: Text(
                              "LOGIN WITH GOOGLE".toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: Global.font,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        onTap: () async {
                          if (!controller.isChecked.value) {
                            Global().showInfoDialog(
                                "You must agree our terms & conditions to use this apps");
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) => Container(
                              height: 30,
                              width: 30,
                              child: Center(
                                child: CupertinoActivityIndicator(
                                  key: UniqueKey(),
                                  radius: 20,
                                  animating: true,
                                ),
                              ),
                            ),
                          );
                          await controller.handleGoogleLogin(context);
                        },
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () {
                    if (!controller.isChecked.value) {
                      Global().showInfoDialog(
                          "You must agree our terms & conditions to use this apps");
                      return;
                    }
                    Session().saveLoginType("phone");
                    Get.toNamed(Routes.AUTH_OTP, arguments: {
                      "updateNumber": false,
                    });
                  },
                  child: Container(
                    height: Get.height * .065,
                    width: Get.width * .75,
                    decoration: BoxDecoration(
                      color: textRed,
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "LOGIN WITH PHONE NUMBER",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: Global.font,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: Get.width * 0.1,
                    right: Get.width * 0.1,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.blue[800]!,
                              Colors.blue[800]!,
                            ],
                          ),
                        ),
                        height: Get.height * .065,
                        width: Get.width * .8,
                        child: Center(
                          child: Text(
                            "LOGIN WITH FACEBOOK".toString(),
                            style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontFamily: Global.font,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      onTap: () async {
                        if (!controller.isChecked.value) {
                          Global().showInfoDialog(
                              "You must agree our terms & conditions to use this apps");
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (context) => Container(
                            height: 30,
                            width: 30,
                            child: Center(
                              child: CupertinoActivityIndicator(
                                key: UniqueKey(),
                                radius: 20,
                                animating: true,
                              ),
                            ),
                          ),
                        );
                        controller.handleFacebookLogin(context);
                      },
                    ),
                  ),
                ),
              ]),
              SizedBox(
                height: Get.height * 0.01,
              ),
              Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: Get.width * 0.1,
                    right: Get.width * 0.1,
                  ),
                  child: Obx(
                    () => CheckboxListTile(
                      value: controller.isChecked.value,
                      onChanged: (bool? value) {
                        controller.isChecked.value =
                            !controller.isChecked.value;
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text("I agree to terms and conditions"),
                    ),
                  )),
              SizedBox(
                height: Get.height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => Global().launchURL(
                        "https://jablesscupid.com/privacy-policy/"), //TODO: add privacy policy
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 4,
                    width: 4,
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(100),
                    //     color: Colors.blue),
                  ),
                  GestureDetector(
                    child: Text(
                      "Terms & Conditions",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => Global().launchURL(
                      "https://jablesscupid.com/terms-conditions/",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Exit'.toString()),
              content: Text('Do you want to exit the app?'.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'.toString()),
                ),
                TextButton(
                  onPressed: () => SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop'),
                  child: Text('Yes'.toString()),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
