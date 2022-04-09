import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Welcome/Desires/DesiresScreen.dart';
import 'package:hookup4u/util/Global.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/snackbar.dart';
// import 'package:easy_localization/easy_localization.dart';

class SexualOrientation extends StatefulWidget {
  final Map<String, dynamic> userData;
  SexualOrientation(this.userData);

  @override
  _SexualOrientationState createState() => _SexualOrientationState();
}

class _SexualOrientationState extends State<SexualOrientation> {
  List<Map<String, dynamic>> orientationlist = [
    {'name': 'straight', 'ontap': false},
    {'name': 'gay', 'ontap': false},
    {'name': 'lesbian', 'ontap': false},
    {'name': 'bisexual', 'ontap': false},
    {'name': 'bi-curious', 'ontap': false},
    {'name': 'pansexual', 'ontap': false},
    {'name': 'polysexual', 'ontap': false},
    {'name': 'queer', 'ontap': false},
    {'name': 'androgynobexual', 'ontap': false},
    {'name': 'androsexual', 'ontap': false},
    {'name': 'asexual', 'ontap': false},
    {'name': 'autosexual', 'ontap': false},
    {'name': 'demisexual', 'ontap': false},
    {'name': 'gray a', 'ontap': false},
    {'name': 'gynosexual', 'ontap': false},
    {'name': 'heteroflexible', 'ontap': false},
    {'name': 'homoflexible', 'ontap': false},
    {'name': 'objectumsexual', 'ontap': false},
    {'name': 'omnisexual', 'ontap': false},
    {'name': 'skoliosexual', 'ontap': false},
  ];
  String other_text = "other";
  var selection;

  // List selected = [];
  bool select = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      floatingActionButton: AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 50),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: FloatingActionButton(
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
              dispose();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Container(
        height: MediaQuery.of(context).size.height,
        // padding: EdgeInsets.only(
        //   left: Get.width * 0.1,
        //   right: Get.width * 0.1,
        // ),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Container(
                child: Center(
                  child: Text(
                    "My sexual orientation is",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: Global.font,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                    left: Get.width * 0.1,
                    right: Get.width * 0.1,
                    top: 100
                ),
              ),

              SizedBox(
                height: Get.height * 0.6,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: Get.width * 0.1,
                      right: Get.width * 0.1,
                      top: 0,
                      bottom: 50
                  ),
                  child: ListView.builder(
                    // physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: orientationlist.length,
                    itemBuilder: (BuildContext context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: OutlineButton(
                          highlightedBorderColor: primaryColor,
                          child: Container(
                            height: MediaQuery.of(context).size.height * .055,
                            // width: MediaQuery.of(context).size.width * .65,
                            child: Center(
                                child: Text("${orientationlist[index]["name"]}".toUpperCase(),
                                    style: TextStyle(
                                        color: orientationlist[index] == selection
                                            ? primaryColor
                                            : secondryColor,
                                        fontSize: 18,
                                        fontFamily: Global.font,
                                        fontWeight: FontWeight.normal
                                    ))),
                          ),
                          borderSide: BorderSide(
                              width: 1,
                              style: BorderStyle.solid,
                              color: orientationlist[index] == selection
                                  ? primaryColor
                                  : secondryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          onPressed: () {
                            selection = orientationlist[index];
                            print(selection);
                            setState(() {
                              // if (selected.length < 3) {
                              //   orientationlist[index]["ontap"] =
                              //   !orientationlist[index]["ontap"];
                              //   if (orientationlist[index]["ontap"]) {
                              //     selected.add(orientationlist[index]["name"]);
                              //     print(orientationlist[index]["name"]);
                              //     print(selected);
                              //   } else {
                              //     selected.remove(orientationlist[index]["name"]);
                              //     print(selected);
                              //   }
                              // } else {
                              //   if (orientationlist[index]["ontap"]) {
                              //     orientationlist[index]["ontap"] =
                              //     !orientationlist[index]["ontap"];
                              //     selected.remove(orientationlist[index]["name"]);
                              //   } else {
                              //     CustomSnackbar.snackbar(
                              //         "select upto 3", _scaffoldKey);
                              //   }
                              // }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.only(
                  left: Get.width * 0.05,
                  right: Get.width * 0.05,
                ),
                child: Column(
                  children: <Widget>[
                    // ListTile(
                    //   leading: Checkbox(
                    //     activeColor: primaryColor,
                    //     value: select,
                    //     onChanged: (bool newValue) {
                    //       setState(() {
                    //         select = newValue;
                    //       });
                    //     },
                    //   ),
                    //   title: Text("Show my orientation on my profile",
                    //
                    //   ),
                    // ),
                    selection != null
                        ? Padding(
                      padding: const EdgeInsets.only(bottom: 40),
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
                              height:
                              MediaQuery.of(context).size.height * .065,
                              width:
                              MediaQuery.of(context).size.width * .75,
                              child: Center(
                                  child: Text(
                                    "CONTINUE",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: textColor,
                                        fontWeight: FontWeight.bold),
                                  ))),
                          onTap: () {
                            widget.userData.addAll({
                              "sexualOrientation": {
                                'orientation': selection,
                                'showOnProfile': select
                              },
                            });
                            print(widget.userData);
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        DesiresScreen(widget.userData)));
                          },
                        ),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              height:
                              MediaQuery.of(context).size.height * .065,
                              width:
                              MediaQuery.of(context).size.width * .75,
                              child: Center(
                                  child: Text(
                                    "CONTINUE",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: secondryColor,
                                        fontWeight: FontWeight.bold),
                                  ))),
                          onTap: () {
                            CustomSnackbar.snackbar(
                                "Please select one", _scaffoldKey);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
