import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/AllowLocation.dart';
import 'package:hookup4u/Screens/University.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/snackbar.dart';
// import 'package:easy_localization/easy_localization.dart';

class ShowGender extends StatefulWidget {
  final Map<String, dynamic> userData;
  ShowGender(this.userData);

  @override
  _ShowGenderState createState() => _ShowGenderState();
}

class _ShowGenderState extends State<ShowGender> {

  List <String> listGender = [
    "other", 'agender', 'androgynous', 'bigender',
    "gender fluid", "gender non conforming", "gender queer",
    "gender questioning", "intersex", "non-binary", "pangender",
    "trans human", "trans man", "trans woman", "transfeminime",
    "transmasculine", "two-spirit"
  ];
  String more_text = "other";

  bool man = false;
  bool woman = false;
  bool eyeryone = false;
  // bool couple = false;
  bool more = false;
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
              Navigator.pop(context);
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Stack(
        children: <Widget>[
          Padding(
            child: Text(
              "Show me",
              style: TextStyle(fontSize: 40),
            ),
            padding: EdgeInsets.only(left: 50, top: 120),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlineButton(
                  highlightedBorderColor: primaryColor,
                  child: Container(
                    height: MediaQuery.of(context).size.height * .065,
                    width: MediaQuery.of(context).size.width * .75,
                    child: Center(
                        child: Text("MEN",
                            style: TextStyle(
                                fontSize: 20,
                                color: man ? primaryColor : secondryColor,
                                fontWeight: FontWeight.bold))),
                  ),
                  borderSide: BorderSide(
                      width: 1,
                      style: BorderStyle.solid,
                      color: man ? primaryColor : secondryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  onPressed: () {
                    setState(() {
                      woman = false;
                      man = true;
                      eyeryone = false;
                      more = false;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 0),
                  child: OutlineButton(
                    child: Container(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                          child: Text("WOMEN",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: woman ? primaryColor : secondryColor,
                                  fontWeight: FontWeight.bold))),
                    ),
                    borderSide: BorderSide(
                      color: woman ? primaryColor : secondryColor,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    onPressed: () {
                      setState(() {
                        woman = true;
                        man = false;
                        eyeryone = false;
                        more = false;
                      });
                      // Navigator.push(
                      //     context, CupertinoPageRoute(builder: (context) => OTP()));
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: OutlineButton(
                    focusColor: primaryColor,
                    highlightedBorderColor: primaryColor,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                          child: Text("EVERYONE",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: eyeryone ? primaryColor : secondryColor,
                                  fontWeight: FontWeight.bold))),
                    ),
                    borderSide: BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                        color: eyeryone ? primaryColor : secondryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    onPressed: () {
                      setState(() {
                        woman = false;
                        man = false;
                        eyeryone = true;
                        more = false;
                      });
                      // Navigator.push(
                      //     context, CupertinoPageRoute(builder: (context) => OTP()));
                    },
                  ),
                ),

                OutlineButton(
                  focusColor: primaryColor,
                  highlightedBorderColor: primaryColor,
                  child: Container(
                    height: MediaQuery.of(context).size.height * .065,
                    width: MediaQuery.of(context).size.width * .75,
                    child: Center(
                        child: Text(more_text.toUpperCase(),
                            style: TextStyle(
                                fontSize: 20,
                                color: more ? primaryColor : secondryColor,
                                fontWeight: FontWeight.bold))),
                  ),
                  borderSide: BorderSide(
                      width: 1,
                      style: BorderStyle.solid,
                      color: more ? primaryColor : secondryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  onPressed: () {
                    // setState(() {
                    //   woman = false;
                    //   man = false;
                    //   eyeryone = false;
                    // });

                    dropdownGenderWidget(context, more_text);
                    // Navigator.push(
                    //     context, CupertinoPageRoute(builder: (context) => OTP()));
                  },
                ),

              ],
            ),
          ),
          man || woman || eyeryone || more
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
                        if (man) {
                          widget.userData.addAll({'showGender': "man"});
                        } else if (woman) {
                          widget.userData.addAll({'showGender': "woman"});
                        } else if(eyeryone){
                          widget.userData.addAll({'showGender': "everyone"});
                        }else{
                          widget.userData.addAll({'showGender': more_text});
                        }

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

  void dropdownGenderWidget(BuildContext context2, String awal){
    showDialog(
      context: context2,
      builder: (context) {
        return AlertDialog(
          title: Text("Gender"),
          content: SizedBox(
              height: Get.height * 0.1,
              child: DropdownSearch<String>(
                dropdownSearchDecoration: const InputDecoration(
                  labelText: "Other Option",
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  hintText: "Other Option",
                  contentPadding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5),
                      ),
                      borderSide: BorderSide(color: Colors.black)
                  ),
                ),
                onChanged: (String data) {

                  setState(() {
                    more_text = data;
                  });

                },
                showSearchBox: true,
                items: listGender,
                selectedItem: more_text,
                dropdownBuilder: _customDropDownGenderWidget,
                popupItemBuilder: _customPopUpGenderWidget,
                isFilteredOnline: true,
                onFind:(String filter) => getData(filter),
              )
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('CANCEL'),
              onPressed: () {
                setState(() {
                  more_text = awal;
                  Navigator.pop(context2);
                });

              },
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                if (kDebugMode) {
                  print(more_text);
                }
                setState(() {
                  man = false;
                  woman = false;
                  eyeryone = false;
                  more = true;
                  Navigator.pop(context2);
                });

              },
            ),
          ],
        );
      },
    );
  }

  Widget _customPopUpGenderWidget(
      BuildContext context, String item, bool isSelected) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: ListTile(
          selected: isSelected,
          title: Text(
            item.toUpperCase(),
            style: const TextStyle(color: Colors.black),
          ),
          leading: const Icon(Icons.drag_indicator_outlined)
      ),
    );
  }

  Widget _customDropDownGenderWidget(BuildContext context, String item) {
    // if (item == null) {
    //   return Container();
    // }

    return Container(
      child: (item == '')
          ? const ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: CircleAvatar(),
        title: Text("No item selected"),
      )
          : ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: Text(
            item.toUpperCase(),
            style: const TextStyle(color: Colors.black),
          ),
          leading: const Icon(Icons.drag_indicator_outlined)
      ),
    );
  }

  Future<List<String>> getData(String filter) async {
    if (kDebugMode) {
      print(listGender.length);
      print("Search : " + filter);
    }

    List<String> listTemp = [];
    for (var element in listGender) {
      if (element.toLowerCase().contains(filter.toLowerCase())) {
        listTemp.add(element);
      }
    }
    if (kDebugMode) {
      print("Cek : "+listTemp.length.toString());
    }

    return listTemp;
  }

}
