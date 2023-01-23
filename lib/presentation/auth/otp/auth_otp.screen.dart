import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../../infrastructure/dal/util/color.dart';
import 'controllers/auth_otp.controller.dart';

class AuthOtpScreen extends GetView<AuthOtpController> {
  const AuthOtpScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(AuthOtpController());
    return Obx(
      () => Scaffold(
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
                Container(
                  padding: EdgeInsets.only(
                    left: Get.width * 0.1,
                    right: Get.width * 0.1,
                  ),
                  child: ListTile(
                    title: Text(
                      "My number is",
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
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
                          controller.countryCode = value.dialCode ?? "";
                        },
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: 'IN',
                        favorite: [controller.countryCode, 'IN'],
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
                        controller: controller.phoneNumController,
                        onChanged: (value) {
                          controller.cont.value = true;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your number",
                          hintStyle: TextStyle(fontSize: 18),
                          focusColor: primaryColor,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Text(
                    "Please enter Your mobile Number to\n receive a verification code. Message and data rates may apply",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
                controller.cont.value
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
                              ],
                            ),
                          ),
                          height: Get.height * .065,
                          width: Get.width * .75,
                          child: Center(
                            child: Text(
                              "CONTINUE",
                              style: TextStyle(
                                fontSize: 15,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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

                          await controller.verifyPhoneNumber(
                            controller.phoneNumController.text,
                            context,
                          );
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        height: Get.height * .065,
                        width: Get.width * .75,
                        child: Center(
                          child: Text(
                            "CONTINUE",
                            style: TextStyle(
                              fontSize: 15,
                              color: darkPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
