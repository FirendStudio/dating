import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/snackbar.dart';

class VerifyProfileController extends GetxController{
  TextEditingController phoneNumController = new TextEditingController();
  bool cont = false;
  String _smsVerificationCode;
  String countryCode = '+91';

  Future verifyPhoneNumber(String phoneNumber, BuildContext context,
      updateNumber, GlobalKey<ScaffoldState> scaffoldKey) async {
    phoneNumber = countryCode + phoneNumber.toString();
    print(phoneNumber);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 30),
        verificationCompleted: (authCredential) => verificationComplete(
            authCredential, context, updateNumber, scaffoldKey),
        verificationFailed: (authException) {
          print("Masuk Exception");
          print(authException);
          verificationFailed(authException, context, scaffoldKey);
        },
        codeAutoRetrievalTimeout: (verificationId) =>
            codeAutoRetrievalTimeout(verificationId),
        // called when the SMS code is sent
        codeSent: (verificationId, [code]) =>
            smsCodeSent(verificationId, [code], context, updateNumber));
  }

  codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    _smsVerificationCode = verificationId;
    print("timeout $_smsVerificationCode");
  }
  verificationFailed(FirebaseAuthException authException, BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey) {
    CustomSnackbar.snackbar(
        "Exception!! message:" + authException.message.toString(), scaffoldKey);
  }
}