import 'package:get/get.dart';

import '../../../../presentation/settings/view/verified_profile/controllers/settings_view_verified_profile.controller.dart';

class SettingsViewVerifiedProfileControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsViewVerifiedProfileController>(
      () => SettingsViewVerifiedProfileController(),
    );
  }
}
