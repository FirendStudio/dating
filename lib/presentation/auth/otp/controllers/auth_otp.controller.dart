import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/controller/global_controller.dart';
import '../../../../infrastructure/dal/util/color.dart';
import '../../../../infrastructure/dal/util/general.dart';

class AuthOtpController extends GetxController {
  bool updateNumber = false;
  TextEditingController phoneNumController = new TextEditingController();
  TextEditingController otpController = new TextEditingController();
  RxBool cont = false.obs;
  String smsVerificationCode = "";
  String countryCode = '+91';
  String code = "";
  String tempCountryPhone = "";

  @override
  void onInit() {
    super.onInit();
    updateNumber = Get.arguments['updateNumber'];
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future verifyPhoneNumber(String phoneNumber, BuildContext context) async {
    phoneNumber = countryCode + phoneNumber.toString();
    print(phoneNumber);

    if (updateNumber) {
      var query = await queryCollectionDB('Users')
          .where("phoneNumber", isEqualTo: phoneNumber)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        Global().showInfoDialog("Phone Number Already Connect");
        return;
      }
    }
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
      verificationCompleted: (phoneCredential) {
        print("Your account is successfully verified");
        // verificationComplete(phoneCredential, context);
      },
      verificationFailed: (authException) {
        print("Masuk Exception");
        print(authException);
        verificationFailed(authException, context);
      },
      codeAutoRetrievalTimeout: (verificationId) => codeAutoRetrievalTimeout(
        verificationId,
      ),
      // called when the SMS code is sent
      codeSent: (verificationId, [code]) => smsCodeSent(
        verificationId,
        [code ?? 0],
        context,
      ),
    );
  }

  smsCodeSent(
      String verificationId, List<int> code, BuildContext context) async {
    // set the verification code so that we can use it to log the user in
    smsVerificationCode = verificationId;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        Future.delayed(
          Duration(seconds: 2),
          () {
            Navigator.pop(context);
            tempCountryPhone = countryCode + phoneNumController.text;
            Get.toNamed(Routes.AUTH_VERIFICATION);
          },
        );
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

  verificationFailed(
      FirebaseAuthException authException, BuildContext context) {
    Global().showInfoDialog(
        "Exception!! message:" + authException.message.toString());
  }

  codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    smsVerificationCode = verificationId;
    print("timeout $smsVerificationCode");
  }

  verificationComplete(
      PhoneAuthCredential authCredential, BuildContext context) async {
    if (updateNumber) {
      print("Update Phone Number");
      User user = FirebaseAuth.instance.currentUser!;
      user
          .updatePhoneNumber(authCredential)
          .then((_) => updatePhoneNumber(context))
          .catchError((e) {
        Global().showInfoDialog(e.toString());
      });
      return;
    }
    FirebaseAuth.instance.signInWithCredential(authCredential).then(
      (UserCredential authResult) async {
        if(kDebugMode){
          print(authResult.user?.uid);
        }
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            Future.delayed(Duration(seconds: 2), () async {
              Navigator.pop(context);
              Get.find<GlobalController>()
                  .navigationCheck(FirebaseAuth.instance.currentUser!, "phone");
            });
            return Center(
              child: Container(
                width: 150.0,
                height: 160.0,
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
                      "Verified\n Successfully",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    ).catchError((onError) {
      Global().showInfoDialog("$onError");
    });
  }

  Future updatePhoneNumber(BuildContext context) async {
    print("here");
    User user = FirebaseAuth.instance.currentUser!;
    Get.find<GlobalController>().addNewLoginTypeUser(user, "phone");
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        Future.delayed(Duration(seconds: 2), () async {
          Navigator.pop(context);
          Get.offAllNamed(Routes.DASHBOARD);
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
                  "Phone Number\nChanged\nSuccessfully",
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
}
