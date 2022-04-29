import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/LoginController.dart';

import '../Screens/Tab.dart';
import '../Screens/auth/login.dart';
import '../Screens/auth/otp_verification.dart';
import '../util/color.dart';
import '../util/snackbar.dart';

class WelcomeController extends GetxController{

  TextEditingController phoneNumController = new TextEditingController();
  bool cont = false;
  String _smsVerificationCode;
  String countryCode = '+91';
  Login login = new Login();
  String code;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Get.back();
      };
  }

  @override
  void dispose() {
    super.dispose();
    cont = false;
  }

  verificationComplete(
      AuthCredential authCredential, BuildContext context, updateNumber, scaffoldKey) async {
    if (updateNumber) {
      print("Update Phone Number");
      User user = FirebaseAuth.instance.currentUser;
      Get.find<LoginController>().userId = user.uid;
      user.updatePhoneNumber(authCredential)
          .then((_) => updatePhoneNumber(context))
          .catchError((e) {
        CustomSnackbar.snackbar("$e", scaffoldKey);
      });
    } else {
      FirebaseAuth.instance
          .signInWithCredential(authCredential)
          .then((authResult) async {
        print(authResult.user.uid);
        //snackbar("Success!!! UUID is: " + authResult.user.uid);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              Future.delayed(Duration(seconds: 2), () async {
                Navigator.pop(context);
                await Get.find<LoginController>().navigationCheck(authResult.user, context, "phone");
              });
              return Center(
                  child: Container(
                      width: 150.0,
                      height: 160.0,
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

        QuerySnapshot snapshot = await Get.find<LoginController>().getUser(authResult.user, "phone");
        await setDataUser(authResult.user);
      });
    }
  }

  /// method to verify phone number and handle phone auth
  Future verifyPhoneNumber(String phoneNumber, BuildContext context, updateNumber, GlobalKey<ScaffoldState> scaffoldKey) async {
    phoneNumber = countryCode + phoneNumber.toString();
    print(phoneNumber);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 30),
        verificationCompleted: (authCredential) =>
            verificationComplete(authCredential, context, updateNumber, scaffoldKey),
        verificationFailed: (authException) {
          print("Masuk Exception");
          print(authException);
          verificationFailed(authException, context, scaffoldKey);
        },
        codeAutoRetrievalTimeout: (verificationId) => codeAutoRetrievalTimeout(verificationId),
        // called when the SMS code is sent
        codeSent: (verificationId, [code]) => smsCodeSent(verificationId, [code], context, updateNumber));
  }

  Future updatePhoneNumber(BuildContext context) async {
    print("here");
    User user = FirebaseAuth.instance.currentUser;
    var loginID = {
      "phone" : user.uid,
    };
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(Get.find<LoginController>().userId)
        .set({
      'phoneNumber': user.phoneNumber,
      "LoginID" : loginID,
    },
        SetOptions(merge : true)
    ).then((_) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            Future.delayed(Duration(seconds: 2), () async {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Tabbar(null, null)));
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
                          "Phone Number\nChanged\nSuccessfully",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.black,
                              fontSize: 20),
                        )
                      ],
                    )));
          });
    });
  }

  /// will get an AuthCredential object that will help with logging into Firebase.


  smsCodeSent(String verificationId, List<int> code, BuildContext context, updateNumber) async {
    // set the verification code so that we can use it to log the user in
    _smsVerificationCode = verificationId;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context);
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => Verification(
                        countryCode + phoneNumController.text,
                        _smsVerificationCode,
                        updateNumber)));
          });
          return Center(

            // Aligns the container to center
              child: Container(
                // A simplified version of dialog.
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

  verificationFailed(FirebaseAuthException authException, BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    CustomSnackbar.snackbar(
        "Exception!! message:" + authException.message.toString(),
        scaffoldKey);
  }

  codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    _smsVerificationCode = verificationId;
    print("timeout $_smsVerificationCode");
  }

  Future setDataUser(User user) async {
    await FirebaseFirestore.instance.collection("Users").doc(Get.find<LoginController>().userId).set({
      'userId': Get.find<LoginController>().userId,
      'phoneNumber': user.phoneNumber,
      'timestamp': FieldValue.serverTimestamp(),
      'Pictures': FieldValue.arrayUnion([
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxUC64VZctJ0un9UBnbUKtj-blhw02PeDEQIMOqovc215LWYKu&s"
      ])

      // 'name': user.displayName,
      // 'pictureUrl': user.photoUrl,
    },
        SetOptions(merge : true)
    );
  }

  Future updateNumberOTP(BuildContext context) async {
    User user = FirebaseAuth.instance.currentUser;
    print("here2");
    var loginID = {
      "phone" : user.uid,
    };
    // await FirebaseFirestore.instance
    //     .collection("Users")
    //     .doc(user.uid)
    //     .set({
    //   'phoneNumber': user.phoneNumber,
    //   "LoginID" : loginID,
    // },
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(Get.find<LoginController>().userId)
        .set({
      'phoneNumber': user.phoneNumber,
      "LoginID" : loginID
    },
        SetOptions(merge : true)
    ).then((_) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            Future.delayed(Duration(seconds: 2), () async {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Tabbar(null, null)));
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
                          "Phone Number\nChanged\nSuccessfully",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.black,
                              fontSize: 20),
                        )
                      ],
                    )));
          });
    });
  }


}