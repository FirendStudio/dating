import 'dart:io';
import 'dart:math';
// import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hookup4u/presentation/notif/controllers/notif.controller.dart';
import 'package:image/image.dart' as i;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_geocoder/geocoder.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/color.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;

import '../../../domain/core/model/Relationship.dart';
import '../../../domain/core/model/user_model.dart';
import '../../navigation/routes.dart';
import '../controller/global_controller.dart';
import 'general.dart';

class Global {
  static String font = "Arial";
  ImagePicker imagePicker = ImagePicker();
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
    Get.snackbar("Information", text,
        colorText: primaryColor, backgroundColor: Colors.white);
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
      // print(lati)
      List<Placemark> result =
          await placemarkFromCoordinates(latitude, longitude);
      Map<String, dynamic> obj = {};
      String currentAddress =
          "${result.first.locality ?? ''} ${result.first.subLocality ?? ''} ${result.first.administrativeArea ?? ''} ${result.first.country ?? ''}, ${result.first.postalCode ?? ''}";
      
      if (kDebugMode) {
        print(result);
        print("Address : " + result.first.toJson().toString());
        print(currentAddress);
      }
      obj['PlaceName'] = currentAddress;
      obj['latitude'] = latitude;
      obj['longitude'] = longitude;
      obj['countryName'] = result.first.country ?? "";
      obj['countryID'] = result.first.isoCountryCode ?? "";
      obj['data'] = result.first.toJson();
      // final coordinates = Coordinates(latitude, longitude);
      // List<Address> result = await Geocoder.google(googleApiKey).findAddressesFromCoordinates(coordinates);
      // await Geocoder.local.findAddressesFromCoordinates(coordinates);
      // String currentAddress =
      //     "${result.first.locality ?? ''} ${result.first.subLocality ?? ''} ${result.first.subAdminArea ?? ''} ${result.first.countryName ?? ''}, ${result.first.postalCode ?? ''}";
      // print("Address : " + result.first.toMap().toString());
      // print(currentAddress);
      // obj['PlaceName'] = currentAddress;
      // obj['latitude'] = latitude;
      // obj['longitude'] = longitude;
      // obj['countryName'] = result.first.countryName ?? "";
      // obj['countryID'] = result.first.countryCode ?? "";
      // obj['data'] = result.first.toMap();

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
    DocumentSnapshot data =
        await queryCollectionDB("Relationship").doc(idUser).get();

