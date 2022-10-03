import 'dart:io';
import 'package:apple_sign_in/apple_sign_in.dart' as i;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/LoginController.dart';
import 'package:hookup4u/Screens/auth/otp.dart';
import 'package:hookup4u/util/Global.dart';
import 'package:hookup4u/util/color.dart';

class Login extends StatelessWidget {
  LoginController loginController = Get.put(LoginController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                      padding: EdgeInsets.only(
                        left: Get.width * 0.1,
                        right: Get.width * 0.1,
                      ),
                      // padding: EdgeInsets.all(20),
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
                  padding: EdgeInsets.only(
                    left: Get.width * 0.1,
                    right: Get.width * 0.1,
                  ),
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
                  padding: EdgeInsets.only(top: 10, bottom: 10,
                    left: Get.width * 0.1,
                    right: Get.width * 0.1,
                  ),
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
                                      textBlue,
                                      textBlue,
                                      textBlue,
                                      textBlue
                                    ])),
                            height: MediaQuery.of(context).size.height * .065,
                            width: MediaQuery.of(context).size.width * .8,
                            child: Center(
                                child: Text(
                              "LOGIN WITH FACEBOOK".toString(),
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontFamily: Global.font,
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
                          await loginController.handleFacebookLogin(context).then((user) {
                            loginController.navigationCheck(user, context, 'fb');
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

                if(Platform.isIOS)
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 10.0,
                      left: Get.width * 0.1,
                      right: Get.width * 0.1,
                    ),
                    child: i.AppleSignInButton(
                      style: i.ButtonStyle.black,
                      cornerRadius: 50,
                      type: i.ButtonType.defaultButton,
                      onPressed: () async {
                        final User currentUser = await loginController.handleAppleLogin(_scaffoldKey).catchError((onError) {
                          SnackBar snackBar =
                              SnackBar(content: Text(onError.toString()));
                          _scaffoldKey.currentState.showSnackBar(snackBar);
                        });
                        if (currentUser != null) {
                          print('usernaem ${currentUser.displayName} \n photourl ${currentUser.photoURL}');
                          // await _setDataUser(currentUser);
                          loginController.navigationCheck(currentUser, context, "apple.com");
                        }
                      },
                    ),
                  ),
                if(Platform.isAndroid)
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10,
                      left: Get.width * 0.1,
                      right: Get.width * 0.1,
                    ),
                    child: Material(
                      // color: Colors.greenAccent,
                      elevation: 2.0,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                          child: Container(
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(25),
                                // gradient: LinearGradient(
                                //   begin: Alignment.topRight,
                                //   end: Alignment.bottomLeft,
                                //   colors: [
                                //     Colors.white,
                                //     Colors.white,
                                //     Colors.white,
                                //     Colors.white
                                //   ]
                                // )
                              ),
                              height: MediaQuery.of(context).size.height * .065,
                              width: MediaQuery.of(context).size.width * .8,
                              child: Center(
                                  child: Text(
                                "LOGIN WITH GOOGLE".toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: Global.font,
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
                            await loginController.handleGoogleLogin(context);
                          },
                        ),
                      ),
                    ),
                  ),
                
                InkWell(
                  onTap: (){
                    bool updateNumber = false;
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => OTP(updateNumber)));
                  },
                  child: Container(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      padding: EdgeInsets.only(
                        // left: Get.width * 0.1,
                        // right: Get.width * 0.1,
                      ),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          // border: Border.all(
                          //   color: Colors.red[500],
                          // ),
                          borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child: Center(
                        child: Text("LOGIN WITH PHONE NUMBER",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: Global.font,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)
                        ),
                      )
                  )
                ),

              ]),
              SizedBox(height: Get.height * 0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () => loginController.launchURL(
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
                    onTap: () => loginController.launchURL(
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
                padding: EdgeInsets.only(
                  left: Get.width * 0.1,
                  right: Get.width * 0.1,
                ),
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

                        Container(
                          padding: EdgeInsets.all(12),
                          child: Image.asset(
                            "asset/images/logo1.png",
                          )
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Are you 18 years of age? In order to use this app you must be 18 years old or over.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Get.height * 0.027,
                              fontFamily: "Arial",
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),

                        SizedBox(
                          height: Get.height * 0.01,
                        ),

                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "If you aren't please leave and do not continue.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: Get.height * 0.027,
                                fontFamily: "Arial",
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
                                  fontSize: Get.height * 0.025,
                                  color: textColor,
                                  fontFamily: "Arial",
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

