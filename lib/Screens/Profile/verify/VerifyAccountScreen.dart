import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/TabsController.dart';
import 'package:hookup4u/Controller/VerifyProfileController.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../Controller/LoginController.dart';
import '../../../Controller/WelcomeController.dart';
import '../../../util/snackbar.dart';
// import 'package:easy_localization/easy_localization.dart';

class VerifyAccountScreen extends StatelessWidget {
  final UserModel currentUser = Get.find<TabsController>().currentUser;
  // VerifyAccountScreen(this.currentUser);
  var welcomeController = Get.put(WelcomeController());
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();
  var onTapRecognizer;
  TextEditingController otpController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyProfileController>(builder: (data) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: primaryColor,
        appBar: AppBar(
          title: Text(
            "Phone number settings",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: Container(
          width: Get.width,
          decoration: BoxDecoration(
              // borderRadius: BorderRadius.only(
              //     topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: RichText(
                  text: TextSpan(
                      text: "Verification Status : ",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: [
                        TextSpan(
                            text: (currentUser.verified == 0)
                                ? "Unverified":(currentUser.verified == 1)
                                ? "On Verification Admin":(currentUser.verified == 2)
                                ? "Rejected"
                                : "Verified",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: (currentUser.verified != 3)
                                    ? Colors.red
                                    : Colors.greenAccent,),),
                      ]),
                ),
              ),
              if (!data.isSentOTP && currentUser.verified == 0) requestWidget(data),
              if (data.isSentOTP && currentUser.verified == 0) verifyWidget(data, context),
              if (!data.isSentOTP && currentUser.verified == 2) requestWidget(data),
              if (data.isSentOTP && currentUser.verified == 2) verifyWidget(data, context),
            ],
          ),
        ),
      );
    });
  }

  Widget verifyWidget(VerifyProfileController data, BuildContext context) {
    return Column(
      children: [
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
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50),
          child: RichText(
            text: TextSpan(
                text: "Enter the code sent to ",
                children: [
                  TextSpan(
                      text: data.countryCode + data.phoneNumController.text,
                      // text: (currentUser.phoneNumber.isNotEmpty)
                      //     ? currentUser.phoneNumber
                      //     : (data.countryCode + data.phoneNumController.text),
                      style: TextStyle(
                          color: primaryColor,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          textBaseline: TextBaseline.alphabetic,
                          fontSize: 15)),
                ],
                style: TextStyle(color: Colors.black54, fontSize: 15)),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: PinCodeTextField(
            controller: otpController,
            // errorAnimationController: errorController, // Pass it here
            keyboardType: TextInputType.number,
            length: 6,
            obscureText: false,
            animationType: AnimationType.fade,
            animationDuration: Duration(milliseconds: 300),
            onChanged: (value) {
              data.code = value;
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
                  onTap: () {
                    data.isSentOTP = false;
                    data.update();
                  },
                  child: Text(" RESEND",
                      style: TextStyle(
                          color: Color(0xFF91D3B3),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ))
              ]),
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
                      ])),
              height: MediaQuery.of(context).size.height * .065,
              width: MediaQuery.of(context).size.width * .75,
              child: Center(
                  child: Text(
                "VERIFY",
                style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                    fontWeight: FontWeight.bold),
              ))),
          onTap: () async {
            data.verifyOtpFunction(
                context, otpController.text, currentUser, _scaffoldKey);
          },
        )
      ],
    );
  }

  Widget requestWidget(VerifyProfileController data) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15, bottom: 5, top: 10),
            child: Text(
                "To get verified we will send you a code which you will need to write down on a A4 sheet of paper.")),
        Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15, bottom: 5, top: 10),
            child: Text(
                "Please make sure that the numbers are written in large font and can easily be seen.")),
        Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15, bottom: 5, top: 10),
            child: Text(
                "You will then take a selfie displaying your face alongside the sheet of paper.")),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: ListTile(
                // leading: (currentUser.phoneNumber.isEmpty)
                //     ? Container(
                //         decoration: BoxDecoration(
                //           border: Border(
                //             bottom: BorderSide(width: 1.0, color: primaryColor),
                //           ),
                //         ),
                //         child: CountryCodePicker(
                //           onChanged: (value) {
                //             data.countryCode = value.dialCode;
                //           },
                //           // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                //           initialSelection: 'IN',
                //           favorite: [data.countryCode, 'IN'],
                //           // optional. Shows only country name and flag
                //           showCountryOnly: false,
                //           // optional. Shows only country name and flag when popup is closed.
                //           showOnlyCountryWhenClosed: false,
                //           // optional. aligns the flag and the Text left
                //           alignLeft: false,
                //         ),
                //       )
                //     : null,
                leading: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: primaryColor),
                    ),
                  ),
                  child: CountryCodePicker(
                    onChanged: (value) {
                      data.countryCode = value.dialCode;
                    },
                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                    initialSelection: 'IN',
                    favorite: [data.countryCode, 'IN'],
                    // optional. Shows only country name and flag
                    showCountryOnly: false,
                    // optional. Shows only country name and flag when popup is closed.
                    showOnlyCountryWhenClosed: false,
                    // optional. aligns the flag and the Text left
                    alignLeft: false,
                  ),
                ),
                title: Container(
                  child: TextFormField(
                    // enabled:(currentUser.phoneNumber.isNotEmpty) ? false : true,
                    enabled: true,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: 20),
                    cursorColor: primaryColor,
                    controller: data.phoneNumController,
                    onChanged: (value) {
                      data.cont = true;
                      data.update();
                    },
                    decoration: InputDecoration(
                      hintText: "Enter your number",
                      hintStyle: TextStyle(fontSize: 18),
                      focusColor: primaryColor,
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                    ),
                  ),
                ))),
        Center(
          child: InkWell(
              onTap: () async {
                String phoneNumber = data.phoneNumController.text;
                phoneNumber = data.countryCode + phoneNumber.toString();
                data.verifyPhoneNumber(phoneNumber, Get.context, _scaffoldKey);
                // if (currentUser.phoneNumber.isEmpty) {
                //   phoneNumber = data.countryCode + phoneNumber.toString();
                // }
                // if (currentUser.phoneNumber.isNotEmpty) {
                //   data.verifyPhoneNumber(
                //       phoneNumber, Get.context, _scaffoldKey);
                //   return;
                // }
                // print(phoneNumber);
                // var result = await FirebaseFirestore.instance
                //     .collection('Users')
                //     .where("phoneNumber", isEqualTo: phoneNumber)
                //     .limit(1)
                //     .get();
                // print(result.docs);
                // if (result != null && result.docs.isEmpty) {
                //   data.verifyPhoneNumber(
                //       phoneNumber, Get.context, _scaffoldKey);
                //   return;
                // }
                // CustomSnackbar.snackbar(
                //     "Phone already registered", _scaffoldKey);
              },
              child: Container(
                  height: Get.size.height * .065,
                  width: Get.size.width * .75,
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Center(
                    child: Text("Send me the verification code",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            // fontFamily: Global.font,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ))),
        )
      ],
    );
  }
}
