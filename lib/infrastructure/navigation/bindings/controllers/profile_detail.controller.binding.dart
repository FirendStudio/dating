import 'package:get/get.dart';

import '../../../../presentation/profile/detail/controllers/detail.controller.dart';

class ProfileDetailControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailController>(
      () => DetailController(),
    );
  }
}
