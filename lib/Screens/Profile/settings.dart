import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:hookup4u/Screens/Welcome/UpdateLocation.dart';
import 'package:hookup4u/Screens/auth/login.dart';
import 'package:hookup4u/ads/ads.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:share/share.dart';
import '../../util/Global.dart';
import 'UpdateNumber.dart';
// import 'package:easy_localization/easy_localization.dart';

class Settings extends StatefulWidget {
  final UserModel currentUser;
  final bool isPurchased;
  final Map items;
  Settings(this.currentUser, this.isPurchased, this.items);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map<String, dynamic> changeValues = {};
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

  List selected = [];
  RangeValues ageRange;
  var _showMe;
  int distance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Ads _ads = new Ads();
  // BannerAd _ad;
  // FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void dispose() {
    // _ads.disable(_ad);

    // _ad?.dispose();
    super.dispose();

    if (changeValues.length > 0) {
      updateData();
    }
  }

  Future updateData() async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.currentUser.id)
        .set(changeValues,
        SetOptions(merge : true)
    );
    // lastVisible = null;
    // print('ewew$lastVisible');
  }

  int freeR;
  int paidR;

  initData(){

    print(widget.currentUser.showMe);
    for(int i = 0; i<=widget.currentUser.showMe.length-1; i++){
      selected.add(widget.currentUser.showMe[i]);

      for(int j=0; j<=listShowMe.length-1; j++){
        if(widget.currentUser.showMe[i] == listShowMe[j]['name']){
          listShowMe[j]['ontap'] = true;
          break;
        }
      }

    }

  }

  @override
  void initState() {
    // _ad = _ads.myBanner();
    super.initState();
    initData();
    // _ad
    //   ..load()
    //   ..show();
    // var a = jsonDecode(widget.currentUser.showGender);
    // print(a[0]); // print one


    freeR = widget.items['free_radius'] != null
        ? int.parse(widget.items['free_radius'])
        : 400;
    paidR = widget.items['paid_radius'] != null
        ? int.parse(widget.items['paid_radius'])
        : 400;
    setState(() {
      if (!widget.isPurchased && widget.currentUser.maxDistance > freeR) {
        widget.currentUser.maxDistance = freeR.round();
        changeValues.addAll({'maximum_distance': freeR.round()});
      } else if (widget.isPurchased &&
          widget.currentUser.maxDistance >= paidR) {
        widget.currentUser.maxDistance = paidR.round();
        changeValues.addAll({'maximum_distance': paidR.round()});
      }
      _showMe = widget.currentUser.showMe;
      distance = widget.currentUser.maxDistance.round();
      ageRange = RangeValues(double.parse(widget.currentUser.ageRange['min']),
          (double.parse(widget.currentUser.ageRange['max'])));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
          title: Text(
            "Settings",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: primaryColor),
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            color: Colors.white),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Account settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: Card(
                      child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Phone Number"),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            child: Text(
                              widget.currentUser.phoneNumber != null
                                  ? "${widget.currentUser.phoneNumber}"
                                  : "Verify Now",
                              style: TextStyle(color: secondryColor),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: secondryColor,
                            size: 15,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    UpdateNumber(widget.currentUser)));
                        // _ads.disable(_ad);
                      },
                    ),
                  )),
                  subtitle: Text("Verify a phone number to secure your account"),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Discovery settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    child: ExpansionTile(
                      key: UniqueKey(),
                      leading: Text(
                        "Current location : ",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      title: Text(
                        widget.currentUser.address,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 25,
                              ),
                              InkWell(
                                child: Text(
                                  "Change location",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () async {
                                  var address = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateLocation()));
                                  print(address);
                                  if (address != null) {
                                    _updateAddress(address);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                  ),
                  child: Text(
                    "Change your location to see members in other city",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Search Settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      top: 5.0, bottom: 5,
                    right: 10, left: 10
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Show me",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),

                      SizedBox(height: 12,),

                      Container(
                        height: Get.height * 0.9,
                        child: GridView.count(
                          physics: NeverScrollableScrollPhysics(),
                          // Create a grid with 2 columns. If you change the scrollDirection to
                          // horizontal, this produces 2 rows.
                          crossAxisCount: 2,
                          childAspectRatio: 4/1,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 8.0,
                          // Generate 100 widgets that display their index in the List.
                          children: List.generate(listShowMe.length, (index) {
                            return OutlineButton(
                              highlightedBorderColor: primaryColor,
                              child: Container(
                                // height: MediaQuery.of(context).size.height * .055,
                                // width: MediaQuery.of(context).size.width * .65,
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
                                            fontSize: 12,
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

                                  listShowMe[index]["ontap"] = !listShowMe[index]["ontap"];
                                  if (listShowMe[index]["ontap"]) {
                                    selected.add(listShowMe[index]["name"]);
                                    print(listShowMe[index]["name"]);
                                    print(selected);
                                  } else {
                                    selected.remove(listShowMe[index]["name"]);
                                    print(selected);
                                  }
                                  changeValues.addAll({
                                    'showGender': selected,
                                  });

                                });
                              },
                            );
                          }),
                        )
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          "Maximum distance",
                          style: TextStyle(
                              fontSize: 18,
                              color: primaryColor,
                              fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "$distance Km.",
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Slider(
                            value: distance.toDouble(),
                            inactiveColor: secondryColor,
                            min: 1.0,
                            max: widget.isPurchased
                                ? paidR.toDouble()
                                : freeR.toDouble(),
                            activeColor: primaryColor,
                            onChanged: (val) {
                              changeValues
                                  .addAll({'maximum_distance': val.round()});
                              setState(() {
                                distance = val.round();
                              });
                            }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          "Age range",
                          style: TextStyle(
                              fontSize: 18,
                              color: primaryColor,
                              fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "${ageRange.start.round()}-${ageRange.end.round()}",
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: RangeSlider(
                            inactiveColor: secondryColor,
                            values: ageRange,
                            min: 18.0,
                            max: 100.0,
                            divisions: 25,
                            activeColor: primaryColor,
                            labels: RangeLabels('${ageRange.start.round()}',
                                '${ageRange.end.round()}'),
                            onChanged: (val) {
                              changeValues.addAll({
                                'age_range': {
                                  'min': '${val.start.truncate()}',
                                  'max': '${val.end.truncate()}'
                                }
                              });
                              setState(() {
                                ageRange = val;
                              });
                            }),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    "App settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Notifications",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Push notifications"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Container(
                //   child: StreamBuilder<QuerySnapshot>(
                //     stream:
                //         FirebaseFirestore.instance.collection('Language').snapshots(),
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
                //             return ListTile(
                //               subtitle: Card(
                //                 child: Padding(
                //                   padding: const EdgeInsets.all(8.0),
                //                   child: Column(
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: [
                //                       Padding(
                //                         padding: const EdgeInsets.all(0.0),
                //                         child: Text(
                //                           "Change Language",
                //                           style: TextStyle(
                //                               fontSize: 18,
                //                               color: primaryColor,
                //                               fontWeight: FontWeight.w500),
                //                         ),
                //                       ),
                //                       Padding(
                //                         padding: EdgeInsets.all(8.0),
                //                         child: Row(
                //                           mainAxisAlignment:
                //                               MainAxisAlignment.start,
                //                           children: [
                //                             FlatButton(
                //                               child: Text(
                //                                 "English",
                //                                 style: TextStyle(
                //                                     color: Colors.pink),
                //                               ),
                //                               onPressed: () async {
                //                                 showDialog(
                //                                   context: context,
                //                                   builder:
                //                                       (BuildContext context) {
                //                                     return AlertDialog(
                //                                       title: Text(
                //                                           "Change Language"),
                //                                       content: Text(
                //                                           'Do you want to change the language to English?'),
                //                                       actions: <Widget>[
                //                                         FlatButton(
                //                                           onPressed: () =>
                //                                               Navigator.of(
                //                                                       context)
                //                                                   .pop(false),
                //                                           child: Text('No'),
                //                                         ),
                //                                         ElevatedButton(
                //                                           onPressed: () {
                //                                             // context.setLocale(Locale('en', 'US'));
                //                                             // EasyLocalization.of(context).locale =
                //                                             //     Locale('en', 'US');
                //                                             Navigator.push(context,
                //                                                 MaterialPageRoute(
                //                                                     builder: (context) =>
                //                                                         Tabbar(null, false)
                //                                                 )
                //                                             );
                //                                           },
                //                                           child: Text('Yes'
                //                                               .tr()
                //                                               .toString()),
                //                                         ),
                //                                       ],
                //                                     );
                //                                   },
                //                                 );
                //                               },
                //                             ),
                //                             FlatButton(
                //                               child: Text(
                //                                 "Spanish",
                //                                 style: TextStyle(
                //                                     color: Colors.pink),
                //                               ),
                //                               onPressed: () async {
                //                                 showDialog(
                //                                   context: context,
                //                                   builder:
                //                                       (BuildContext context) {
                //                                     return AlertDialog(
                //                                       title: Text(
                //                                           "Change Language"
                //                                               .tr()
                //                                               .toString()),
                //                                       content: Text(
                //                                           'Do you want to change the language to Spanish?'
                //                                               .tr()
                //                                               .toString()),
                //                                       actions: <Widget>[
                //                                         ElevatedButton(
                //                                           onPressed: () =>
                //                                               Navigator.of(context).pop(false),
                //                                           child: Text('No'),
                //                                         ),
                //                                         ElevatedButton(
                //                                           onPressed: () {
                //                                             context.setLocale(Locale('es', 'ES'));
                //                                             // EasyLocalization.of(context).locale =
                //                                             //     Locale('es', 'ES');
                //                                             Navigator.push(context,
                //                                                 MaterialPageRoute(
                //                                                     builder: (context) =>
                //                                                         Tabbar(null, false)
                //                                                 )
                //                                             );
                //                                             // _ads.disable(_ad);
                //                                           },
                //                                           child: Text('Yes'
                //                                               .tr()
                //                                               .toString()),
                //                                         ),
                //                                       ],
                //                                     );
                //                                   },
                //                                 );
                //                               },
                //                             ),
                //                           ],
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //             );
                //           } else {
                //             return Text('');
                //           }
                //         }).toList(),
                //       );
                //     },
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Center(
                          child: Text(
                            "Invite your friends",
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Share.share(
                          'check out my website https://deligence.com', //Replace with your dynamic link and msg for invite users
                          subject: 'Look what I made!');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            "Logout",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Logout'),
                            content: Text('Would you like to logout of your account?'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('No'),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  await _auth.signOut().whenComplete(() {
                                    // _firebaseMessaging.deleteInstanceID();
                                    Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => Login()),
                                    );
                                  });
                                  // _ads.disable(_ad);
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Center(
                          child: Text(
                            "Delete Account",
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Account'),
                            content: Text('Do you want to delete your account?'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('No'),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  final user = _auth.currentUser;
                                  await _deleteUser(user).then((_) async {
                                    await _auth.signOut().whenComplete(() {
                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => Login()),
                                      );
                                    });
                                    // _ads.disable(_ad);
                                  });
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Container(
                          height: 50,
                          width: 100,
                          child: Image.asset(
                            "asset/hookup4u-Logo-BP.png",
                            fit: BoxFit.contain,
                          )),
                    )),
                SizedBox(
                  height: 80,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateAddress(Map _address) {
    showCupertinoModalPopup(
        context: context,
        builder: (ctx) {
          return Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .4,
            child: Column(
              children: <Widget>[
                Material(
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'New address:',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.black26,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    subtitle: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _address['PlaceName'] ?? '',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              decoration: TextDecoration.none),
                        ),
                      ),
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.white,
                  child: Text(
                    "Confirm",
                    style: TextStyle(color: primaryColor),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await FirebaseFirestore.instance
                        .collection("Users")
                        .doc('${widget.currentUser.id}')
                        .update({
                          'location': {
                            'latitude': _address['latitude'],
                            'longitude': _address['longitude'],
                            'address': _address['PlaceName']
                          },
                        },

                    )
                        .whenComplete(() => showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) {
                              Future.delayed(Duration(seconds: 3), () {
                                setState(() {
                                  widget.currentUser.address =
                                      _address['PlaceName'];
                                });

                                Navigator.pop(context);
                              });
                              return Center(
                                  child: Container(
                                      width: 160.0,
                                      height: 120.0,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            "asset/auth/verified.jpg",
                                            height: 60,
                                            color: primaryColor,
                                            colorBlendMode: BlendMode.color,
                                          ),
                                          Text(
                                            "location\nchanged",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                decoration: TextDecoration.none,
                                                color: Colors.black,
                                                fontSize: 20),
                                          )
                                        ],
                                      )));
                            }))
                        .catchError((e) {
                          print(e);
                        });

                    // .then((_) {
                    //   Navigator.pop(context);
                    // });
                  },
                )
              ],
            ),
          );
        });
  }

  Future _deleteUser(User user) async {
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).delete();
  }
}
