import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';

import '../../../infrastructure/dal/util/color.dart';

Future showWelcomDialog(context) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pop(context);
        Get.find<GlobalController>().initAfterLogin();
        Get.toNamed(Routes.DASHBOARD);
      });
      return Center(
        child: Container(
          width: 150.0,
          height: 100.0,
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
                "You're in!",
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
