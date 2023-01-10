import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apple_sign_in/apple_sign_in.dart' as i;
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';

class AuthLoginController extends GetxController {
  RxBool isChecked = false.obs;

  Future<void> handleAppleLogin(GlobalKey<ScaffoldState> scaffoldKey) async {
    User? user;
    if (await i.AppleSignIn.isAvailable()) {
      try {
        final i.AuthorizationResult result =
            await i.AppleSignIn.performRequests([
          i.AppleIdRequest(requestedScopes: [i.Scope.email, i.Scope.fullName])
        ]).catchError((onError) {
          print("inside $onError");
        });

        // print("masuk sini cuy");

        switch (result.status) {
          case i.AuthorizationStatus.authorized:
            try {
              print("successfull sign in");
              final i.AppleIdCredential appleIdCredential = result.credential;

              OAuthProvider oAuthProvider = OAuthProvider("apple.com");
              final AuthCredential credential = oAuthProvider.credential(
                idToken: String.fromCharCodes(appleIdCredential.identityToken),
                accessToken:
                    String.fromCharCodes(appleIdCredential.authorizationCode),
              );

              user = (await Get.find<GlobalController>()
                      .auth
                      .signInWithCredential(credential))
                  .user;
              print("signed in as " + user.toString());
            } catch (error) {
              print("Error $error");
              return;
            }
            break;
          case i.AuthorizationStatus.error:
            // do something
            Get.showSnackbar(
              GetSnackBar(
                message: 'An error occured. Please Try again.',
                duration: Duration(seconds: 8),
              ),
            );
            return;
          // break;

          case i.AuthorizationStatus.cancelled:
            print('User cancelled');
            return;
          // break;
        }
      } catch (error) {
        Get.showSnackbar(
          GetSnackBar(
            message: '$error.',
            duration: Duration(seconds: 8),
          ),
        );
        print("error with apple sign in");
        return;
      }
    } else {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Apple SignIn is not available for your device',
          duration: Duration(seconds: 8),
        ),
      );
      return;
    }
    print('username ${user?.displayName} \n photourl ${user?.photoURL}');
    // await _setDataUser(currentUser);
    if (user!.providerData.length > 1) {
      for (int index = 0; index <= user.providerData.length - 1; index++) {
        if (user.providerData.length - 1 == index) {
          await Get.find<LoginController>().navigationCheck(
              user, context, user.providerData[index].providerId, false);
          break;
        }
        await Get.find<LoginController>().navigationCheck(currentUser, context,
            currentUser.providerData[index].providerId, true);
      }
      return;
    }
    loginController.navigationCheck(currentUser, context, "apple.com", false);
  }
}
