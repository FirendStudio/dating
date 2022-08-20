import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apple_sign_in/apple_sign_in.dart' as i;
import '../Screens/Profile/EditProfile.dart';
import '../Screens/Tab.dart';
import '../Screens/Welcome.dart';
import '../models/custom_web_view.dart';
import '../util/color.dart';
import 'NotificationController.dart';
import 'TabsController.dart';
import 'package:image/image.dart' as a;

class LoginController extends GetxController{
  static const your_client_id = '709280423766575';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const your_redirect_url = 'https://jablesscupid.firebaseapp.com/__/auth/handler';
  var storage = GetStorage();
  String userId = "";
  final EditProfileState editProfileState = EditProfileState();
  double progress = 0.0;

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
        Get.put(NotificationController());
        Get.put(TabsController());
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
    userId = user.uid;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .set(userData,
        SetOptions(merge: true)
    );

  }

  updateFirstImageProfil() async {
    User user = FirebaseAuth.instance.currentUser;
    String idUser = user.uid;

    await source(Get.context, idUser);
  }

  Future source(
      BuildContext context, String idUser) async {


    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text("Add profile picture"),
              content: StatefulBuilder(
                builder: (BuildContext context2, StateSetter setState2){
                  return Column(
                    children: [
                      Text(
                        "Select source",
                      ),

                    ],
                  );
                },
              ),
              insetAnimationCurve: Curves.decelerate,
              actions: <Widget>[

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.photo_camera,
                          size: 28,
                        ),
                        Text(
                          " Camera",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera, context,
                          idUser);
                      // showDialog(
                      //     context: context,
                      //     builder: (context) {
                      //       getImage(ImageSource.camera, context,
                      //           idUser);
                      //       return Center(
                      //           child: CircularProgressIndicator(
                      //             strokeWidth: 2,
                      //             valueColor: AlwaysStoppedAnimation<Color>(
                      //                 Colors.white),
                      //           ));
                      //     });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.photo_library,
                          size: 28,
                        ),
                        Text(
                          " Gallery",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery, context,
                          idUser);
                      // showDialog(
                      //     barrierDismissible: false,
                      //     context: context,
                      //     builder: (context) {
                      //       getImage(ImageSource.gallery, context, idUser);
                      //       return Center(
                      //           child: CircularProgressIndicator(
                      //             strokeWidth: 2,
                      //             valueColor: AlwaysStoppedAnimation<Color>(
                      //                 Colors.white),
                      //           ));
                      //     });
                    },
                  ),
                ),
              ]);
        });
  }

  Future getImage(
      ImageSource imageSource, context, String idUser) async {
    try {
      var image = await ImagePicker().pickImage(source: imageSource,
          imageQuality: 10
      );
      if (image != null) {
        File croppedFile = await ImageCropper.cropImage(
            sourcePath: image.path,
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
        if (croppedFile != null) {
          await uploadFile(await compressimage(croppedFile), idUser);
        }
      }
      // Navigator.pop(context);
    } catch (e) {
      print("error");
      print(e);
      // Navigator.pop(context);
    }
  }

  Future uploadFile(File image, String idUser) async {

    Get.dialog(
        GetBuilder<LoginController>(builder: (data){
          return CircularPercentIndicator(
            radius: 120.0,
            lineWidth: 13.0,
            animation: true,
            percent: Get.find<LoginController>().progress,
            center: Text(
              "${(Get.find<LoginController>().progress * 100)}%",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0,
                  color: Colors.white
              ),
            ),
            footer: Text(
              "Uploading......",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0,
                  color: Colors.white
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.purple,
          );
        })
    );
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('users/$idUser/${image.hashCode}.jpg');
    UploadTask uploadTask = ref.putFile(File(image.path));
    // var stream = uploadTask.asStream();
    uploadTask.snapshotEvents.listen((event) {
      print("Progress : " + (event.bytesTransferred/event.totalBytes).toString());
      Get.find<LoginController>().progress = (event.bytesTransferred/event.totalBytes).toDouble();
      Get.find<LoginController>().update();
    });

    uploadTask.then((res) async {
      String fileURL = await res.ref.getDownloadURL();

      try {
        Map<String, dynamic> updateObject = {
          "Pictures": [
            {
              "url": fileURL,
              "show": "true"
            }

          ],
        };
        print("object");
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(idUser)
            .set(updateObject,
            SetOptions(merge : true)

        );
        // widget.currentUser.imageUrl.add(fileURL);
        Get.back();
        await Future.delayed(Duration(seconds: 1));
        Get.find<LoginController>().progress = 0.0;
        // if (mounted) setState(() {});
      } catch (err) {
        print("Error: $err");
      }
    });
  }

  Future compressimage(File image) async {
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    a.Image imagefile = a.decodeImage(image.readAsBytesSync());
    final compressedImagefile = File('$path.jpg')
      ..writeAsBytesSync(a.encodeJpg(imagefile, quality: 80));
    // setState(() {
    return compressedImagefile;
    // });
  }

}