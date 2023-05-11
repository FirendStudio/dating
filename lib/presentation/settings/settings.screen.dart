import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/infrastructure/dal/util/session.dart';
import 'package:hookup4u/presentation/dashboard/view/home/controllers/home.controller.dart';
import 'package:hookup4u/presentation/notif/controllers/notif.controller.dart';
import 'package:share/share.dart';

import '../../domain/core/interfaces/search/CustomSearch.dart';
import '../../infrastructure/dal/util/Global.dart';
import '../../infrastructure/dal/util/color.dart';
import '../../infrastructure/dal/util/general.dart';
import '../../infrastructure/navigation/routes.dart';
import '../profile/update_location/update_location_widget.dart';
import 'controllers/settings.controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
//    Get.put(SettingsController());
    return Obx(
      () => Scaffold(
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
                        // Get.find<VerifyProfileController>()
                        //     .phoneNumController
                        //     .text = "";
                        controller.getVerifyModel();
                      }),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 10, top: 20, bottom: 20),
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
                                  globalController.currentUser.value?.verified != 3 ? "Unverified" : "Verified",
                                  style: TextStyle(
                                    color:
                                        globalController.currentUser.value?.verified != 3 ? Colors.red : Colors.green,
                                  ),
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
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: InkWell(
                      onTap: (() {
                        if (globalController.reviewModel.value?.status?.value == "review") {
                          Global().showInfoDialog("Waiting Reviewed by Admin");
                          return;
                        }
                        if (globalController.reviewModel.value?.status?.value == "suspend") {
                          Get.toNamed(
                            Routes.SETTINGS_VIEW_VERIFIED_PROFILE,
                            arguments: {
                              "reviewModel": globalController.reviewModel.value!,
                            },
                          );
                          return;
                        }
                        Global().showInfoDialog("Your Profile Already Verified");
                      }),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 10, top: 20, bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Text("Verification Profile"),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  (globalController.reviewModel.value?.status?.value == "suspend" ||
                                          globalController.reviewModel.value?.status?.value == "review")
                                      ? (globalController.reviewModel.value?.status?.value ?? "").capitalizeFirst ?? ""
                                      : "Verified",
                                  style: TextStyle(
                                    color: (globalController.reviewModel.value?.status?.value == "suspend" ||
                                            globalController.reviewModel.value?.status?.value == "review")
                                        ? Colors.red
                                        : Colors.green,
                                  ),
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
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Card(
                        child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 10,
                        top: 20,
                        bottom: 20,
                      ),
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
                                (globalController.currentUser.value?.phoneNumber ?? "").isNotEmpty
                                    ? "${globalController.currentUser.value?.phoneNumber}"
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
                          Get.toNamed(Routes.AUTH_OTP, arguments: {
                            "updateNumber": true,
                          });
                        },
                      ),
                    )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 10,
                        top: 20,
                        bottom: 20,
                      ),
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
                          controller.connectedAccountWidget();
                        },
                      ),
                    ),
                  ),



                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Partner",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Column(
                    children: [
                      if ((globalController.currentUser.value?.relasi.value?.pendingAcc ?? []).isEmpty &&
                          (globalController.currentUser.value?.relasi.value?.pendingReq ?? []).isEmpty)
                        newPartnerWidget(),
                      if ((globalController.currentUser.value?.relasi.value?.pendingAcc ?? []).isNotEmpty &&
                          (globalController.currentUser.value?.relasi.value?.pendingReq ?? []).isEmpty)
                        pendingWidget(),
                      if ((globalController.currentUser.value?.relasi.value?.pendingAcc ?? []).isEmpty &&
                          (globalController.currentUser.value?.relasi.value?.pendingReq ?? []).isNotEmpty)
                        acceptWidget(),
                      if ((globalController.currentUser.value?.relasi.value?.pendingAcc ?? []).isNotEmpty &&
                          (globalController.currentUser.value?.relasi.value?.pendingReq ?? []).isNotEmpty)
                        relationWidget(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Search Settings",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  ///-- search only verified User
                  Container(
                    padding: const EdgeInsets.only(bottom: 5, right: 10, left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Show only Verified User",
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                        CupertinoSwitch(
                          value: SettingsController.isVerifiedUserOnly.value,
                          onChanged: (value) {
                            SettingsController.isVerifiedUserOnly.value = value;
                            if (SettingsController.isVerifiedUserOnly.value) {
                              Get.find<HomeController>().listUsers.removeWhere((element) => element.verified != 3);
                            } else {
                              Get.find<HomeController>().initUser(false);
                            }
                          },
                          activeColor: primaryColor.withOpacity(0.3),
                          thumbColor: primaryColor,
                          trackColor: Colors.grey.shade400.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 5, right: 10, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Show me",
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        GridView.count(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          childAspectRatio: 4 / 1,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 8.0,
                          // Generate 100 widgets that display their index in the List.
                          children: List.generate(
                            listShowMe.length,
                            (index) {
                              return Obx(
                                () => OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primaryColor,
                                    side: BorderSide(
                                      width: 1,
                                      style: BorderStyle.solid,
                                      color: listShowMe[index].onTap.value ? primaryColor : secondryColor,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                                    child: Center(
                                      child: Text(
                                        "${listShowMe[index].name.value}".toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: Global.font,
                                          color: listShowMe[index].onTap.value ? primaryColor : secondryColor,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    listShowMe[index].onTap.value = !listShowMe[index].onTap.value;
                                    if (listShowMe[index].onTap.value) {
                                      controller.listSelectedGender.add(listShowMe[index].name.value);
                                    } else {
                                      controller.listSelectedGender.remove(listShowMe[index].name.value);
                                    }
                                    print(controller.listSelectedGender);
                                    controller.changeValues.addAll({
                                      'showGender': controller.listSelectedGender,
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                 /* Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 50),

                        child: CountryCodePicker(
                          onChanged: (value) {
                            controller.countryCode = value.dialCode ?? "";
                          },
                          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                          initialSelection: 'IN',
                          favorite: [controller.countryCode, 'IN'],
                          // optional. Shows only country name and flag
                          showCountryOnly: false,
                          // optional. Shows only country name and flag when popup is closed.
                          showOnlyCountryWhenClosed: false,
                          // optional. aligns the flag and the Text left
                          alignLeft: false,
                        ),
                      ),*/



                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            "Maximum distance",
                            style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(
                            "${controller.distance.value} Km.",
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: Slider(
                              value: controller.distance.value.toDouble(),
                              inactiveColor: secondryColor,
                              min: 0.0,
                              max: globalController.isPurchased.value
                                  ? controller.paidR.toDouble()
                                  : controller.freeR.toDouble(),
                              activeColor: primaryColor,
                              onChanged: (val) {
                                controller.changeValues.addAll({'maximum_distance': val.round()});

                                controller.distance.value = val.round();
                                globalController.addDistance.value=0;
                              }),
                        ),
                      ),
                    ),
                  ),  Padding(
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
                          (globalController.currentUser.value?.address ?? ""),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              // print(await Global().getLocationCoordinates());
                              await Get.to(() => UploadLocationWidget());
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.blue,
                                    size: 25,
                                  ),
                                  Text(
                                    "Change location",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                          title: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "Age range",
                              style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.w500),
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    Text(
                                      "From",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    DropdownButton<int>(
                                      value: controller.ageMin.value,
                                      items: globalController.listAge.map((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(value.toString()),
                                        );
                                      }).toList(),
                                      onChanged: (int? valueInt) {
                                        if (valueInt != null) {
                                          controller.ageMin.value = valueInt;
                                          controller.changeValues.addAll({
                                            'age_range': {
                                              'min': '${controller.ageMin.value}',
                                              'max': '${controller.ageMax.value}'
                                            }
                                          });
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    Text(
                                      "To",
                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    DropdownButton<int>(
                                      value: controller.ageMax.value,
                                      items: globalController.listAge.map((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(value.toString()),
                                        );
                                      }).toList(),
                                      onChanged: (int? valueInt) {
                                        if (valueInt != null) {
                                          controller.ageMax.value = valueInt;
                                          controller.changeValues.addAll({
                                            'age_range': {
                                              'min': '${controller.ageMin.value}',
                                              'max': '${controller.ageMax.value}'
                                            }
                                          });
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Share.share(
                          'Checkout our brand new dating app! https://jablesscupid.com/',
                          //Replace with your dynamic link and msg for invite users
                          subject: 'Checkout our brand new dating app! https://jablesscupid.com/',
                        );
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
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text('No'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await FirebaseAuth.instance.signOut();
                                      Session().saveSwipedUser([]);


                                      Get.find<GlobalController>().isPurchased.value=false;
                                      Get.delete<GlobalController>();
                                      Get.put(GlobalController());
                                      Get.find<GlobalController>().isFromLogOut.value = true;
                                    } catch (e) {
                                      Global().showInfoDialog(e.toString());
                                    }

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
                              style: TextStyle(color: primaryColor, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        await buildShowDeleteAccountDialog(context, false);
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
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  )
                ],
              ),
            ),
          ),
        ),
        // ),
      ),
    );
  }

  buildShowDeleteAccountDialog(BuildContext context, isFromPermanently) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text('Delete Account'),
          content: Text(
            isFromPermanently
                ? 'Your account has been deleted. We are sorry to see you go and hope to see you back again soon.'
                : "You are about to permanently delete your account. Are you sure you want to do this?",
          ),
          actions: <Widget>[
            isFromPermanently
                ? SizedBox()
                : ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No'),
                  ),
            ElevatedButton(
              onPressed: () async {
                if (isFromPermanently) {
                  try {
                    Get.back();
                    Get.find<GlobalController>().isFromLogOut.value = true;

                    Get.offAllNamed(
                      Routes.AUTH_LOGIN,
                    );
                  } catch (e) {
                    Global().showInfoDialog(e.toString());
                  }
                }
                String getType = Session().getLoginType();
                Session().clearDate();
                Session().saveLoginType(getType);

                await controller.deleteUser();
                await FirebaseAuth.instance.signOut();
                Get.back();
                buildShowDeleteAccountDialog(context, true);
              },
              child: Text(!isFromPermanently ? 'Yes' : 'OK'),
            ),
          ],
        );
      },
    );
  }

  Widget newPartnerWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: Card(
          color: primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: Text(
                "Add Partner",
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        onTap: () {
          showSearch(context: Get.context!, delegate: CustomSearch());
          // Share.share(
          //     'check out my website https://deligence.com', //Replace with your dynamic link and msg for invite users
          //     subject: 'Look what I made!');
        },
      ),
    );
  }

  Widget pendingWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            (globalController.currentUser.value?.relasi.value?.pendingAcc[0].userName ?? "") + " (Pending)",
            style: TextStyle(fontSize: 16),
          ),
          InkWell(
            child: SizedBox(
              height: 50,
              child: Card(
                color: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            onTap: () async {
              await Global().deletePartner(
                Uid: globalController.currentUser.value?.relasi.value?.pendingAcc[0].reqUid ?? "",
              );
            },
          ),
        ],
      ),
    );
  }

  Widget acceptWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 7,
            child: Text(
              (globalController.currentUser.value?.relasi.value?.pendingReq[0].userName ?? "") + " (Requested)",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 1,
            child: FloatingActionButton(
              backgroundColor: Colors.greenAccent,
              onPressed: () async {
                debugPrint("add partner accept request----->");
                await Get.find<NotifController>().acceptPartner(
                  context2: Get.context!,
                  Uid: globalController.currentUser.value?.relasi.value?.pendingReq[0].reqUid ?? "",
                  imageUrl: globalController.currentUser.value?.relasi.value?.pendingReq[0].imageUrl ?? "",
                  userName: globalController.currentUser.value?.relasi.value?.pendingReq[0].userName ?? "",
                );
              },
              child: Icon(
                Icons.add,
                size: 25,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 1,
            child: FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () async {
                await Global().deletePartner(
                  Uid: globalController.currentUser.value?.relasi.value?.pendingReq[0].reqUid ?? "",
                );
              },
              child: Icon(
                Icons.close,
                size: 25,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  Widget relationWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            globalController.currentUser.value?.relasi.value?.partner?.partnerName ?? '',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          InkWell(
            child: SizedBox(
              height: 50,
              child: Card(
                color: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            onTap: () async {
              await Global().deletePartner(
                Uid: globalController.currentUser.value?.relasi.value?.partner?.partnerId ?? "",
              );
            },
          ),
        ],
      ),
    );
  }
}
