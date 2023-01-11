import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/user_model.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';

class DetailPartnerController extends GetxController {
  late UserModel userPartner;
  late UserModel user;
  String type = "";
  UserModel currentUser = Get.find<GlobalController>().currentUser.value!;
  String interestText = "";
  String desiresText = "";
  bool cekpartner = false;
  bool isMe = false;
  
  @override
  void onInit() {
    super.onInit();
    userPartner = Get.arguments['userPartner'];
    user = Get.arguments['user'];
    type = Get.arguments['userPartner'] ?? "";
    isMe = userPartner.id == currentUser.id;
    if (userPartner.relasi.value != null &&
        userPartner.relasi.value!.partner!.partnerId.isNotEmpty) {
      cekpartner = true;
    }
    if (userPartner.desires.isNotEmpty) {
      for (int index = 0; index <= userPartner.desires.length - 1; index++) {
        if (desiresText.isEmpty) {
          desiresText = Global().capitalize(userPartner.desires[index]);
          print(desiresText);
        } else {
          desiresText += ", " + Global().capitalize(userPartner.desires[index]);
        }
      }
    }

    if (userPartner.interest.isNotEmpty) {
      for (int index = 0; index <= userPartner.interest.length - 1; index++) {
        if (interestText.isEmpty) {
          interestText = Global().capitalize(userPartner.interest[index]);
        } else {
          interestText +=
              ", " + Global().capitalize(userPartner.interest[index]);
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
