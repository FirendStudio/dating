import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/presentation/auth/otp/controllers/auth_otp.controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../infrastructure/dal/util/color.dart';
import 'dart:async';

class AuthVerificationScreen extends GetView<AuthOtpController> {
  AuthVerificationScreen({Key? key}) : super(key: key);
  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 100),
                width: 300,
                child: Image.asset(
                  "asset/auth/verifyOtp.png",
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50),
              child: RichText(
                text: TextSpan(
                  text: "Enter the code sent to ",
                  children: [
                    TextSpan(
                      text: controller.tempCountryPhone,
                      style: TextStyle(
                        color: primaryColor,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                        fontSize: 15,
                      ),
                    ),
                  ],
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: PinCodeTextField(
                controller: controller.otpController,
                errorAnimationController: errorController, // Pass it here
                keyboardType: TextInputType.number,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                animationDuration: Duration(milliseconds: 300),
                onChanged: (value) {
                  controller.code = value;
                },
                appContext: context,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Didn't receive the code? ",
                style: TextStyle(color: Colors.black54, fontSize: 15),
                children: [
                  WidgetSpan(
                    child: InkWell(
                      onTap: () {},
                      child: Text(
                        " RESEND",
                        style: TextStyle(
                          color: Color(0xFF91D3B3),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            InkWell(
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
                    ],
                  ),
                ),
                height: Get.height * .065,
                width: Get.width * .75,
                child: Center(
                  child: Text(
                    "VERIFY",
                    style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              onTap: () async {
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.pop(context);
                });
                showDialog(
                  builder: (context) {
                    return Center(
                        child: CupertinoActivityIndicator(
                      radius: 20,
                    ));
                  },
                  barrierDismissible: false,
                  context: context,
                );
                PhoneAuthCredential _phoneAuth = PhoneAuthProvider.credential(
                    verificationId: controller.smsVerificationCode,
                    smsCode: controller.otpController.text);
                print(_phoneAuth.providerId);
                final PhoneAuthCredential credential =
                    PhoneAuthProvider.credential(
                  verificationId: controller.smsVerificationCode,
                  smsCode: controller.otpController.text,
                );
                controller.verificationComplete(credential, context);
              },
            )
          ],
        ),
      ),
    );
  }
}
