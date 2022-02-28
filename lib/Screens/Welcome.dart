import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/UserDOB.dart';
import 'package:hookup4u/Screens/UserName.dart';
import 'package:hookup4u/util/color.dart';
// import 'package:easy_localization/easy_localization.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                  height: MediaQuery.of(context).size.height * .8,
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
                            "This is a community for unvaccinated singles looking to meet like-minded people for love, fun and friendship.",
                            style: TextStyle(
                                fontSize: Get.height * 0.025,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Be yourself.",
                            style: TextStyle(
                                fontSize: Get.height * 0.025,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Please make sure that your photos, age and bio are accurate and a true representation of who you are.",
                            style: TextStyle(
                              fontSize: Get.height * 0.024,
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Play it cool.",
                            style: TextStyle(
                                fontSize: Get.height * 0.025,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Respect others and treat them as you would like to be treated.",
                            style: TextStyle(
                              fontSize: Get.height * 0.024,
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Stay safe.",
                            style: TextStyle(
                                fontSize: Get.height * 0.025,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Don't be too quick to give out personal information.",
                            style: TextStyle(
                              fontSize: Get.height * 0.024,
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Be proactive.",
                            style: TextStyle(
                                fontSize: Get.height * 0.025,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Always report bad behavior.",
                            style: TextStyle(
                              fontSize: Get.height * 0.024,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, top: 50),
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
                          "GOT IT",
                          style: TextStyle(
                              fontSize: Get.height * 0.022,
                              color: textColor,
                              fontWeight: FontWeight.bold),
                        ))),
                    onTap: () async {
                      User _user = FirebaseAuth.instance.currentUser;

                      if (_user.displayName != null) {
                        if (_user.displayName.length > 0) {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => UserDOB(
                                      {'UserName': _user.displayName})));
                        } else {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => UserName()));
                        }
                      } else {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => UserName()));
                      }
                      // await FirebaseAuth.instance.currentUser().then((_user) {
                      //   if (_user.displayName != null) {
                      //     if (_user.displayName.length > 0) {
                      //       Navigator.push(
                      //           context,
                      //           CupertinoPageRoute(
                      //               builder: (context) => UserDOB(
                      //                   {'UserName': _user.displayName})));
                      //     } else {
                      //       Navigator.push(
                      //           context,
                      //           CupertinoPageRoute(
                      //               builder: (context) => UserName()));
                      //     }
                      //   } else {
                      //     Navigator.push(
                      //         context,
                      //         CupertinoPageRoute(
                      //             builder: (context) => UserName()));
                      //   }
                      // });
                    },
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
