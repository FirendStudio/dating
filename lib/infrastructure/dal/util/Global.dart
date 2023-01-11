import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/color.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;

import '../../../domain/core/model/Relationship.dart';
import '../../../domain/core/model/user_model.dart';
import '../../navigation/routes.dart';
import '../controller/global_controller.dart';

class Global {
  static String font = "Arial";
  String readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var format = new DateFormat('HH:mm a');
    var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';
    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + 'DAY AGO';
      } else {
        time = diff.inDays.toString() + 'DAYS AGO';
      }
    }
    return time;
  }

  double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  showInfoDialog(String text) {
    Get.snackbar("Info", text);
  }

  launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchURL(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Map<String, dynamic> getLoginType(
      String metode, String uid, Map<String, dynamic> loginID) {
    if (metode == "apple.com" || metode == "apple") {
      loginID['apple'] = uid;
      print("Login with apple");
    } else if (metode == "fb") {
      loginID['fb'] = uid;
      print("Login With Facebook");
    } else if (metode == "google" || metode == 'google.com') {
      loginID['google'] = uid;
      print("Login With Google");
    } else {
      loginID['phone'] = uid;
      print("Login With Phone");
    }
    return loginID;
  }

  Future<Map<String, dynamic>?> getLocationCoordinates() async {
    loc.Location location = loc.Location();
    try {
      await location.serviceEnabled().then((value) async {
        if (!value) {
          await location.requestService();
        }
      });
      final coordinates = await location.getLocation();
      return await coordinatesToAddress(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> coordinatesToAddress(
      {latitude, longitude}) async {
    try {
      Map<String, dynamic> obj = {};
      final coordinates = Coordinates(latitude, longitude);
      List<Address> result =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      String currentAddress =
          "${result.first.locality ?? ''} ${result.first.subLocality ?? ''} ${result.first.subAdminArea ?? ''} ${result.first.countryName ?? ''}, ${result.first.postalCode ?? ''}";
      print("Address : " + result.first.toMap().toString());
      print(currentAddress);
      obj['PlaceName'] = currentAddress;
      obj['latitude'] = latitude;
      obj['longitude'] = longitude;
      obj['countryName'] = result.first.countryName ?? "";
      obj['countryID'] = result.first.countryCode ?? "";
      obj['data'] = result.first.toMap();

      return obj;
    } catch (_) {
      print(_);
      return null;
    }
  }

  String capitalize(String text) {
    if (text.isEmpty) {
      return "";
    }
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  Future<Relationship> getRelationship(String idUser) async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection("Relationship")
        .doc(idUser)
        .get();

    if (!data.exists) {
      await setNewRelationship(idUser);
      data = await FirebaseFirestore.instance
          .collection("Relationship")
          .doc(idUser)
          .get();
    }
    return Relationship.fromDocument(data.data() as Map<String, dynamic>);
  }

  setNewRelationship(String uid) async {
    Map<String, dynamic> newRelation = {
      "userId": uid,
      "partner": {
        "partnerId": "",
        "partnerImage": "",
        "partnerName": "",
      },
      "inRelationship": false,
      "pendingReq": [],
      "pendingAcc": [],
      "updateAt": FieldValue.serverTimestamp()
    };

    await FirebaseFirestore.instance
        .collection("Relationship")
        .doc(uid)
        .set(newRelation, SetOptions(merge: true));
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  initProfilPartner(
    UserModel userModel,
  ) async {
    UserModel currentUser = Get.find<GlobalController>().currentUser.value!;
    showDialog(
      context: Get.context!,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      },
    );
    var data = await FirebaseFirestore.instance
        .collection("Users")
        .doc(userModel.relasi.value!.partner!.partnerId)
        .get();

    UserModel userSecondPartner =
        UserModel.fromJson(data.data() as Map<String, dynamic>);
    userSecondPartner.relasi.value =
        await getRelationship(userModel.relasi.value!.partner!.partnerId);
    Get.back();
    userSecondPartner.distanceBW = Global()
        .calculateDistance(
          currentUser.coordinates?['latitude'] ?? 0,
          currentUser.coordinates?['longitude'] ?? 0,
          userSecondPartner.coordinates?['latitude'] ?? 0,
          userSecondPartner.coordinates?['longitude'] ?? 0,
        )
        .round();

    Get.toNamed(Routes.DETAILPARTNER, arguments: {
      "userPartner": userSecondPartner,
      "user": userModel,
      "type": "like",
    });
    // await showDialog(
    //     barrierDismissible: false,
    //     context: Get.context!,
    //     builder: (context) {
    //       return DetailpartnerScreen(
    //           Get.find<NotificationController>().userPartner,
    //           widget.currentUser,
    //           null,
    //           relationshipTemp,
    //           Get.find<NotificationController>().userPartner,
    //           "like");
    //     });
  }

  initProfil(
    UserModel userModel,
  ) async {
    UserModel currentUser = Get.find<GlobalController>().currentUser.value!;
    showDialog(
      context: Get.context!,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      },
    );
    UserModel? userSecondPartner;
    if (userModel.relasi.value!.partner!.partnerId.isNotEmpty) {
      var data = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userModel.relasi.value?.partner?.partnerId)
          .get();

      userSecondPartner =
          UserModel.fromJson(data.data() as Map<String, dynamic>);
      userSecondPartner.relasi.value =
          await getRelationship(userModel.relasi.value!.partner!.partnerId);
      userSecondPartner.distanceBW = Global()
          .calculateDistance(
            currentUser.coordinates?['latitude'] ?? 0,
            currentUser.coordinates?['longitude'] ?? 0,
            userSecondPartner.coordinates?['latitude'] ?? 0,
            userSecondPartner.coordinates?['longitude'] ?? 0,
          )
          .round();
    }

    Get.back();

    Get.toNamed(Routes.DETAIL, arguments: {
      "userPartner": userSecondPartner,
      "user": userModel,
      "type": "like",
    });
    // await showDialog(
    //     barrierDismissible: false,
    //     context: Get.context!,
    //     builder: (context) {
    //       return DetailpartnerScreen(
    //           Get.find<NotificationController>().userPartner,
    //           widget.currentUser,
    //           null,
    //           relationshipTemp,
    //           Get.find<NotificationController>().userPartner,
    //           "like");
    //     });
  }

  disloveFunction(UserModel userModel) async {
    if (kDebugMode) {
      print(userModel.id);
    }
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(Get.find<GlobalController>().currentUser.value?.id)
        .collection("CheckedUser")
        .doc(userModel.id)
        .set({
      'userName': userModel.name,
      'pictureUrl': (userModel.imageUrl[0].runtimeType == String)
          ? userModel.imageUrl[0]
          : userModel.imageUrl[0]['url'],
      'DislikedUser': userModel.id,
      'timestamp': DateTime.now(),
    }, SetOptions(merge: true));
    // listUsers.remove(userModel);
  }

  loveUserFunction(UserModel userModel) async {
    bool cek = false;
    UserModel currentUser = Get.find<GlobalController>().currentUser.value!;
    if (kDebugMode) {
      print(userModel.id);
    }
    var doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(Get.find<GlobalController>().currentUser.value?.id)
        .collection("LikedBy")
        .doc(userModel.id)
        .get();

    print(doc.exists);
    if (doc.exists) {
      cek = true;
      print("Masuk sini");

      Get.find<GlobalController>()
          .sendMatchedFCM(idUser: userModel.id, name: userModel.name);
      showDialog(
          context: Get.context!,
          builder: (ctx) {
            Future.delayed(Duration(milliseconds: 1700), () {
              Navigator.pop(ctx);
            });
            return Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Align(
                alignment: Alignment.topCenter,
                child: Card(
                  child: Container(
                    height: 100,
                    width: 300,
                    child: Center(
                        child: Text(
                      "It's a match\n With ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 30,
                          decoration: TextDecoration.none),
                    )
                        // .tr(args: ['${widget.users[index].name}']),
                        ),
                  ),
                ),
              ),
            );
          });
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.id)
          .collection("Matches")
          .doc(userModel.id)
          .set({
        'Matches': userModel.id,
        'isRead': false,
        'userName': userModel.name,
        'pictureUrl': (userModel.imageUrl[0].runtimeType == String)
            ? userModel.imageUrl[0]
            : userModel.imageUrl[0]['url'],
        'timestamp': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userModel.id)
          .collection("Matches")
          .doc(currentUser.id)
          .set({
        'Matches': currentUser.id,
        'userName': currentUser.name,
        'pictureUrl': (currentUser.imageUrl[0].runtimeType == String)
            ? currentUser.imageUrl[0]
            : currentUser.imageUrl[0]['url'],
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
    }

    if (!cek) {
      Get.find<GlobalController>()
          .sendLikedFCM(idUser: userModel.id, name: userModel.name);
    }

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.id)
        .collection("CheckedUser")
        .doc(userModel.id)
        .set({
      'userName': userModel.name,
      'pictureUrl': (userModel.imageUrl[0].runtimeType == String)
          ? userModel.imageUrl[0]
          : userModel.imageUrl[0]['url'],
      'LikedUser': userModel.id,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userModel.id)
        .collection("LikedBy")
        .doc(currentUser.id)
        .set({
      'userName': currentUser.name,
      'pictureUrl': (currentUser.imageUrl[0].runtimeType == String)
          ? currentUser.imageUrl[0]
          : currentUser.imageUrl[0]['url'],
      'LikedBy': currentUser.id,
      'timestamp': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));

    // if(data.indexUser+1 == data.users.length){
    //
    //   data.indexUser--;
    // }else{
    //   data.users.removeAt(data.indexUser);
    // }
    // data.userRemoved.clear();
    // data.userRemoved.add(data.users[data.indexUser]);
    print("selesai");
    // if (data.indexUser < (data.users.length + 1)) {
    //   print("clear");
    //   data.userRemoved.clear();
    //   data.userRemoved.add(data.users[data.indexUser]);
    //   data.users.removeAt(data.indexUser);
    //   if (data.users.length == 1) {
    //     data.indexUser = 0;
    //   }
    // }
  }
}
