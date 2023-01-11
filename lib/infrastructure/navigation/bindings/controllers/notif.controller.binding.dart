import 'package:get/get.dart';

import '../../../../presentation/notif/controllers/notif.controller.dart';

class NotifControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotifController>(
      () => NotifController(),
    );
  }
}
