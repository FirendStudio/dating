import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apple_sign_in/apple_sign_in.dart' as i;
import '../Screens/Tab.dart';
import '../Screens/Welcome.dart';
import '../models/custom_web_view.dart';

class LoginController extends GetxController{
  static const your_client_id = '709280423766575';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const your_redirect_url = 'https://jablesscupid.firebaseapp.com/__/auth/handler';
  var storage = GetStorage();
  String userId = "";

  Future<User> handleFacebookLogin(context) async {
    User user;
    String result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CustomWebView(
            selectedUrl:
            'https://www.facebook.com/dialog/oauth?client_id=$your_client_id&redirect_uri=$your_redirect_url&response_type=token&scope=email,public_profile,',
          ),
          maintainState: true),
    );
    if (result != null) {
      try {
        final facebookAuthCred =
        FacebookAuthProvider.credential(result);
        user = (await FirebaseAuth.instance.signInWithCredential(facebookAuthCred)).user;

        print('user $user');
      } catch (e) {
        print('Error $e');
      }
    }
    return user;
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future <QuerySnapshot> getUser(User user, String metode) async {
    QuerySnapshot data;
    if(metode == "apple.com" || metode == "apple"){
      data = await FirebaseFirestore.instance.collection('Users')
      // .where('userId', isEqualTo: user.uid)
          .where('LoginID.apple', isEqualTo: user.uid).limit(1)
          .get();
    }else if(metode == "phone"){
      data = await FirebaseFirestore.instance.collection('Users')
      // .where('userId', isEqualTo: user.uid)
          .where('LoginID.phone', isEqualTo: user.uid).limit(1)
          .get();
    }else{
      data = await FirebaseFirestore.instance.collection('Users')
      // .where('userId', isEqualTo: user.uid)
          .where('LoginID.fb', isEqualTo: user.uid).limit(1)
          .get();
    }

    return data;
  }

  Future<User> handleAppleLogin(GlobalKey<ScaffoldState> scaffoldKey) async {
    User user;
    if (await i.AppleSignIn.isAvailable()) {
      try {
        final i.AuthorizationResult result = await i.AppleSignIn.performRequests([i.AppleIdRequest(requestedScopes: [i.Scope.email, i.Scope.fullName])
        ]).catchError((onError) {
          print("inside $onError");
        });

        print("masuk sini cuy");

        switch (result.status) {
          case i.AuthorizationStatus.authorized:
            try {
              print("successfull sign in");
              final i.AppleIdCredential appleIdCredential = result.credential;

              OAuthProvider oAuthProvider = OAuthProvider("apple.com");
              final AuthCredential credential = oAuthProvider.credential(
                idToken: String.fromCharCodes(appleIdCredential.identityToken),
                accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
              );

              user = (await _auth.signInWithCredential(credential)).user;
              print("signed in as " + user.toString());
            } catch (error) {
              print("Error $error");
            }
            break;
          case i.AuthorizationStatus.error:
          // do something

            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('An error occured. Please Try again.'),
              duration: Duration(seconds: 8),
            ));
            break;

          case i.AuthorizationStatus.cancelled:
            print('User cancelled');
            break;
        }
      } catch (error) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('$error.'),
          duration: Duration(seconds: 8),
        ));
        print("error with apple sign in");
      }
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Apple SignIn is not available for your device'),
        duration: Duration(seconds: 8),
      ));
    }
    return user;
  }

  Future navigationCheck(User currentUser, context, String metode) async {

    print(currentUser);
    QuerySnapshot snapshot = await getUser(currentUser, metode);
    print("masuk sini 1");
    print(snapshot.docs);
    if (snapshot.docs.length > 0) {
      print("masuk sini 2");
      // var location;
      var docs = snapshot.docs.first;
      print(docs.data());
      Map<String, dynamic> data = docs.data();
      try {
        // var data = snapshot.docs.map((doc) => doc.get('location')).toList();
        print(data['userId']);
        storage.write("userId", data['userId']);
        userId = data['userId'];

        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => Tabbar(null, null)));
      } on StateError catch (e) {
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => Welcome()));
      }

    } else {
      print("masuk sini 3");
      await setDataUser(currentUser, metode);
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => Welcome()));
    }
  }

  Future setDataUser(User user, String metode) async {
    print("Metode : " + metode);
    String url = "";
    if(user.photoURL != null){
      url = user.photoURL + '?width=9999';
    }else{
      url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxUC64VZctJ0un9UBnbUKtj-blhw02PeDEQIMOqovc215LWYKu&s";
    }
    var imageData = {
      "url": url,
      "show": "true"
    };
    List image = [imageData];
    var LoginID = {
      "fb" : "",
      "apple" : "",
      "phone" : "",
    };
    var userID = "";
    userID = user.uid;
    if(metode == "apple.com" || metode == "apple"){
      LoginID['apple'] = user.uid;
      print("Login with apple");
      await FirebaseFirestore.instance.collection("Users").doc(userID).set(
          {
            "LoginID" : LoginID,
            "metode" : user.providerData[0].providerId,
            'userId': user.uid,
            'UserName': user.displayName ?? '',
            'Pictures': image,
            'phoneNumber': user.phoneNumber,
            'timestamp': FieldValue.serverTimestamp()
          },
          SetOptions(merge : true)

      );
    }else if (metode == "fb"){
      LoginID['fb'] = user.uid;
      print("Login With Facebook");

      await FirebaseFirestore.instance.collection("Users").doc(userID).set(
          {
            "LoginID" : LoginID,
            "metode" : user.providerData[0].providerId,
            'userId': user.uid,
            'UserName': user.displayName ?? '',
            'Pictures': image,
            'phoneNumber': user.phoneNumber,
            'timestamp': FieldValue.serverTimestamp()
          },
          SetOptions(merge : true)

      );
    }else{
      LoginID['phone'] = user.uid;
      print("Login With Phone");
      await FirebaseFirestore.instance.collection("Users").doc(userID).set(
          {
            "LoginID" : LoginID,
            "metode" : user.providerData[0].providerId,
            'userId': user.uid,
            'UserName': user.displayName ?? '',
            'Pictures': image,
            'phoneNumber': user.phoneNumber,
            'timestamp': FieldValue.serverTimestamp()
          },
          SetOptions(merge : true)

      );
    }

  }

  Future setUserData(Map<String, dynamic> userData) async {
    User user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(Get.find<LoginController>().userId)
        .set(userData,
        SetOptions(merge: true)
    );
  }

}