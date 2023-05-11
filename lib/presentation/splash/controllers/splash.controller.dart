import 'package:get/get.dart';
import 'package:hookup4u/presentation/payment/subcription/controllers/payment_subcription.controller.dart';

import '../../../infrastructure/dal/controller/global_controller.dart';

class SplashController extends GetxController {
  //TODO: Implement SplashController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    print("call splash controller===>");

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
