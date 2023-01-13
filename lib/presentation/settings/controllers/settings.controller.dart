import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hookup4u/presentation/screens.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../../domain/core/model/custom_web_view.dart';
import '../../../infrastructure/dal/controller/global_controller.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/general.dart';
import '../../../infrastructure/dal/util/session.dart';

class SettingsController extends GetxController {
  static const your_client_id = '709280423766575';
  static const your_redirect_url =
      'https://jablesscupid.firebaseapp.com/__/auth/handler';
  RxBool isChecked = false.obs;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      // 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  List<String> listSelectedGender = [];
  GoogleSignInAccount? googleUser;
  Map<String, dynamic> changeValues = {};
  RxInt distance = 0.obs;
  @override
  void onInit() {
    super.onInit();
    changeValues = {};
    listSelectedGender = [];
    // for (int i = 0; i <= widget.currentUser.showMe.length - 1; i++) {
    //   selected.add(widget.currentUser.showMe[i]);

    //   for (int j = 0; j <= listShowMe.length - 1; j++) {
    //     if (widget.currentUser.showMe[i] == listShowMe[j]['name']) {
    //       listShowMe[j]['ontap'] = true;
    //       break;
    //     }
    //   }
    // }

    // freeR = widget.items['free_radius'] != null
    //     ? int.parse(widget.items['free_radius'])
    //     : 400;
    // paidR = widget.items['paid_radius'] != null
    //     ? int.parse(widget.items['paid_radius'])
    //     : 400;
    // if (!widget.isPurchased && widget.currentUser.maxDistance > freeR) {
    //   widget.currentUser.maxDistance = freeR.round();
    //   changeValues.addAll({'maximum_distance': freeR.round()});
    // } else if (widget.isPurchased && widget.currentUser.maxDistance >= paidR) {
    //   widget.currentUser.maxDistance = paidR.round();
    //   changeValues.addAll({'maximum_distance': paidR.round()});
    // }
    // _showMe = widget.currentUser.showMe;
    // distance = widget.currentUser.maxDistance.round();
    // ageRange = RangeValues(double.parse(widget.currentUser.ageRange['min']),
    //     (double.parse(widget.currentUser.ageRange['max'])));
    // Get.find<HomeController>().ageMin =
    //     int.parse(widget.currentUser.ageRange['min']);
    // Get.find<HomeController>().ageMax =
    //     int.parse(widget.currentUser.ageRange['max']);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> connectedAccountWidget() async {
    await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context2, StateSetter setState2) {
              return Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Connected Accounts",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: () async {
                            if (globalController
                                    .currentUser.value?.loginID?['fb'] ==
                                "") {
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
                              await handleFacebookLogin(context);
                            } else {
                              Global().showInfoDialog(
                                  "You have connected to Facebook");
                            }
                          },
                          child: Container(
                            width: 250,
                            padding: EdgeInsets.only(
                                left: 8, right: 8, bottom: 8, top: 8),
                            decoration: BoxDecoration(
                                // color: (globalController.currentUser.value?.loginID?['fb'] == "")?Colors.red : Colors.greenAccent,
                                // border: Border.all(
                                //   color: Colors.red[500],
                                // ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.grey[400]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset("asset/images/fb.png", height: 25),
                                Text(
                                  "Facebook",
                                  style: TextStyle(
                                      color: (globalController.currentUser.value
                                                  ?.loginID?['fb'] ==
                                              "")
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                if (globalController
                                        .currentUser.value?.loginID?['fb'] ==
                                    "")
                                  Text(""),
                                if (globalController
                                        .currentUser.value?.loginID?['fb'] !=
                                    "")
                                  Icon(
                                    Icons.check_box,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Platform.isIOS
                            ? InkWell(
                                onTap: () async {
                                  if (globalController.currentUser.value
                                          ?.loginID?['apple'] ==
                                      "") {
                                    await handleAppleLogin();
                                  } else {
                                    Get.snackbar(
                                      "Information",
                                      "You have connected to Apple",
                                    );
                                  }
                                },
                                child: Container(
                                  width: 250,
                                  padding: EdgeInsets.only(
                                      left: 8, right: 8, bottom: 8, top: 8),
                                  decoration: BoxDecoration(
                                      // color: (globalController.currentUser.value?.loginID?['apple'] == "")?Colors.red : Colors.greenAccent,
                                      // border: Border.all(
                                      //   color: Colors.red[500],
                                      // ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Colors.grey[400]),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset("asset/images/apple.png",
                                          height: 25),
                                      Text(
                                        "Apple",
                                        style: TextStyle(
                                            color: (globalController
                                                        .currentUser
                                                        .value
                                                        ?.loginID?['apple'] ==
                                                    "")
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      if (globalController.currentUser.value
                                              ?.loginID?['apple'] ==
                                          "")
                                        Text(""),
                                      if (globalController.currentUser.value
                                              ?.loginID?['apple'] !=
                                          "")
                                        Icon(
                                          Icons.check_box,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        Platform.isAndroid
                            ? InkWell(
                                onTap: () async {
                                  if (globalController.currentUser.value
                                          ?.loginID?['google'] ==
                                      "") {
                                    handleGoogleLogin(context);
                                  } else {
                                    Get.snackbar("Information",
                                        "You have connected to Google");
                                  }
                                },
                                child: Container(
                                  width: 250,
                                  padding: EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    bottom: 8,
                                    top: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    color: Colors.grey[400],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        "asset/images/ic_google.png",
                                        height: 25,
                                      ),
                                      Text(
                                        "Google",
                                        style: TextStyle(
                                          color: (globalController
                                                      .currentUser
                                                      .value
                                                      ?.loginID?['google'] ==
                                                  "")
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      if (globalController.currentUser.value
                                              ?.loginID?['google'] ==
                                          "")
                                        Text(""),
                                      if (globalController.currentUser.value
                                              ?.loginID?['google'] !=
                                          "")
                                        Icon(
                                          Icons.check_box,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: new BoxDecoration(
                            shape: BoxShape
                                .circle, // You can use like this way or like the below line
                            //borderRadius: new BorderRadius.circular(30.0),
                            color: Colors.black,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          insetAnimationCurve: Curves.decelerate,
          actions: [],
        );
      },
    );
  }

  Future<void> handleAppleLogin() async {
    User? user;
    final AuthorizationResult result = await TheAppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);
    try {
      switch (result.status) {
        case AuthorizationStatus.authorized:

          // Store user ID
          // Session().saveLoginType("apple");
          final AppleIdCredential appleIdCredential = result.credential!;

          OAuthProvider oAuthProvider = OAuthProvider("apple.com");
          final AuthCredential credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode!),
          );

          user = (await Get.find<GlobalController>()
                  .auth
                  .signInWithCredential(credential))
              .user;
          print('username ${user?.displayName} \n photourl ${user?.photoURL}');
          // await _setDataUser(currentUser);
          if (user == null) {
            return;
          }
          var loginID = {
            "apple": user.uid,
          };
          await queryCollectionDB("Users")
              .doc(globalController.currentUser.value?.id)
              .set({
            "LoginID": loginID,
          }, SetOptions(merge: true));
          Get.find<GlobalController>().navigationCheck(user, "apple.com");
          break;

        case AuthorizationStatus.error:
          // print("Sign in failed: ${result.error.localizedDescription}");
          Get.showSnackbar(
            GetSnackBar(
              // message: 'An error occured. Please Try again.',
              message: "Sign in failed: ${result.error?.localizedDescription}",
              duration: Duration(seconds: 8),
            ),
          );
          break;

        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> handleGoogleLogin(context) async {
    googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return;
    }

    if (kDebugMode) {
      print(googleUser?.id);
    }
    final googleAuth = await googleUser?.authentication;
    if (googleAuth == null) {
      return;
    }
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Once signed in, return the UserCredential
    try {
      var data = await Get.find<GlobalController>()
          .auth
          .signInWithCredential(credential);
      if (kDebugMode) {
        print(Get.find<GlobalController>().auth.currentUser?.providerData);
      }
      googleSignIn.signOut();
      if (data.user == null) {
        return;
      }
      // Session().saveLoginType("google");
      var loginID = {
        "google": data.user?.uid ?? "",
      };
      await queryCollectionDB("Users")
          .doc(globalController.currentUser.value?.id)
          .set({
        "LoginID": loginID,
      }, SetOptions(merge: true));
      Get.find<GlobalController>().navigationCheck(data.user!, "google");
    } catch (e) {
      Global().showInfoDialog(e.toString());
    }
  }

  Future<void> handleFacebookLogin(context) async {
    User? user;
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWebView(
          selectedUrl:
              'https://www.facebook.com/dialog/oauth?client_id=$your_client_id&redirect_uri=$your_redirect_url&response_type=token&scope=email,public_profile,',
        ),
        maintainState: true,
      ),
    );
    if (result != null) {
      try {
        final facebookAuthCred = FacebookAuthProvider.credential(result);
        user =
            (await FirebaseAuth.instance.signInWithCredential(facebookAuthCred))
                .user;
        if (user == null) {
          return;
        }
        // Session().saveLoginType("fb");
        var loginID = {
          "google": user.uid,
        };
        await queryCollectionDB("Users")
            .doc(globalController.currentUser.value?.id)
            .set({
          "LoginID": loginID,
        }, SetOptions(merge: true));
        Get.find<GlobalController>().navigationCheck(user, "fb");
        print('user $user');
      } catch (e) {
        print('Error $e');
      }
    }
    // return user;
  }
}
