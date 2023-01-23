import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/splash.controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: 120,
          width: 200,
          child: Image.asset(
            "asset/hookup4u-Logo-BP.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
