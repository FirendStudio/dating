import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import '../../infrastructure/dal/util/color.dart';
import 'controllers/settings.controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
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
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
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
                Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: InkWell(
                      onTap: (() {
                        // print("Test");
                        Get.find<VerifyProfileController>()
                            .phoneNumController
                            .text = "";
                        Get.find<VerifyProfileController>().getVerifyModel();
                      }),
                      child: Card(
                          child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 10, top: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: Text("Verification Status"),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                widget.currentUser.verified != 3
                                    ? "Unverified"
                                    : "Verified",
                                style: TextStyle(
                                    color: widget.currentUser.verified != 3
                                        ? Colors.red
                                        : Colors.greenAccent),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: secondryColor,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      )),
                    )),
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Card(
                      child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 10, top: 20, bottom: 20),
                    child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Text("Phone Number"),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              widget.currentUser.phoneNumber.isNotEmpty
                                  ? "${widget.currentUser.phoneNumber}"
                                  : "Verify Now",
                              style: TextStyle(color: secondryColor),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: secondryColor,
                              size: 15,
                            ),
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
                ),
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Card(
                      child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 10, top: 20, bottom: 20),
                    child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Text("Connected Account"),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "",
                              style: TextStyle(color: secondryColor),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: secondryColor,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        connectedAccountWidget();
                      },
                    ),
                  )),
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
                    "Partner",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                GetBuilder<NotificationController>(builder: (data) {
                  return Column(
                    children: [
                      if (data.relationUser.pendingAcc.isEmpty &&
                          data.relationUser.pendingReq.isEmpty)
                        newPartnerWidget(),
                      if (data.relationUser.pendingAcc.isNotEmpty &&
                          data.relationUser.pendingReq.isEmpty)
                        pendingWidget(),
                      if (data.relationUser.pendingAcc.isEmpty &&
                          data.relationUser.pendingReq.isNotEmpty)
                        acceptWidget(),
                      if (notificationController
                              .relationUser.pendingAcc.isNotEmpty &&
                          notificationController
                              .relationUser.pendingReq.isNotEmpty)
                        relationWidget(),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Search Settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 5.0, bottom: 5, right: 10, left: 10),
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
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                          height: Get.height * 0.9,
                          child: GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            // Create a grid with 2 columns. If you change the scrollDirection to
                            // horizontal, this produces 2 rows.
                            crossAxisCount: 2,
                            childAspectRatio: 4 / 1,
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
                                      top: 8, bottom: 8, left: 8, right: 8),
                                  child: Center(
                                      child: Text(
                                          "${listShowMe[index]["name"]}"
                                              .toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: Global.font,
                                              color: listShowMe[index]["ontap"]
                                                  ? primaryColor
                                                  : secondryColor,
                                              fontWeight: FontWeight.normal))),
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
                                      selected
                                          .remove(listShowMe[index]["name"]);
                                      print(selected);
                                    }
                                    changeValues.addAll({
                                      'showGender': selected,
                                    });
                                  });
                                },
                              );
                            }),
                          ))
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
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 16.0),
                        title: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "Age range",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500),
                            )),
                        subtitle: Row(children: [
                          Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Text(
                                    "From",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  DropdownButton<int>(
                                    value: Get.find<HomeController>().ageMin,
                                    items: Get.find<HomeController>()
                                        .listAge
                                        .map((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(value.toString()),
                                      );
                                    }).toList(),
                                    onChanged: (int valueInt) {
                                      Get.find<HomeController>().ageMin =
                                          valueInt;
                                      changeValues.addAll({
                                        'age_range': {
                                          'min':
                                              '${Get.find<HomeController>().ageMin}',
                                          'max':
                                              '${Get.find<HomeController>().ageMax}'
                                        }
                                      });
                                      setState(() {});
                                    },
                                  )
                                ],
                              )),
                          Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Text(
                                    "To",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  DropdownButton<int>(
                                    value: Get.find<HomeController>().ageMax,
                                    items: Get.find<HomeController>()
                                        .listAge
                                        .map((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(value.toString()),
                                      );
                                    }).toList(),
                                    onChanged: (int valueInt) {
                                      Get.find<HomeController>().ageMax =
                                          valueInt;
                                      changeValues.addAll({
                                        'age_range': {
                                          'min':
                                              '${Get.find<HomeController>().ageMin}',
                                          'max':
                                              '${Get.find<HomeController>().ageMax}'
                                        }
                                      });
                                      setState(() {});
                                    },
                                  )
                                ],
                              )),
                        ]),
                      ),
                    ),
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
                          'Checkout our brand new dating app! https://jablesscupid.com/', //Replace with your dynamic link and msg for invite users
                          subject:
                              'Checkout our brand new dating app! https://jablesscupid.com/');
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
                            content: Text(
                                'Would you like to logout of your account?'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('No'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await _auth.signOut().whenComplete(() {
                                    GetStorage().write("listUidSwiped", []);
                                    Get.delete<NotificationController>();
                                    Get.delete<TabsController>();
                                    Get.put(NotificationController());
                                    Get.put(TabsController());
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
                            content:
                                Text('Do you want to delete your account?'),
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
}
