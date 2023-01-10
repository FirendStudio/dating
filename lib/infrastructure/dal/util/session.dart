import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:hookup4u/domain/core/model/user_model.dart';

class Session {
  var storage = GetStorage();

  void saveUser(UserModel userModel) async {
    await storage.write("user", jsonEncode(userModel));
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
}
