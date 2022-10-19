import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/LoginController.dart';
import 'package:hookup4u/Controller/TabsController.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:hookup4u/Screens/Welcome/UploadImage/UploadImageScreen.dart';
import 'package:hookup4u/Screens/Welcome/seach_location.dart';
import 'package:hookup4u/util/color.dart';
// import 'package:easy_localization/easy_localization.dart';

import '../Profile/EditProfile.dart';
import 'UpdateLocation.dart';
//import 'package:geolocator/geolocator.dart';

class AllowLocation extends StatelessWidget {
  final Map<String, dynamic> userData;
  AllowLocation(this.userData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 50),
              child: FloatingActionButton(
                heroTag: UniqueKey(),
                elevation: 10,
                child: IconButton(
                  color: secondryColor,
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                backgroundColor: Colors.white38,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: secondryColor.withOpacity(.2),
                      radius: 110,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 90,
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: RichText(
                      text: TextSpan(
                        text: "Enable location",
                        style: TextStyle(color: Colors.black, fontSize: 40),
                        children: [
                          TextSpan(
                              text:
                                  "\nYou'll need to provide a \nlocation\nin order to search users around you.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: secondryColor,
                                  textBaseline: TextBaseline.alphabetic,
                                  fontSize: 18)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  // child: FlatButton.icon(
                  //     onPressed: null,
                  //     icon: Icon(Icons.arrow_drop_down),
                  //     label: Text("Show more")),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
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
                        "ALLOW LOCATION",
                        style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: FontWeight.bold),
                      ))),
                  onTap: () async {
                    print("Cek");
                    var currentLocation = await getLocationCoordinates();
                    print(currentLocation);
                    print(userData);
                    if (currentLocation != null) {
                      if(kDebugMode){
                        print(Get.find<TabsController>().items['free_radius']);
                      }
                      int maxDistance = int.parse(Get.find<TabsController>().items['free_radius']  ?? "20");
                      userData.addAll(
                        {
                          "listSwipedUser" : [],
                          "verified" : 0,
                          'location': {
                            'latitude': currentLocation['latitude'],
                            'longitude': currentLocation['longitude'],
                            'address': currentLocation['PlaceName'],
                            'countryName' : currentLocation['countryName'],
                            'countryID' : currentLocation['countryID'],
                          },
                          'maximum_distance': maxDistance,
                          'age_range': {
                            'min': "18",
                            'max': "99",
                          },
                        },
                      );
                      if(kDebugMode){
                        print(userData);
                        print(Get.find<LoginController>().userId);
                      }
                      Get.to(() => UploadImageScreen(userData));
                    }
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

Future showWelcomDialog(context) async {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pop(context);
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => Tabbar(null, null)));
        });
        return Center(
            child: Container(
                width: 150.0,
                height: 100.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "asset/auth/verified.jpg",
                      height: 60,
                      color: primaryColor,
                      colorBlendMode: BlendMode.color,
                    ),
                    Text(
                      "You're in!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 20),
                    )
                  ],
                )));
      });
}
