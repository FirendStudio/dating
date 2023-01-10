import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:apple_sign_in/apple_sign_in.dart' as i;
import '../../../infrastructure/dal/util/Global.dart';
import 'controllers/auth_login.controller.dart';

class AuthLoginScreen extends GetView<AuthLoginController> {
  const AuthLoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
                      onPressed: () async {
                        final User currentUser = await loginController
                            .handleAppleLogin(_scaffoldKey)
                            .catchError((onError) {
                          SnackBar snackBar =
                              SnackBar(content: Text(onError.toString()));
                          _scaffoldKey.currentState.showSnackBar(snackBar);
                        });
                        if (currentUser != null) {
                          print(
                              'username ${currentUser.displayName} \n photourl ${currentUser.photoURL}');
                          // await _setDataUser(currentUser);
                          if (currentUser.providerData.length > 1) {
                            for (int index = 0;
                                index <= currentUser.providerData.length - 1;
                                index++) {
                              if (currentUser.providerData.length - 1 ==
                                  index) {
                                await Get.find<LoginController>()
                                    .navigationCheck(
                                        currentUser,
                                        context,
                                        currentUser
                                            .providerData[index].providerId,
                                        false);
                                break;
                              }
                              await Get.find<LoginController>().navigationCheck(
                                  currentUser,
                                  context,
                                  currentUser.providerData[index].providerId,
                                  true);
                            }
                            return;
                          }
                          loginController.navigationCheck(
                              currentUser, context, "apple.com", false);
                        }
                      },
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
                                    ])),
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
                            ))),
                        onTap: () async {
                          if (!controller.isChecked.value) {
                            Get.snackbar("Information",
                                "You must agree our terms & conditions to use this apps",
                                colorText: Colors.white);
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
                                  ))));
                          await loginController.handleGoogleLogin(context);
                        },
                      ),
                    ),
                  ),
                InkWell(
                    onTap: () {
                      if (!controller.isChecked.value) {
                        Get.snackbar("Information",
                            "You must agree our terms & conditions to use this apps");
                        return;
                      }
                      bool updateNumber = false;
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => OTP(updateNumber)));
                    },
                    child: Container(
                        height: MediaQuery.of(context).size.height * .065,
                        width: MediaQuery.of(context).size.width * .75,
                        padding: EdgeInsets.only(
                            // left: Get.width * 0.1,
                            // right: Get.width * 0.1,
                            ),
                        decoration: BoxDecoration(
                            color: textRed,
                            // border: Border.all(
                            //   color: Colors.red[500],
                            // ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: Center(
                          child: Text("LOGIN WITH PHONE NUMBER",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: Global.font,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ))),
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
                                  ])),
                          height: MediaQuery.of(context).size.height * .065,
                          width: MediaQuery.of(context).size.width * .8,
                          child: Center(
                              child: Text(
                            "LOGIN WITH FACEBOOK".toString(),
                            style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontFamily: Global.font,
                                fontWeight: FontWeight.bold),
                          ))),
                      onTap: () async {
                        if (!controller.isChecked.value) {
                          Get.snackbar("Information",
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
                                ))));
                        await loginController
                            .handleFacebookLogin(context)
                            .then((user) async {
                          if (user.providerData.length > 1) {
                            for (int index = 0;
                                index <= user.providerData.length - 1;
                                index++) {
                              if (user.providerData.length - 1 == index) {
                                await Get.find<LoginController>()
                                    .navigationCheck(
                                        user,
                                        context,
                                        user.providerData[index].providerId,
                                        false);
                                break;
                              }
                              await Get.find<LoginController>().navigationCheck(
                                  user,
                                  context,
                                  user.providerData[index].providerId,
                                  true);
                            }
                            return;
                          }
                          loginController.navigationCheck(
                              user, context, 'fb', false);
                        }).then((_) {
                          Navigator.pop(context);
                        }).catchError((e) {
                          Navigator.pop(context);
                        });
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
                      value: loginController.isChecked.value,
                      onChanged: (bool value) {
                        loginController.isChecked.value =
                            !loginController.isChecked.value;
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
                    onTap: () => loginController.launchURL(
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
                    onTap: () => loginController.launchURL(
                        "https://jablesscupid.com/terms-conditions/"), //TODO: add Terms and conditions
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
