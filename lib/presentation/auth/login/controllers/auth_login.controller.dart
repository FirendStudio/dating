import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:apple_sign_in/apple_sign_in.dart' as i;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../../../domain/core/model/custom_web_view.dart';
import '../../../../infrastructure/dal/util/Global.dart';
import '../../../../infrastructure/dal/util/session.dart';

class AuthLoginController extends GetxController {
  static const your_client_id = '709280423766575';
  static const your_redirect_url =
      'https://jablesscupid.firebaseapp.com/__/auth/handler';
  RxBool isChecked = false.obs;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      // 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  GoogleSignInAccount? googleUser;

  Future<void> handleAppleLogin() async {
    User? user;
    final AuthorizationResult result = await TheAppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);
    try {
      switch (result.status) {
        case AuthorizationStatus.authorized:

          // Store user ID
          Session().saveLoginType("apple");
          final AppleIdCredential appleIdCredential = result.credential!;

          OAuthProvider oAuthProvider = OAuthProvider("apple.com");
          final AuthCredential credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode!),
          );

          user = (await Get.find<GlobalController>()
                  .auth
                  .signInWithCredential(credential))
              .user;
          print('username ${user?.displayName} \n photourl ${user?.photoURL}');
          // await _setDataUser(currentUser);
          if (user == null) {
            return;
          }
          Get.find<GlobalController>().navigationCheck(user, "apple.com");
          break;

        case AuthorizationStatus.error:
          // print("Sign in failed: ${result.error.localizedDescription}");
          Get.showSnackbar(
            GetSnackBar(
              // message: 'An error occured. Please Try again.',
              message: "Sign in failed: ${result.error?.localizedDescription}",
              duration: Duration(seconds: 8),
            ),
          );
          break;

        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> handleGoogleLogin(context) async {
    googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return;
    }

    if (kDebugMode) {
      print(googleUser?.id);
    }
    final googleAuth = await googleUser?.authentication;
    if (googleAuth == null) {
      return;
    }
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Once signed in, return the UserCredential
    try {
      var data = await Get.find<GlobalController>()
          .auth
          .signInWithCredential(credential);
      if (kDebugMode) {
        print(Get.find<GlobalController>().auth.currentUser?.providerData);
      }
      googleSignIn.signOut();
      if (data.user == null) {
        return;
      }
      Session().saveLoginType("google");
      Get.find<GlobalController>().navigationCheck(data.user!, "google");
    } catch (e) {
      Global().showInfoDialog(e.toString());
    }
  }

  Future<void> handleFacebookLogin(context) async {
    User? user;
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWebView(
          selectedUrl:
              'https://www.facebook.com/dialog/oauth?client_id=$your_client_id&redirect_uri=$your_redirect_url&response_type=token&scope=email,public_profile,',
        ),
        maintainState: true,
      ),
    );
    if (result != null) {
      try {
        final facebookAuthCred = FacebookAuthProvider.credential(result);
        user =
            (await FirebaseAuth.instance.signInWithCredential(facebookAuthCred))
                .user;
        if (user == null) {
          return;
        }
        Session().saveLoginType("fb");
        Get.find<GlobalController>().navigationCheck(user, "fb");
        print('user $user');
      } catch (e) {
        print('Error $e');
      }
    }
    // return user;
  }
}
