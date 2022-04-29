import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/WelcomeController.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:hookup4u/Screens/auth/otp_verification.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/snackbar.dart';
import 'login.dart';
// import 'package:easy_localization/easy_localization.dart';
//
// class OTP extends StatefulWidget {
//
//
//   @override
//   _OTPState createState() => _OTPState();
// }

class OTP extends StatelessWidget {
  final bool updateNumber;
  OTP(this.updateNumber);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var welcomeController = Get.put(WelcomeController());

  Widget build(BuildContext context) {
    return GetBuilder<WelcomeController>(builder: (data){
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 50,
              bottom: 50,

            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Image.asset(
                    "asset/auth/MobileNumber.png",
                    fit: BoxFit.cover,
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                // Icon(
                //   Icons.mobile_screen_share,
                //   size: 50,
                // ),
                Container(
                  padding: EdgeInsets.only(
                    left: Get.width * 0.1,
                    right: Get.width * 0.1,
                  ),
                  child: ListTile(
                    title: Text(
                      "My number is",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    // subtitle: Text(
                    //   "Please enter Your mobile Number to\n receive a verification code. Message and data rates may apply",
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    // ),
                  ),
                ),

                Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    child: ListTile(
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
                            keyboardType: TextInputType.phone,
                            style: TextStyle(fontSize: 20),
                            cursorColor: primaryColor,
                            controller: data.phoneNumController,
                            onChanged: (value) {
                              data.cont = true;
                              data.update();
                              // setState(() {
                              //   // if (value.length == 10) {
                              //   cont = true;
                              //   //  phoneNumController.text = value;
                              //   //  } else {
                              //   //    cont = false;
                              //   //  }
                              // });
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
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Text(
                    "Please enter Your mobile Number to\n receive a verification code. Message and data rates may apply",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),

                data.cont
                    ? InkWell(
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
                            "CONTINUE",
                            style: TextStyle(
                                fontSize: 15,
                                color: textColor,
                                fontWeight: FontWeight.bold),
                          ))),
                  onTap: () async {
                    showDialog(
                      builder: (context) {
                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.pop(context);
                        });
                        return Center(
                            child: CupertinoActivityIndicator(
                              radius: 20,
                            ));
                      },
                      barrierDismissible: false,
                      context: context,
                    );

                    await data.verifyPhoneNumber(data.phoneNumController.text, context, updateNumber, _scaffoldKey);
                  },
                )
                    : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    height: MediaQuery.of(context).size.height * .065,
                    width: MediaQuery.of(context).size.width * .75,
                    child: Center(
                        child: Text(
                          "CONTINUE",
                          style: TextStyle(
                              fontSize: 15,
                              color: darkPrimaryColor,
                              fontWeight: FontWeight.bold),
                        ))),
              ],
            ),
          ),
        ),
      );
    });
  }
}