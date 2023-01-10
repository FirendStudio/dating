import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
          apiKey: "AIzaSyByhi7SM_wtdRgE-rpqLUQtQ3YM60uxwE0",
          authDomain: "jablesscupid.firebaseapp.com",
          projectId: "jablesscupid",
          storageBucket: "jablesscupid.appspot.com",
          messagingSenderId: "320445830507",
          appId: "1:320445830507:web:e6a5def4566aa0516e282e",
          measurementId: "G-2L4PN7MMVE"
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
        apiKey: 'AIzaSyB5T6M2gW8PAleR5rzr0lKAQhMoJLOa7TI',
        projectId: 'jablesscupid',
        messagingSenderId: '320445830507',
        iosBundleId: 'com.jab.jablesscupid',
        iosClientId:
        '320445830507-rmqfclnkr3d182vb5flk1ho3b1ismkn1.apps.googleusercontent.com',
        androidClientId:
        '320445830507-4np897s0ir6lj427il1rea2f8voerhae.apps.googleusercontent.com',
        storageBucket: 'jablesscupid.appspot.com',
        // databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
      );
    } else {
      // Android
      return const FirebaseOptions(
        appId: '1:448618578101:android:3ad281c0067ccf97ac3efc',
        apiKey: 'AIzaSyCuu4tbv9CwwTudNOweMNstzZHIDBhgJxA',
        projectId: 'react-native-firebase-testing',
        messagingSenderId: '448618578101',
      );
    }
  }
}