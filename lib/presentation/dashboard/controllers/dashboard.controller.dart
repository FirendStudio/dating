import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';

import '../../../domain/core/interfaces/dialog.dart';
import '../../../infrastructure/dal/util/session.dart';

class DashboardController extends GetxController  {
  RxBool isLoading = false.obs;
RxInt initalIndex=1.obs;
  Future<bool> onBack() async {
    globalController.upgradeCounts.value=0;
    return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Exit'),
          content: Text('Do you want to exit the app?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () =>
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> firstLoginApp() async {
    await Future.delayed(Duration(seconds: 4));
    bool cek = Session().getIntroductionAfterLogin();
    print("Cek isLogin : " + cek.toString());
    if (!cek) {
      Session().saveIntroductionAfterLogin(true);
      Get.to(() => DialogFirstApp());
    }
  }

  @override
  void onInit() {
    firstLoginApp();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
