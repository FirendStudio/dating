import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:hookup4u/domain/core/model/user_model.dart';

class Session {
  var storage = GetStorage();

  void saveUser(UserModel userModel) async {
    await storage.write("user", jsonEncode(userModel));
  }

  void clearDate() async {
    await storage.erase();
  }

  UserModel? getUser() {
    UserModel? userModel;
    String? temp = storage.read("user");
    if (temp != null) {
      userModel = UserModel.fromJson(jsonDecode(temp));
    }
    return userModel;
  }

  void saveIntroduction(bool isIntroduction) async {
    await storage.write("isIntroduction", isIntroduction);
  }

  bool getIntroduction() {
    return storage.read("isIntroduction") ?? false;
  }

  void saveIntroductionAfterLogin(bool isIntroduction) async {
    await storage.write("isIntroductionLogin", isIntroduction);
  }

  bool getIntroductionAfterLogin() {
    return storage.read("isIntroductionLogin") ?? false;
  }

  void saveLoginType(String loginType) async {
    await storage.write("metode", loginType);
  }

  String getLoginType() {
    return storage.read("metode") ?? "";
  }

  void saveSwipedUser(List<String> list) async {
    await storage.write("listUidSwiped", list);
  }

  List<String> getSwipedUser() {
    if ((storage.read("listUidSwiped") ?? []).isNotEmpty) {
      return storage.read("listUidSwiped").cast<String>();
    }
    return [];
  }
}
