import 'package:get/get.dart';

import '../../../../presentation/profile/edit/controllers/profile_edit.controller.dart';

class ProfileEditControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileEditController>(
      () => ProfileEditController(),
    );
  }
}
