import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../util/Global.dart';

class FCMService {
  Future sendFCM(
      {required Map<String, String> data, required String to}) async {
    try {
      var headers = {
        'Authorization':
            'key=AAAASpwPVWs:APA91bFvN_Vt8rhde5jUzFM7WdPZbKKg7tjPT6UAXMJnTU30ys4Be86dV1UOocEjJw3Bvir4gkoIa1lpgKauXcKtPWzKKe-cO-quC4AFdn4zPyhWKL-aGHh2kiewAglpTR9MhnImRGH9',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
      request.body = json.encode({
        "notification": data,
        "data": data,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "to": to
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      return response;
    } catch (e) {
      print(e.toString());
      Global().showInfoDialog(e.toString());
      return null;
    }
  }

  Future sendCustomFCM({
    required Map<String, String> data,
    required Map<String, String> notif,
    required String to,
  }) async {
    try {
      var headers = {
        'Authorization':
            'key=AAAASpwPVWs:APA91bFvN_Vt8rhde5jUzFM7WdPZbKKg7tjPT6UAXMJnTU30ys4Be86dV1UOocEjJw3Bvir4gkoIa1lpgKauXcKtPWzKKe-cO-quC4AFdn4zPyhWKL-aGHh2kiewAglpTR9MhnImRGH9',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
      request.body = json.encode({
        "notification": data,
        "data": data,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "to": to
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      return response;
    } catch (e) {
      print(e.toString());
      Global().showInfoDialog(e.toString());
      return null;
    }
  }
}
