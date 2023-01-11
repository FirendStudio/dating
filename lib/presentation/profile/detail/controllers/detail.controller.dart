import 'package:get/get.dart';

import '../../../../domain/core/model/user_model.dart';
import '../../../../infrastructure/dal/controller/global_controller.dart';
import '../../../../infrastructure/dal/util/Global.dart';

class DetailController extends GetxController {
  UserModel? userPartner;
  late UserModel user;
  String type = "";
  late UserModel currentUser;
  String interestText = "";
  String desiresText = "";
  bool cekpartner = false;
  bool isMe = false;
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    currentUser = Get.find<GlobalController>().currentUser.value!;
    userPartner = Get.arguments['userPartner'];
    user = Get.arguments['user'];
    type = Get.arguments['userPartner'] ?? "";
    isMe = user.id == currentUser.id;
    if (user.relasi.value != null &&
        user.relasi.value!.partner!.partnerId.isNotEmpty) {
      cekpartner = true;
    }
    if (user.desires.isNotEmpty) {
      for (int index = 0; index <= user.desires.length - 1; index++) {
        if (desiresText.isEmpty) {
          desiresText = Global().capitalize(user.desires[index]);
          print(desiresText);
        } else {
          desiresText += ", " + Global().capitalize(user.desires[index]);
        }
      }
    }

    if (user.interest.isNotEmpty) {
      for (int index = 0; index <= user.interest.length - 1; index++) {
        if (interestText.isEmpty) {
          interestText = Global().capitalize(user.interest[index]);
        } else {
          interestText +=
              ", " + Global().capitalize(user.interest[index]);
        }
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
