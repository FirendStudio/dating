import 'dart:io';
import 'package:apple_sign_in/apple_sign_in.dart' as i;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:hookup4u/Screens/Welcome.dart';
import 'package:hookup4u/Screens/auth/otp.dart';
import 'package:hookup4u/models/custom_web_view.dart';
import 'package:hookup4u/util/color.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:easy_localization/easy_localization.dart';

class Login extends StatelessWidget {
  static const your_client_id = '00000000000000';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const your_redirect_url = 'https://h*****firebaseapp.com/__/auth/handler';

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: new PreferredSize(
          child: new Container(
            padding: new EdgeInsets.only(
                top: MediaQuery.of(context).padding.top
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  primaryColor,
                  primaryColor
                ]),
            ),
          ),
          preferredSize: new Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.1,
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              color: Colors.white),
          child: ListView(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: WaveClipper2(),
                    child: Container(
                      child: Column(),
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        darkPrimaryColor,
                        primaryColor.withOpacity(.15)
                      ])),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper3(),
                    child: Container(
                      child: Column(),
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        darkPrimaryColor,
                        primaryColor.withOpacity(.2)
                      ])),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper1(),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 15,
                          ),
                          Image.asset(
                            "asset/hookup4u-Logo-BW.png",
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [primaryColor, primaryColor])),
                    ),
                  ),
                ],
              ),
              Column(children: <Widget>[
                SizedBox(
                  //height: MediaQuery.of(context).size.height * .1,
                  height: MediaQuery.of(context).size.height * .02,
                ),
                Container(
                  child: Text(
                    // "By tapping 'Log in', you agree with our \n Terms.Learn how we process your data in \n our Privacy Policy and Cookies Policy.".toString(),
                    "By signing in, you are indicating that you have read the Privacy Policy and agree to the Terms of Service",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54,
                      fontSize: Get.height * 0.02,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Material(
                    elevation: 2.0,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: InkWell(
                        child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      primaryColor.withOpacity(.5),
                                      primaryColor.withOpacity(.8),
                                      primaryColor,
                                      primaryColor
                                    ])),
                            height: MediaQuery.of(context).size.height * .065,
                            width: MediaQuery.of(context).size.width * .8,
                            child: Center(
                                child: Text(
                              "LOG IN WITH FACEBOOK".toString(),
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold),
                            ))),
                        onTap: () async {
                          showDialog(
                              context: context,
                              builder: (context) => Container(
                                  height: 30,
                                  width: 30,
                                  child: Center(
                                      child: CupertinoActivityIndicator(
                                    key: UniqueKey(),
                                    radius: 20,
                                    animating: true,
                                  ))));
                          await handleFacebookLogin(context).then((user) {
                            navigationCheck(user, context);
                          }).then((_) {
                            Navigator.pop(context);
                          }).catchError((e) {
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Platform.isIOS
                    ? Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0, left: 30, right: 30),
                        child: i.AppleSignInButton(
                          style: i.ButtonStyle.black,
                          cornerRadius: 50,
                          type: i.ButtonType.defaultButton,
                          onPressed: () async {
                            final User currentUser = await handleAppleLogin().catchError((onError) {
                              SnackBar snackBar =
                                  SnackBar(content: Text(onError));
                              _scaffoldKey.currentState.showSnackBar(snackBar);
                            });
                            if (currentUser != null) {
                              print(
                                  'usernaem ${currentUser.displayName} \n photourl ${currentUser.photoURL}');
                              // await _setDataUser(currentUser);
                              navigationCheck(currentUser, context);
                            }
                          },
                        ),
                      )
                    : Container(),
                OutlineButton(
                  child: Container(
                    height: MediaQuery.of(context).size.height * .065,
                    width: MediaQuery.of(context).size.width * .75,
                    child: Center(
                        child: Text("LOG IN WITH PHONE NUMBER".toString(),
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold))),
                  ),
                  borderSide: BorderSide(
                      width: 1, style: BorderStyle.solid, color: primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  onPressed: () {
                    bool updateNumber = false;
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => OTP(updateNumber)));
                  },
                ),
              ]),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       Text(
              //         "Trouble logging in?".toString(),
              //         style: TextStyle(
              //             color: Colors.black,
              //             fontSize: Get.height * 0.018,
              //             fontWeight: FontWeight.normal),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: Get.height * 0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () => _launchURL(
                        "https://jablesscupid.com/privacy-policy/"), //TODO: add privacy policy
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 4,
                    width: 4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue),
                  ),
                  GestureDetector(
                    child: Text(
                      "Terms & Conditions",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () => _launchURL(
                        "https://jablesscupid.com/terms-conditions/"), //TODO: add Terms and conditions
                  ),
                ],
              ),
              // Container(
              //   child: StreamBuilder<QuerySnapshot>(
              //     stream: FirebaseFirestore.instance.collection('Language').snapshots(),
              //     builder: (context, snapshot) {
              //       if (!snapshot.hasData) {
              //         return Center(
              //             // child: Text('Lanuage not Found'),
              //             );
              //       }
              //       return Column(
              //         children: snapshot.data.docs.map((document) {
              //           if (document['spanish'] == true &&
              //               document['english'] == true) {
              //             return Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 FlatButton(
              //                   child: Text(
              //                     "English".toString(),
              //                     style: TextStyle(color: Colors.pink),
              //                   ),
              //                   onPressed: () {
              //                     // context.setLocale(Locale('en', 'US'));
              //                     // EasyLocalization.of(context).locale =
              //                     //     Locale('en', 'US');
              //                     Navigator.pushReplacement(
              //                         context,
              //                         MaterialPageRoute(
              //                           builder: (context) => Login(),
              //                         ));
              //                   },
              //                 ),
              //                 FlatButton(
              //                   child: Text(
              //                     "Spanish",
              //                     style: TextStyle(color: Colors.pink),
              //                   ),
              //                   onPressed: () {
              //                     context.locale = Locale('es', 'ES');
              //
              //                     // EasyLocalization.of(context).locale =
              //                     //     Locale('es', 'ES');
              //                     Navigator.pushReplacement(
              //                         context,
              //                         MaterialPageRoute(
              //                           builder: (context) => Login(),
              //                         ));
              //                   },
              //                 ),
              //               ],
              //             );
              //           } else {
              //             return Text('');
              //           }
              //         }).toList(),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Exit'.toString()),
              content: Text('Do you want to exit the app?'.toString()),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'.toString()),
                ),
                FlatButton(
                  onPressed: () => SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop'),
                  child: Text('Yes'.toString()),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
        user =
            (await FirebaseAuth.instance.signInWithCredential(facebookAuthCred))
                .user;

        print('user $user');
      } catch (e) {
        print('Error $e');
      }
    }
    return user;
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future navigationCheck(User currentUser, context) async {
    await FirebaseFirestore.instance.collection('Users')
        .where('userId', isEqualTo: currentUser.uid).get().then((QuerySnapshot snapshot) async {
          print("masuk sini 1");
          print(snapshot.docs);
          if (snapshot.docs.length > 0) {
            print("masuk sini 2");
            var location;
            // snapshot.docs.map((e) {
            //   print(e.get('phoneNumber'));
            //   location = e.get('location');
            //   print(e['location']);
            // });

            var data = snapshot.docs.map((doc) => doc.get('location')).toList();
            print(data);
            // print("Location : " + location.toString());
            if (data == null) {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (context) => Welcome()));

            } else {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => Tabbar(null, null)));
            }

          } else {
            print("masuk sini 3");
            await _setDataUser(currentUser);
            Navigator.push(
                context, CupertinoPageRoute(builder: (context) => Welcome()));
          }

        // if (snapshot.docs[0].data['location'] != null) {

    });
  }

  Future<User> handleAppleLogin() async {
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

              OAuthProvider oAuthProvider =
                  new OAuthProvider("apple.com");
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

            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('An error occured. Please Try again.'),
              duration: Duration(seconds: 8),
            ));
            break;

          case i.AuthorizationStatus.cancelled:
            print('User cancelled');
            break;
        }
      } catch (error) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('$error.'),
          duration: Duration(seconds: 8),
        ));
        print("error with apple sign in");
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Apple SignIn is not available for your device'),
        duration: Duration(seconds: 8),
      ));
    }
    return user;
  }
}

