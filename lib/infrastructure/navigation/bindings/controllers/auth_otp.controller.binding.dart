import 'package:get/get.dart';

import '../../../../presentation/auth/otp/controllers/auth_otp.controller.dart';

class AuthOtpControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthOtpController>(
      () => AuthOtpController(),
    );
  }
}
