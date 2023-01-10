import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;

import '../../../domain/core/model/Relationship.dart';

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

  showDialog(String text) {
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
}
