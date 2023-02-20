import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/session.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';
import 'package:hookup4u/presentation/auth/login/controllers/auth_login.controller.dart';
import '../../../../infrastructure/dal/util/color.dart';


class RememberLoginDialog extends StatefulWidget {
  final String loginWith, wishedLoginType;

  RememberLoginDialog({required this.loginWith, required this.wishedLoginType});

  @override
  _RememberLoginDialogState createState() => _RememberLoginDialogState();
}

class _RememberLoginDialogState extends State<RememberLoginDialog> {
  TextEditingController reasonCtlr = TextEditingController();
  bool other = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Remember Your Choice",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              "Are you certain that you wish to log in using your ${getLoginType(widget.wishedLoginType)}, even though your initial registration was created using your ${getLoginType(widget.loginWith)}?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Material(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
                child: Text(
                  "Yes",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Get.back();
                  getLoginEvent(widget.wishedLoginType);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  "No",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Get.back();
                },
              )
            ],
          ),
        ))
      ],
    );
  }

  getLoginType(loginType) {
    switch (loginType) {
      case "phone":
        return "Phone Number";
      case "apple":
        return "apple Account";
      case "google":
        return "google Account";
      case "fb":
        return "facebook Account";
    }
  }

  getLoginEvent(loginType) {
    switch (loginType) {
      case "phone":
        Session().saveLoginType("phone");
        Get.toNamed(Routes.AUTH_OTP, arguments: {
          "updateNumber": false,
        });
        break;
      case "apple":
        Get.find<AuthLoginController>().handleAppleLogin();
        break;
      case "google":
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
        Get.back();
        Get.find<AuthLoginController>().handleGoogleLogin(context);
        break;
      case "fb":
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
        Get.back();
        Get.find<AuthLoginController>().handleFacebookLogin(context);
        break;
    }
  }
}
