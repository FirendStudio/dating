import 'package:get/get.dart';

import '../../../../presentation/payment/subcription/controllers/payment_subcription.controller.dart';

class PaymentSubcriptionControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentSubcriptionController>(
      () => PaymentSubcriptionController(),
    );
  }
}
