import 'package:get/get.dart';

import '../../../../presentation/payment/details/controllers/payment_details.controller.dart';

class PaymentDetailsControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentDetailsController>(
      () => PaymentDetailsController(),
    );
  }
}
