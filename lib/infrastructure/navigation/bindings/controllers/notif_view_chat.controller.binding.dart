import 'package:get/get.dart';

import '../../../../presentation/notif/view/chat/controllers/notif_view_chat.controller.dart';

class NotifViewChatControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotifViewChatController>(
      () => NotifViewChatController(),
    );
  }
}
