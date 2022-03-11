
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Welcome/ShowGender.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/snackbar.dart';

class StatusScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  StatusScreen(this.userData);

  @override
  _StatusScreen createState() => _StatusScreen();
}

class _StatusScreen extends State<StatusScreen> {
  List<Map<String, dynamic>> listStatus = [
    {'name': 'single', 'ontap': false},
    {'name': 'man + woman couple', 'ontap': false},
    {'name': 'man + man couple', 'ontap': false},
    {'name': 'woman + woman couple', 'ontap': false},
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

              Padding(
                child: Text(
                  "My status is",
                  style: TextStyle(fontSize: Get.height * 0.05,),
                ),
                padding: EdgeInsets.only(left: 50, top: 80),
              ),

              SizedBox(
                height: Get.height * 0.65,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: ListView.builder(
                    // physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listStatus.length,
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
                                child: Text("${listStatus[index]["name"]}".toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: listStatus[index]["ontap"]
                                            ? primaryColor
                                            : secondryColor,
                                        fontWeight: FontWeight.bold
                                    )
                                )
                            ),
                          ),
                          borderSide: BorderSide(
                              width: 1,
                              style: BorderStyle.solid,
                              color: listStatus[index]["ontap"]
                                  ? primaryColor
                                  : secondryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          onPressed: () {
                            setState(() {
                              if (selected.length < 3) {
                                listStatus[index]["ontap"] =
                                !listStatus[index]["ontap"];
                                if (listStatus[index]["ontap"]) {
                                  selected.add(listStatus[index]["name"]);
                                  print(listStatus[index]["name"]);
                                  print(selected);
                                } else {
                                  selected.remove(listStatus[index]["name"]);
                                  print(selected);
                                }
                              } else {
                                if (listStatus[index]["ontap"]) {
                                  listStatus[index]["ontap"] =
                                  !listStatus[index]["ontap"];
                                  selected.remove(listStatus[index]["name"]);
                                } else {
                                  CustomSnackbar.snackbar(
                                      "select upto 3", _scaffoldKey);
                                }
                              }
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
                  ListTile(
                    leading: Checkbox(
                      activeColor: primaryColor,
                      value: select,
                      onChanged: (bool newValue) {
                        setState(() {
                          select = newValue;
                        });
                      },
                    ),
                    title: Text("Show my orientation on my profile"),
                  ),
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
                          widget.userData.addAll(
                              {
                                'status': selected,
                                'showstatus': select
                              }
                          );
                          print(widget.userData);
                          // Navigator.push(
                          //     context,
                          //     CupertinoPageRoute(
                          //         builder: (context) =>
                          //             University(widget.userData)));
                          // widget.userData.addAll({
                          //   'editInfo': {
                          //     'university': "",
                          //     'userGender': widget.userData['userGender'],
                          //     'showOnProfile':
                          //     widget.userData['showOnProfile']
                          //   }
                          // });
                          // widget.userData.remove('showOnProfile');
                          // widget.userData.remove('userGender');

                          print(widget.userData);
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      ShowMe(widget.userData)));

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