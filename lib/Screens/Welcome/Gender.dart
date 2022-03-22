import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Welcome/SexualOrientation.dart';
import 'package:hookup4u/Screens/UserName.dart';
import 'package:hookup4u/util/Global.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/snackbar.dart';
// import 'package:easy_localization/easy_localization.dart';

class Gender extends StatefulWidget {
  final Map<String, dynamic> userData;
  Gender(this.userData);

  @override
  _GenderState createState() => _GenderState();
}

class _GenderState extends State<Gender> {
  // bool man = false;
  // bool woman = false;
  // bool other = false;
  bool select = false;
  var selection;
  String other_text = "other";
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // List <String> listGender = [
  //   "other", 'agender', 'androgynous', 'bigender',
  //   "gender fluid", "gender non conforming", "gender queer",
  //   "gender questioning", "intersex", "non-binary", "pangender",
  //   "trans human", "trans man", "trans woman", "transfeminime",
  //   "transmasculine", "two-spirit"
  // ];


  List<Map<String, dynamic>> listGender = [
    {'name': 'man', 'ontap': false},
    {'name': 'woman', 'ontap': false},
    {'name': 'other', 'ontap': false},
    {'name': 'agender', 'ontap': false},
    {'name': 'androgynous', 'ontap': false},
    {'name': 'bigender', 'ontap': false},
    {'name': 'gender fluid', 'ontap': false},
    {'name': 'gender non conforming', 'ontap': false},
    {'name': 'gender queer', 'ontap': false},
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
      body: Stack(
        children: <Widget>[
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Text(
                    "I am a",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: Global.font,
                    ),
                  ),

                ],
              ),
            padding: EdgeInsets.only(left: 0, top: 70),
          ),
          Container(
            padding: EdgeInsets.only(
              top: Get.height * 0.16
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
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
                      itemCount: listGender.length,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: OutlineButton(
                            highlightedBorderColor: primaryColor,
                            child: Container(
                              height: MediaQuery.of(context).size.height * .055,
                              // width: MediaQuery.of(context).size.width * .65,
                              child: Center(
                                  child: Text("${listGender[index]["name"]}".toUpperCase(),
                                      style: TextStyle(
                                          color: listGender[index] == selection
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
                                color: listGender[index] == selection
                                    ? primaryColor
                                    : secondryColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            onPressed: () {
                              selection = listGender[index];
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 100.0, left: 10),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                leading: Checkbox(
                  activeColor: primaryColor,
                  value: select,
                  onChanged: (bool newValue) {
                    setState(() {
                      select = newValue;
                    });
                  },
                ),
                title: Text("Show my gender on my profile"),
              ),
            ),
          ),
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
                          height: MediaQuery.of(context).size.height * .065,
                          width: MediaQuery.of(context).size.width * .75,
                          child: Center(
                              child: Text(
                            "CONTINUE",
                            style: TextStyle(
                                fontSize: 15,
                                color: textColor,
                                fontWeight: FontWeight.bold),
                          ))),
                      onTap: () {
                        var userGender;
                        // if (man) {
                        //   userGender = {
                        //     'userGender': "man",
                        //     'showOnProfile': select
                        //   };
                        // } else if (woman) {
                        //   userGender = {
                        //     'userGender': "woman",
                        //     'showOnProfile': select
                        //   };
                        // } else {
                        //   userGender = {
                        //     'userGender': other_text,
                        //     'showOnProfile': select
                        //   };
                        // }
                        userGender = {
                          'userGender': "man",
                          'showOnProfile': select
                        };
                        widget.userData.addAll(userGender);
                        // print(userData['userGender']['showOnProfile']);
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    SexualOrientation(widget.userData)));
                        // ads.disable(ad1);
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
                          height: MediaQuery.of(context).size.height * .065,
                          width: MediaQuery.of(context).size.width * .75,
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
    );
  }

  // void dropdownGenderWidget(BuildContext context2, String awal){
  //   showDialog(
  //     context: context2,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Gender"),
  //         content: SizedBox(
  //             height: Get.height * 0.1,
  //             child: DropdownSearch<String>(
  //               dropdownSearchDecoration: const InputDecoration(
  //                 labelText: "Other Option",
  //                 labelStyle: TextStyle(
  //                   color: Colors.black,
  //                 ),
  //                 hintText: "Other Option",
  //                 contentPadding: EdgeInsets.fromLTRB(12, 4, 12, 4),
  //                 border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.all(Radius.circular(5),
  //                     ),
  //                     borderSide: BorderSide(color: Colors.black)
  //                 ),
  //               ),
  //               onChanged: (String data) {
  //
  //                 setState(() {
  //                   other_text = data;
  //                 });
  //
  //               },
  //               showSearchBox: true,
  //               items: listGender,
  //               selectedItem: other_text,
  //               dropdownBuilder: _customDropDownGenderWidget,
  //               popupItemBuilder: _customPopUpGenderWidget,
  //               isFilteredOnline: true,
  //               onFind:(String filter) => getData(filter),
  //             )
  //         ),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             child: const Text('CANCEL'),
  //             onPressed: () {
  //               setState(() {
  //                 other_text = awal;
  //                 Navigator.pop(context2);
  //               });
  //
  //             },
  //           ),
  //           ElevatedButton(
  //             child: const Text('OK'),
  //             onPressed: () {
  //               if (kDebugMode) {
  //                 print(other_text);
  //               }
  //               setState(() {
  //                 man = false;
  //                 woman = false;
  //                 other = true;
  //                 Navigator.pop(context2);
  //               });
  //
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // Widget _customPopUpGenderWidget(
  //     BuildContext context, String item, bool isSelected) {
  //
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 8),
  //     decoration: !isSelected
  //         ? null
  //         : BoxDecoration(
  //       border: Border.all(color: Theme.of(context).primaryColor),
  //       borderRadius: BorderRadius.circular(5),
  //       color: Colors.white,
  //     ),
  //     child: ListTile(
  //         selected: isSelected,
  //         title: Text(
  //           item.toUpperCase(),
  //           style: const TextStyle(color: Colors.black),
  //         ),
  //         leading: const Icon(Icons.drag_indicator_outlined)
  //     ),
  //   );
  // }
  //
  // Widget _customDropDownGenderWidget(BuildContext context, String item) {
  //   // if (item == null) {
  //   //   return Container();
  //   // }
  //
  //   return Container(
  //     child: (item == '')
  //         ? const ListTile(
  //       contentPadding: EdgeInsets.all(0),
  //       leading: CircleAvatar(),
  //       title: Text("No item selected"),
  //     )
  //         : ListTile(
  //         contentPadding: const EdgeInsets.all(0),
  //         title: Text(
  //           item.toUpperCase(),
  //           style: const TextStyle(color: Colors.black),
  //         ),
  //         leading: const Icon(Icons.drag_indicator_outlined)
  //     ),
  //   );
  // }

  // Future<List<String>> getData(String filter) async {
  //   if (kDebugMode) {
  //     print(listGender.length);
  //     print("Search : " + filter);
  //   }
  //
  //   List<String> listTemp = [];
  //   for (var element in listGender) {
  //     if (element.toLowerCase().contains(filter.toLowerCase())) {
  //       listTemp.add(element);
  //     }
  //   }
  //   if (kDebugMode) {
  //     print("Cek : "+listTemp.length.toString());
  //   }
  //
  //   return listTemp;
  // }

}
