import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Profile/verify/UploadImageVerifyScreen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../Screens/Tab.dart';
import '../models/user_model.dart';
import '../util/color.dart';
import '../util/snackbar.dart';
import 'LoginController.dart';
import 'TabsController.dart';

class VerifyProfileController extends GetxController {
  TextEditingController phoneNumController = new TextEditingController();
  bool cont = false;
  String smsVerificationCode;
  String countryCode = '+91';
  bool isSentOTP = false;
  String code;
  ImagePicker imagePicker = ImagePicker();
  File croppedFile;

  setVerification() {
    var rng = Random();
    code = rng.nextInt(99999).toString();
    if(kDebugMode){
      print(code);
    }
    Get.to(() => UploadImageVerifyScreen());
    // for (var i = 0; i < 5; i++) {
    //   print(rng.nextInt(100));
    // }
  }

  Future verifyPhoneNumber(String phoneNumber, BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    // phoneNumber = countryCode + phoneNumber.toString();
    print(phoneNumber);
    // return;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 30),
        verificationCompleted: (authCredential) {
          if (kDebugMode) {
            print(authCredential);
            print("Berhasil");
          }
          //  verificationComplete(
          //   authCredential, context, updateNumber, scaffoldKey)
        },
        verificationFailed: (authException) {
          if (kDebugMode) {
            print("Masuk Exception");
            print(authException);
          }
          verificationFailed(authException, context, scaffoldKey);
        },
        codeAutoRetrievalTimeout: (verificationId) =>
            codeAutoRetrievalTimeout(verificationId),
        // called when the SMS code is sent
        codeSent: (verificationId, [code]) =>
            smsCodeSent(verificationId, [code], context));
  }

  smsCodeSent(
      String verificationId, List<int> code, BuildContext context) async {
    // set the verification code so that we can use it to log the user in
    smsVerificationCode = verificationId;
    // isSentOTP = true;
    // print("code Sent : ");
    // code.forEach((element) => print(element),);
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Future.delayed(Duration(seconds: 2), () async {
            Navigator.pop(context);
            Get.to(() => UploadImageVerifyScreen());
          });
          return Center(
              child: Container(
                  width: 100.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        "asset/auth/verified.jpg",
                        height: 60,
                        color: primaryColor,
                        colorBlendMode: BlendMode.color,
                      ),
                      Text(
                        "OTP\nSent",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 20),
                      )
                    ],
                  )));
        });
  }

  codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    smsVerificationCode = verificationId;
    print("timeout $smsVerificationCode");
  }

  verificationFailed(FirebaseAuthException authException, BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey) {
    CustomSnackbar.snackbar(
        "Exception!! message:" + authException.message.toString(), scaffoldKey);
  }

  verifyOtpFunction(BuildContext context, String otp, UserModel currentUser,
      GlobalKey<ScaffoldState> _scaffoldKey) {
    AuthCredential _phoneAuth = PhoneAuthProvider.credential(
        verificationId: smsVerificationCode, smsCode: otp);
    print(_phoneAuth);
    if (currentUser.phoneNumber.isEmpty) {
      User user = FirebaseAuth.instance.currentUser;
      user.updatePhoneNumber(_phoneAuth).then((_) async {
        User user = FirebaseAuth.instance.currentUser;
        var loginID = {
          "phone": user.uid,
        };
        FirebaseFirestore.instance
            .collection("Users")
            .doc(Get.find<LoginController>().userId)
            .set({'phoneNumber': user.phoneNumber, "LoginID": loginID},
                SetOptions(merge: true));
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              Future.delayed(Duration(seconds: 2), () async {
                Navigator.pop(context);
                Get.to(() => UploadImageVerifyScreen());
              });
              return Center(
                  child: Container(
                      width: 180.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20)),
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
                                fontSize: 20),
                          )
                        ],
                      )));
            });
      }).catchError((e) {
        CustomSnackbar.snackbar("$e", _scaffoldKey);
      });
      return;
    }

    FirebaseAuth.instance
        .signInWithCredential(_phoneAuth)
        .then((authResult) async {
      if (authResult != null) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              Future.delayed(Duration(seconds: 2), () async {
                Navigator.pop(context);
                Get.to(() => UploadImageVerifyScreen());
              });
              return Center(
                  child: Container(
                      width: 180.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20)),
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
                                fontSize: 20),
                          )
                        ],
                      )));
            });
      }
    }).catchError((onError) {
      CustomSnackbar.snackbar("$onError", _scaffoldKey);
    });
  }

  Future<void> pickImage(ImageSource source, {bool metode = false}) async {
    final XFile file =
        await imagePicker.pickImage(source: source, imageQuality: 50);

    if (file == null) {
      return;
    }
    if (metode) {
      croppedFile = await ImageCropper().cropImage(
          sourcePath: file.path,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      // image = file;
      if (croppedFile != null) {
        update();
      }
    }
  }

  Future uploadFile(File image) async {
    Get.dialog(GetBuilder<LoginController>(builder: (data) {
      return CircularPercentIndicator(
        radius: 120.0,
        lineWidth: 13.0,
        animation: true,
        percent: Get.find<LoginController>().progress,
        center: Text(
          "${(Get.find<LoginController>().progress * 100)}%",
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
        'verify/${Get.find<TabsController>().currentUser.id}/${image.hashCode}.jpg');
    UploadTask uploadTask = ref.putFile(File(image.path));
    uploadTask.snapshotEvents.listen((event) {
      print("Progress : " +
          (event.bytesTransferred / event.totalBytes).toString());
      Get.find<LoginController>().progress =
          (event.bytesTransferred / event.totalBytes).toDouble();
      Get.find<LoginController>().update();
    });

    uploadTask.then((res) async {
      String fileURL = await res.ref.getDownloadURL();

      try {
        Map<String, dynamic> updateObject = {
          "idUser": Get.find<TabsController>().currentUser.id,
          "name": Get.find<TabsController>().currentUser.name,
          "phoneNumber": Get.find<TabsController>().currentUser.phoneNumber,
          "verified": 1,
          "date_updated": DateTime.now().toIso8601String(),
          "imageUrl": fileURL,
          "code" : code,
        };
        await FirebaseFirestore.instance
            .collection("Verify")
            .doc(Get.find<TabsController>().currentUser.id)
            .set(updateObject, SetOptions(merge: true));
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(Get.find<TabsController>().currentUser.id)
            .set({"verified": 1}, SetOptions(merge: true));
        // widget.currentUser.imageUrl.add(fileURL);
        Get.back();
        await Future.delayed(Duration(seconds: 1));
        Get.find<LoginController>().progress = 0.0;
        await showDialog(
        context: Get.context,
        builder: (BuildContext context) {
          return Material(
              color: Colors.transparent,
              child: CupertinoAlertDialog(
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [Text("Account Verification")]),
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
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: () {
                                  Navigator.pop(Get.context);
                                  Navigator.push(Get.context,
                                      CupertinoPageRoute(builder: (context) => Tabbar(null, null)));
                                },
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: 0, top: 4, bottom: 4, right: 6),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[400],
                                      ),
                                      // borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    child: Text(
                                      "Okay",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ))),
                          ),
                          
                        ],
                      ),
                    ],
                  ),
                  insetAnimationCurve: Curves.decelerate,
                  actions: []));
        });
        // if (mounted) setState(() {});
      } catch (err) {
        print("Error: $err");
      }
    });
  }
}
