import 'package:get/get.dart';

import '../../../../presentation/profile/detailpartner/controllers/detailpartner.controller.dart';

class ProfileDetailpartnerControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailPartnerController>(
      () => DetailPartnerController(),
    );
  }
}
