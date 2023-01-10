import 'dart:math';

import 'package:flutter_geocoder/geocoder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;

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
}