class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 29 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 60);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 15 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 40);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * .7, size.height - 40);
    var firstControlPoint = Offset(size.width * .25, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 45);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

Future _setDataUser(User user) async {
  await FirebaseFirestore.instance.collection("Users").doc(user.uid).set(
    {
      'userId': user.uid,
      'UserName': user.displayName ?? '',
      'Pictures': FieldValue.arrayUnion([
        user.photoURL != null
            ? user.photoURL + '?width=9999'
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxUC64VZctJ0un9UBnbUKtj-blhw02PeDEQIMOqovc215LWYKu&s'
      ]),
      'phoneNumber': user.phoneNumber,
      'timestamp': FieldValue.serverTimestamp()
    },
    // merge: true,
  );


}

class FirstLogin extends StatefulWidget {
  @override
  _FirstLogin createState() => _FirstLogin();
}

class _FirstLogin extends State<FirstLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  height: MediaQuery.of(context).size.height * .6,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: Get.height * 0.1,
                        ),
                        Image.asset(
                          "asset/images/logo1.png",
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Are you 18 years of age? In order to use this app you must be 18 years old or over.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: Get.height * 0.025,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        SizedBox(
                          height: Get.height * 0.02,
                        ),

                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "If you aren't please leave and do not continue.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: Get.height * 0.025,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, top: 0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  primaryColor.withOpacity(.5),
                                  primaryColor.withOpacity(.8),
                                  primaryColor,
                                  primaryColor
                                ])),
                        height: MediaQuery.of(context).size.height * .065,
                        width: MediaQuery.of(context).size.width * .75,
                        child: Center(
                            child: Text(
                              "I'm 18+",
                              style: TextStyle(
                                  fontSize: Get.height * 0.022,
                                  color: textColor,
                                  fontWeight: FontWeight.bold),
                            ))),
                    onTap: () async {

                      Get.to(()=>Login());

                    },
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

