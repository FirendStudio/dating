import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import '../../../domain/core/model/VerifyModel.dart';
import '../../../domain/core/model/custom_web_view.dart';
import '../../../domain/core/model/user_model.dart';
import '../../../infrastructure/dal/controller/global_controller.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/general.dart';
import '../../../infrastructure/navigation/routes.dart';

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
  TextEditingController phoneController = new TextEditingController();
  List<String> listSelectedGender = [];
  GoogleSignInAccount? googleUser;
  Map<String, dynamic> changeValues = {};
  RxInt distance = 0.obs;
  int freeR = 0;
  int paidR = 0;
  RxInt ageMin = 1.obs;
  RxInt ageMax = 100.obs;
  Rxn<VerifyModel> verifyModel = Rxn();
  String code = "0";
  String codeVerify = "0";
  Rxn<File> currentFile = Rxn();
  RxBool isSentOTP = false.obs;
  String countryCode = '+91';
  String smsVerificationCode = "";

  @override
  void onInit() {
    super.onInit();
    changeValues = {};
    listSelectedGender = [];
    for (int i = 0;
        i <= globalController.currentUser.value!.showMe.length - 1;
        i++) {
      listSelectedGender.add(globalController.currentUser.value!.showMe[i]);

      for (int j = 0; j <= listShowMe.length - 1; j++) {
        if (globalController.currentUser.value!.showMe[i] ==
            listShowMe[j].name.value) {
          listShowMe[j].onTap.value = true;
          break;
        }
      }
    }

    freeR = globalController.items['free_radius'] != null
        ? int.parse(globalController.items['free_radius'])
        : 400;
    paidR = globalController.items['paid_radius'] != null
        ? int.parse(globalController.items['paid_radius'])
        : 400;
    if (!globalController.isPurchased.value &&
        (globalController.currentUser.value?.maxDistance ?? 100) > freeR) {
      globalController.currentUser.value!.maxDistance = freeR.round();
      changeValues.addAll({'maximum_distance': freeR.round()});
    } else if (globalController.isPurchased.value &&
        (globalController.currentUser.value?.maxDistance ?? 100) >= paidR) {
      globalController.currentUser.value!.maxDistance = paidR.round();
      changeValues.addAll({'maximum_distance': paidR.round()});
    }
    // _showMe = widget.currentUser.showMe;
    distance.value =
        (globalController.currentUser.value?.maxDistance ?? 100).round();
    ageMin.value =
        int.parse(globalController.currentUser.value?.ageRange?['min'] ?? 1);
    ageMax.value =
        int.parse(globalController.currentUser.value?.ageRange?['max'] ?? 100);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    if (changeValues.length > 0) {
      updateData();
    }
  }

  getVerifyModel() async {
    verifyModel.value = null;
    var result = await queryCollectionDB("Verify")
        .doc(globalController.currentUser.value?.id)
        .get();
    if (result.exists) {
      print(result.data());
      verifyModel.value = VerifyModel.fromDocument(result.data()!);
      if (verifyModel.value?.verified == 2) {
        code = verifyModel.value?.code ?? "0";
        Get.toNamed(Routes.Verify_Upload);
        // Get.to(() => UploadImageVerifyScreen());
        return;
      }
    }
    Get.toNamed(Routes.Verify_Account);
  }

  Future updateData() async {
    queryCollectionDB("Users")
        .doc(globalController.currentUser.value?.id)
        .set(changeValues, SetOptions(merge: true));
  }

  Future deleteUser() async {
    await queryCollectionDB("Users")
        .doc(globalController.currentUser.value?.id)
        .delete();
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

  setVerification() {
    var rng = Random();
    codeVerify = rng.nextInt(99999).toString();
    if (kDebugMode) {
      print(codeVerify);
    }
    Get.toNamed(Routes.Verify_Upload);
  }

  Future uploadFile(File image) async {
    Get.dialog(Obx(() {
      return CircularPercentIndicator(
        radius: 120.0,
        lineWidth: 13.0,
        animation: true,
        percent: progressLoading.value,
        center: Text(
          "${(progressLoading.value * 100)}%",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
        ),
        footer: Text(
          "Uploading......",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 17.0, color: Colors.white),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: Colors.purple,
      );
    }));
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(
        'verify/${globalController.currentUser.value?.id}/${image.hashCode}.jpg');
    UploadTask uploadTask = ref.putFile(File(image.path));
    uploadTask.snapshotEvents.listen((event) {
      print("Progress : " +
          (event.bytesTransferred / event.totalBytes).toString());
      progressLoading.value =
          (event.bytesTransferred / event.totalBytes).toDouble();
    });

    uploadTask.then((res) async {
      String fileURL = await res.ref.getDownloadURL();

      try {
        Map<String, dynamic> updateObject = {
          "idUser": globalController.currentUser.value?.id,
          "name": globalController.currentUser.value?.name,
          "phoneNumber": globalController.currentUser.value?.phoneNumber,
          "verified": 1,
          "reason_verified": "",
          "date_updated": DateTime.now().toIso8601String(),
          "imageUrl": fileURL,
          "code": code,
        };
        await queryCollectionDB("Verify")
            .doc(globalController.currentUser.value?.id)
            .set(updateObject, SetOptions(merge: true));
        await queryCollectionDB("Users")
            .doc(globalController.currentUser.value?.id)
            .set({
          "verified": 1,
          "reason_verified": "",
        }, SetOptions(merge: true));
        // widget.currentUser.imageUrl.add(fileURL);
        Get.back();
        await Future.delayed(Duration(seconds: 1));
        progressLoading.value = 0.0;
        await showDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return Material(
              color: Colors.transparent,
              child: CupertinoAlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text("Account Verification")],
                ),
                content: Column(
                  children: [
                    Text(
                      "Thanks for submitting your photo! Please allow up to 24 hours for our staff to manually verify your profile.",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(Get.context!);
                              Get.offAllNamed(Routes.DASHBOARD);
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 0,
                                top: 4,
                                bottom: 4,
                                right: 6,
                              ),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                ),
                              ),
                              child: Text(
                                "Okay",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                insetAnimationCurve: Curves.decelerate,
                actions: [],
              ),
            );
          },
        );
      } catch (err) {
        print("Error: $err");
      }
    });
  }

  codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    smsVerificationCode = verificationId;
    print("timeout $smsVerificationCode");
  }

  verifyOtpFunction(BuildContext context, String otp, UserModel currentUser) {
    PhoneAuthCredential phoneAuth = PhoneAuthProvider.credential(
        verificationId: smsVerificationCode, smsCode: otp);
    if (currentUser.phoneNumber.isEmpty) {
      User user = FirebaseAuth.instance.currentUser!;
      user.updatePhoneNumber(phoneAuth).then((_) async {
        User user = FirebaseAuth.instance.currentUser!;
        var loginID = {
          "phone": user.uid,
        };
        queryCollectionDB("Users")
            .doc(globalController.currentUser.value?.id)
            .set({'phoneNumber': user.phoneNumber, "LoginID": loginID},
                SetOptions(merge: true));
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            Future.delayed(Duration(seconds: 2), () async {
              Navigator.pop(context);
              Get.toNamed(Routes.Verify_Upload);
            });
            return Center(
              child: Container(
                width: 180.0,
                height: 200.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "asset/auth/verified.jpg",
                      height: 100,
                    ),
                    Text(
                      "Verified\n Successfully",
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
      }).catchError((e) {
        Global().showInfoDialog(e.toString());
      });
      return;
    }

    FirebaseAuth.instance
        .signInWithCredential(phoneAuth)
        .then((authResult) async {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Future.delayed(Duration(seconds: 2), () async {
            Navigator.pop(context);
            Get.toNamed(Routes.Verify_Upload);
          });
          return Center(
            child: Container(
              width: 180.0,
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "asset/auth/verified.jpg",
                    height: 100,
                  ),
                  Text(
                    "Verified\n Successfully",
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
    }).catchError((onError) {
      Global().showInfoDialog("$onError");
    });
  }
}