    if (!data.exists) {
      await setNewRelationship(idUser);
      data = await queryCollectionDB("Relationship").doc(idUser).get();
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

    await queryCollectionDB("Relationship")
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
      barrierDismissible: false,
      context: Get.context!,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        );
      },
    );
    var data = await queryCollectionDB("Users")
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
  }

  initProfil(UserModel userModel, {String type = "like"}) async {
    UserModel currentUser = Get.find<GlobalController>().currentUser.value!;
    showDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        );
      },
    );
    UserModel? userSecondPartner;
    if (userModel.relasi.value!.partner!.partnerId.isNotEmpty) {
      var data = await queryCollectionDB("Users")
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
      "type": type,
    });
  }

  disloveFunction(UserModel userModel) async {
    if (kDebugMode) {
      print(userModel.id);
    }
    await queryCollectionDB('Users')
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
    var doc = await queryCollectionDB('Users')
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
      await queryCollectionDB('Users')
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
      await queryCollectionDB('Users')
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

    await queryCollectionDB('Users')
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
    await queryCollectionDB('Users')
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

  chatId(String currentUser, String sender) {
    String groupChatId = "";
    if (currentUser.hashCode <= sender.hashCode) {
      return groupChatId = '$currentUser-$sender';
    } else {
      return groupChatId = '$sender-$currentUser';
    }
  }

  setNewOptionMessage(String chatId) {
    queryCollectionDB("chats").doc(chatId).set({
      "active": true,
      "docId": chatId,
      "isclear1": false,
      "isclear2": false,
    });
  }

  leaveWidget(
      UserModel sender, UserModel second, String idChat, String type) async {
    return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: CupertinoAlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Leave Conversation"),
              ],
            ),
            content: Column(
              children: [
                Text(
                  "Are you sure that you would like to leave this conversation?",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () =>
                            leaveFunction(sender, second, idChat, type),
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 0,
                            top: 4,
                            bottom: 4,
                            right: 6,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                            // borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Text(
                            "Yes",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          // if (type == "chat") {
                          //   Get.back();
                          // }
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 6,
                            top: 4,
                            bottom: 4,
                            right: 0,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                            // borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Text(
                            "No",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            insetAnimationCurve: Curves.decelerate,
            actions: [],
          ),
        );
      },
    );
  }

  leaveFunction(
      UserModel sender, UserModel second, String idChat, String type) async {
    await queryCollectionDB("chats").doc(idChat).collection('messages').add({
      'type': 'Leave',
      'text': "${sender.name} has left the conversation.",
      'sender_id': sender.id,
      'receiver_id': second.id,
      'isRead': false,
      'image_url': "",
      'time': FieldValue.serverTimestamp(),
    });
    Get.find<GlobalController>().sendLeaveFCM(
      idUser: second.id,
      name: Get.find<GlobalController>().currentUser.value?.name ?? "",
    );
    await Get.find<NotifController>().filterMatches();
    // if (type == 'chat') {
    //   Get.back();
    // }
    Get.back();
  }

  restoreLeaveWidget(UserModel sender, UserModel second, String idMessage,
      String idChat, String type) async {
    return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: CupertinoAlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Resume Chat"),
              ],
            ),
            content: Column(
              children: [
                Text(
                  "Are you sure that you want to resume this chat?",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () => restoreLeaveFunction(
                            sender, second, idMessage, idChat, type),
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 0,
                            top: 4,
                            bottom: 4,
                            right: 6,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                            // borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Text(
                            "Yes",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 6,
                            top: 4,
                            bottom: 4,
                            right: 0,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                            // borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Text(
                            "No",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            insetAnimationCurve: Curves.decelerate,
            actions: [],
          ),
        );
      },
    );
  }

  restoreLeaveFunction(UserModel sender, UserModel second, String idMessage,
      String chatId, String type) async {
    await queryCollectionDB("chats")
        .doc(chatId)
        .collection('messages')
        .doc(idMessage)
        .delete()
        .then((value) async {
      await Get.find<NotifController>().filterMatches();
      Get.find<GlobalController>().sendRestoreLeaveFCM(
        idUser: second.id,
        name: Get.find<GlobalController>().currentUser.value?.name ?? "",
      );
      // if(type != "notif"){
      //   Get.back();
      // }
      Get.back();
    });
  }

  disconnectWidget(
      UserModel sender, UserModel second, String idChat, String type) async {
    return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: CupertinoAlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Permanently Disconnect"),
              ],
            ),
            content: Column(
              children: [
                Text(
                  "This action will permanently disconnect you from ${second.name}." +
                      "\nAre you sure you want to proceed?",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () =>
                            disconnectFunction(sender, second, idChat, type),
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 0,
                            top: 4,
                            bottom: 4,
                            right: 6,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                            // borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Text(
                            "Yes",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          // if (type == "chat") {
                          //   Get.back();
                          // }
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 6,
                            top: 4,
                            bottom: 4,
                            right: 0,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                            // borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Text(
                            "No",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            insetAnimationCurve: Curves.decelerate,
            actions: [],
          ),
        );
      },
    );
  }

  disconnectFunction(
      UserModel sender, UserModel second, String chatId, String type) async {
    var result = await queryCollectionDB("chats")
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty && result.docs.first['type'] == "Leave") {
      if (kDebugMode) {
        print(result.docs.first['type']);
      }
      await queryCollectionDB("chats")
          .doc(chatId)
          .collection('messages')
          .doc(result.docs.first.id)
          .delete();
    }
    // Get.back();
    // return;
    await queryCollectionDB("chats").doc(chatId).collection('messages').add({
      'type': 'Disconnect',
      'text': "${sender.name} has blocked you",
      'sender_id': sender.id,
      'receiver_id': second.id,
      'isRead': false,
      'image_url': "",
      'time': FieldValue.serverTimestamp(),
    });
    queryCollectionDB("chats")
        .doc(chatId)
        .set({"active": false, "docId": chatId}, SetOptions(merge: true)).then(
            (value) {
      Get.find<GlobalController>().sendDisconnectFCM(
        idUser: second.id,
        name: Get.find<GlobalController>().currentUser.value?.name ?? "",
      );
      Get.back();
      // Get.to(()=>Tabbar(null, null));
    });
  }

  Future<File?> compressimage(File image) async {
    try {
      final tempdir = await getTemporaryDirectory();
      final path = tempdir.path;
      i.Image imagefile = i.decodeImage(image.readAsBytesSync())!;
      final compressedImagefile = File('$path.jpg')
        ..writeAsBytesSync(i.encodeJpg(imagefile, quality: 80));
      return compressedImagefile;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> deletePartner({required String Uid}) async {
    try {
      await setNewRelationship(Uid);
      await setNewRelationship(globalController.currentUser.value?.id ?? "");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showInfoDialog(e.toString());
      return false;
    }

    return true;
  }

  Future<File?> pickImage(ImageSource source, {bool metode = false}) async {
    final XFile? file =
        await imagePicker.pickImage(source: source, imageQuality: 50);

    if (file == null) {
      return null;
    }
    if (metode) {
      File? croppedFile = await ImageCropper().cropImage(
          sourcePath: file.path,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      // image = file;
      return croppedFile;
    }
    return File(file.path);
  }

  bool searchFirstUser(List<String> list, String idUser) {
    var temp = list.firstWhereOrNull((element) => idUser == element);
    if (temp != null) {
      return true;
    }
    return false;
  }

  // Future<void> handleCameraAndMic(callType) async {
  //   if (callType == "VideoCall") {
  //     Map<Permission, PermissionStatus> statuses = await [
  //       Permission.camera,
  //       Permission.microphone,
  //     ].request();
  //     print(statuses);
  //   } else {
  //     Map<Permission, PermissionStatus> statuses = await [
  //       Permission.microphone,
  //     ].request();
  //     print(statuses);
  //   }
  // }
}
