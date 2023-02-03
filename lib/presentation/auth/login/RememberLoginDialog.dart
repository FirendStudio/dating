import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/session.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';
import 'package:hookup4u/presentation/auth/login/controllers/auth_login.controller.dart';

import '../../../../infrastructure/dal/util/color.dart';

// import 'package:easy_localization/easy_localization.dart';

class RememberLoginDialog extends StatefulWidget {
  String loginWith;

  RememberLoginDialog({required this.loginWith});

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
                "Remember My Choice",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
            Text(
              "Last Time You Login with this",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Material(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: Column(
          children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
                child: Text(
                  getLoginType(widget.loginWith),
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Get.back();
                  getLoginEvent(widget.loginWith);

                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  "CANCEL",
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
        return "LOGIN WITH PHONE NUMBER";
      case "apple":
        return "LOGIN WITH APPLE";
      case "google":
        return "LOGIN WITH GOOGLE";
      case "fb":
        return "LOGIN WITH FACEBOOK";
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
