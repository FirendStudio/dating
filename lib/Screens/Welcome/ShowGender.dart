import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Welcome/AllowLocation.dart';
import 'package:hookup4u/Screens/Welcome/University.dart';
import 'package:hookup4u/util/Global.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/snackbar.dart';

class ShowMe extends StatefulWidget {
  final Map<String, dynamic> userData;
  ShowMe(this.userData);

  @override
  _ShowMe createState() => _ShowMe();
}

class _ShowMe extends State<ShowMe> {
  List<Map<String, dynamic>> listShowMe = [
    {'name': 'men', 'ontap': false},
    {'name': 'women', 'ontap': false},
    {'name': 'man + woman couples', 'ontap': false},
    {'name': 'man + man couples', 'ontap': false},
    {'name': 'woman + woman couples', 'ontap': false},
    {'name': 'gender fluid', 'ontap': false},
    {'name': 'gender non conforming', 'ontap': false},
    {'name': 'gender queer', 'ontap': false},
    {'name': 'agender', 'ontap': false},
    {'name': 'androgynous', 'ontap': false},
    {'name': 'bigender', 'ontap': false},
    {'name': 'gender questioning', 'ontap': false},
    {'name': 'intersex', 'ontap': false},
    {'name': 'non-binary', 'ontap': false},
    {'name': 'pangender', 'ontap': false},
    {'name': 'trans human', 'ontap': false},
    {'name': 'trans man', 'ontap': false},
    {'name': 'trans woman', 'ontap': false},
    {'name': 'transfeminime', 'ontap': false},
    {'name': 'transmasculine', 'ontap': false},
    {'name': 'two-spirit', 'ontap': false},
  ];
  String other_text = "other";

  List selected = [];
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
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Container(
                child: Center(
                  child: Text(
                    "Show Me",
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
                height: Get.height * 0.7,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: Get.width * 0.1,
                      right: Get.width * 0.1,
                      top: 0,
                      bottom: 20
                  ),
                  child: ListView.builder(
                    // physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listShowMe.length,
                    itemBuilder: (BuildContext context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: OutlineButton(
                          highlightedBorderColor: primaryColor,
                          child: Container(
                            // height: MediaQuery.of(context).size.height * .055,
                            width: MediaQuery.of(context).size.width * .65,
                            padding: EdgeInsets.only(
                                top: 8,
                                bottom: 8,
                                left: 8,
                                right: 8
                            ),
                            child: Center(
                                child: Text("${listShowMe[index]["name"]}".toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: Global.font,
                                        color: listShowMe[index]["ontap"]
                                            ? primaryColor
                                            : secondryColor,
                                        fontWeight: FontWeight.normal
                                    )
                                )
                            ),
                          ),
                          borderSide: BorderSide(
                              width: 1,
                              style: BorderStyle.solid,
                              color: listShowMe[index]["ontap"]
                                  ? primaryColor
                                  : secondryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          onPressed: () {
                            setState(() {

                              listShowMe[index]["ontap"] =
                              !listShowMe[index]["ontap"];
                              if (listShowMe[index]["ontap"]) {
                                selected.add(listShowMe[index]["name"]);
                                print(listShowMe[index]["name"]);
                                print(selected);
                              } else {
                                selected.remove(listShowMe[index]["name"]);
                                print(selected);
                              }

                              // if (selected.length < 3) {
                              //
                              // } else {
                              //   if (listShowMe[index]["ontap"]) {
                              //     listShowMe[index]["ontap"] =
                              //     !listShowMe[index]["ontap"];
                              //     selected.remove(listShowMe[index]["name"]);
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

              Column(
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
                  //   title: Text("Show my orientation on my profile"),
                  // ),
                  selected.length > 0
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
                          // widget.userData.addAll({
                          //   "showMe": {
                          //     'showme': selected,
                          //     // 'showOnProfile': select
                          //   },
                          // });
                          // print(widget.userData);
                          // Navigator.push(
                          //     context,
                          //     CupertinoPageRoute(
                          //         builder: (context) =>
                          //             ShowMe(widget.userData)
                          //     )
                          // );

                          // if (man) {
                          //   widget.userData.addAll({'showGender': "man"});
                          // } else if (woman) {
                          //   widget.userData.addAll({'showGender': "woman"});
                          // } else if(eyeryone){
                          //   widget.userData.addAll({'showGender': "everyone"});
                          // }else{
                          //   widget.userData.addAll({'showGender': more_text});
                          // }
                          widget.userData.addAll({'showGender': selected});
                          print(widget.userData);
                          // Navigator.push(
                          //     context,
                          //     CupertinoPageRoute(
                          //         builder: (context) =>
                          //             University(widget.userData)));
                          widget.userData.addAll({
                            'editInfo': {
                              'university': "",
                              'userGender': widget.userData['userGender'],
                              'showOnProfile':
                              widget.userData['showOnProfile']
                            }
                          });
                          widget.userData.remove('showOnProfile');
                          widget.userData.remove('userGender');

                          print(widget.userData);
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      AllowLocation(widget.userData)));

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
            ],
          ),
        ),
      ),
    );
  }
}


