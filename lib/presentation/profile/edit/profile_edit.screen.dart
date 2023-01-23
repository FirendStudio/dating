import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:hookup4u/presentation/profile/controllers/profile.controller.dart';

import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';
import 'controllers/profile_edit.controller.dart';

class ProfileEditScreen extends GetView<ProfileEditController> {
  ProfileEditScreen({Key? key}) : super(key: key);
  var profileController = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    Get.put(ProfileEditController());
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Edit Profile",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: primaryColor,
        ),
        body: Scaffold(
          backgroundColor: primaryColor,
          body: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      height: Get.height * .65,
                      width: Get.width,
                      child: GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio: Get.size.aspectRatio * 1.5,
                        crossAxisSpacing: 4,
                        padding: EdgeInsets.all(10),
                        children: List.generate(
                          9,
                          (index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: (globalController.currentUser
                                                      .value?.imageUrl ??
                                                  [])
                                              .length >
                                          index
                                      ? BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        )
                                      : BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            style: BorderStyle.solid,
                                            width: 1,
                                            color: secondryColor,
                                          ),
                                        ),
                                  child: Stack(
                                    children: <Widget>[
                                      (globalController.currentUser.value
                                                          ?.imageUrl ??
                                                      [])
                                                  .length >
                                              index
                                          ? CachedNetworkImage(
                                              height: Get.height * .2,
                                              fit: BoxFit.cover,
                                              imageUrl: (globalController
                                                          .currentUser
                                                          .value!
                                                          .imageUrl[index]
                                                          .runtimeType ==
                                                      String)
                                                  ? globalController.currentUser
                                                      .value!.imageUrl[index]
                                                  : globalController
                                                              .currentUser
                                                              .value!
                                                              .imageUrl[index]
                                                          ['url'] ??
                                                      '',
                                              placeholder: (context, url) =>
                                                  Center(
                                                child:
                                                    CupertinoActivityIndicator(
                                                  radius: 10,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.error,
                                                      color: Colors.black,
                                                      size: 25,
                                                    ),
                                                    Text(
                                                      "Enable to load",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          padding: (globalController
                                                              .currentUser
                                                              .value
                                                              ?.imageUrl ??
                                                          [])
                                                      .length >
                                                  index
                                              ? EdgeInsets.all(4)
                                              : EdgeInsets.all(4),
                                          decoration: ((globalController
                                                              .currentUser
                                                              .value
                                                              ?.imageUrl ??
                                                          [])
                                                      .length >
                                                  index)
                                              ? BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: primaryColor,
                                                )
                                              : null,
                                          child: (globalController
                                                              .currentUser
                                                              .value
                                                              ?.imageUrl ??
                                                          [])
                                                      .length >
                                                  index
                                              ? InkWell(
                                                  child: Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 22,
                                                  ),
                                                  onTap: () async {
                                                    if (index == 0) {
                                                      ArtSweetAlert.show(
                                                        context: context,
                                                        artDialogArgs:
                                                            ArtDialogArgs(
                                                          type:
                                                              ArtSweetAlertType
                                                                  .info,
                                                          title: "Info",
                                                          text:
                                                              "You cannot edit profile image",
                                                        ),
                                                      );
                                                    } else {
                                                      controller.indexImage =
                                                          index;
                                                      bool show = true;
                                                      if (globalController
                                                                  .currentUser
                                                                  .value
                                                                  ?.imageUrl[
                                                                      index]
                                                                  .runtimeType ==
                                                              String ||
                                                          globalController
                                                                      .currentUser
                                                                      .value
                                                                      ?.imageUrl[
                                                                  index]['show'] ==
                                                              "true") {
                                                        show = true;
                                                      } else {
                                                        show = false;
                                                      }
                                                      if ((globalController
                                                                      .currentUser
                                                                      .value
                                                                      ?.imageUrl ??
                                                                  [])
                                                              .length >
                                                          1) {
                                                        // _deletePicture(index);

                                                        controller
                                                            .showPrivateImageDialog(
                                                          context,
                                                          true,
                                                          globalController
                                                              .currentUser
                                                              .value!,
                                                          true,
                                                          show,
                                                        );
                                                      } else {
                                                        controller
                                                            .showPrivateImageDialog(
                                                          context,
                                                          true,
                                                          globalController
                                                              .currentUser
                                                              .value!,
                                                          true,
                                                          show,
                                                        );
                                                        // source(context, widget.currentUser, true);
                                                      }
                                                    }
                                                  },
                                                )
                                              : Container(
                                                  color: Colors.white,
                                                ),
                                        ),
                                      ),
                                      if ((globalController.currentUser.value
                                                      ?.imageUrl ??
                                                  [])
                                              .length >
                                          index)
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            // width: 12,
                                            // height: 16,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: primaryColor,
                                            ),
                                            child: InkWell(
                                              child: Icon(
                                                (globalController
                                                                .currentUser
                                                                .value
                                                                ?.imageUrl[
                                                                    index]
                                                                .runtimeType ==
                                                            String ||
                                                        globalController
                                                                    .currentUser
                                                                    .value
                                                                    ?.imageUrl[
                                                                index]['show'] ==
                                                            "true")
                                                    ? Icons.visibility
                                                    : Icons.visibility_off_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                              onTap: () async {},
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    InkWell(
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
                              primaryColor,
                            ],
                          ),
                        ),
                        height: 50,
                        width: 340,
                        child: Center(
                          child: Text(
                            "Add media",
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        await profileController.source(
                          context,
                          globalController.currentUser.value!,
                          false,
                          "true",
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListBody(
                        mainAxis: Axis.vertical,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              "About ",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: CupertinoTextField(
                              controller: controller.aboutCtlr,
                              cursorColor: primaryColor,
                              maxLines: 10,
                              minLines: 3,
                              placeholder: "About you",
                              padding: EdgeInsets.all(10),
                              onChanged: (text) {
                                controller.editInfo.addAll({'about': text});
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5,
                              right: 10,
                              left: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Gender",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  childAspectRatio: 4 / 1,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 8.0,
                                  // Generate 100 widgets that display their index in the List.
                                  children:
                                      List.generate(listGender.length, (index) {
                                    return Obx(
                                      () => OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          side: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color:
                                                listGender[index].name.value ==
                                                        controller
                                                            .selectedGender
                                                            .value
                                                            ?.name
                                                            .value
                                                    ? primaryColor
                                                    : secondryColor,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 8,
                                            right: 8,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${listGender[index].name.value}"
                                                  .toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: Global.font,
                                                color: listGender[index]
                                                            .name
                                                            .value ==
                                                        controller
                                                            .selectedGender
                                                            .value
                                                            ?.name
                                                            .value
                                                    ? primaryColor
                                                    : secondryColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          controller.selectedGender.value =
                                              listGender[index];
                                          controller.editInfo.addAll({
                                            'userGender': controller
                                                    .selectedGender
                                                    .value
                                                    ?.name.value ??
                                                "",
                                            'showOnProfile': globalController
                                                    .currentUser
                                                    .value
                                                    ?.showingGender ??
                                                false
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, bottom: 5, right: 10, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Sexual Orientation",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  childAspectRatio: 4 / 1,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 8.0,
                                  children: List.generate(
                                      orientationlist.length, (index) {
                                    return Obx(
                                      () => OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          side: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color: orientationlist[index]
                                                        .name
                                                        .value ==
                                                    controller.selectedSexual
                                                        .value?.name.value
                                                ? primaryColor
                                                : secondryColor,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 8,
                                            right: 8,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${orientationlist[index].name.value}"
                                                  .toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: Global.font,
                                                color: orientationlist[index]
                                                            .name
                                                            .value ==
                                                        controller
                                                            .selectedSexual
                                                            .value
                                                            ?.name
                                                            .value
                                                    ? primaryColor
                                                    : secondryColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          controller.selectedSexual.value =
                                              orientationlist[index];
                                          controller.orientationMap.addAll({
                                            "sexualOrientation": {
                                              'orientation': controller
                                                      .selectedSexual
                                                      .value
                                                      ?.name.value ??
                                                  "",
                                              'showOnProfile': globalController
                                                      .currentUser
                                                      .value
                                                      ?.showingOrientation ??
                                                  false
                                            },
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, bottom: 5, right: 10, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Status",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
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
                                  children:
                                      List.generate(listStatus.length, (index) {
                                    return Obx(
                                      () => OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          side: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color:
                                                listStatus[index].name.value ==
                                                        controller
                                                            .selectedStatus
                                                            .value
                                                            ?.name
                                                            .value
                                                    ? primaryColor
                                                    : secondryColor,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 8,
                                            right: 8,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${listStatus[index].name.value}"
                                                  .toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: Global.font,
                                                color: listStatus[index]
                                                            .name
                                                            .value ==
                                                        controller
                                                            .selectedStatus
                                                            .value
                                                            ?.name
                                                            .value
                                                    ? primaryColor
                                                    : secondryColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          controller.selectedStatus.value =
                                              listStatus[index];
                                          controller.statusMap.addAll({
                                            'status': controller.selectedStatus
                                                    .value?.name.value ??
                                                "",
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5,
                              right: 10,
                              left: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "I am looking for",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  childAspectRatio: 4 / 1,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 8.0,
                                  // Generate 100 widgets that display their index in the List.
                                  children:
                                      List.generate(listDesire.length, (index) {
                                    return Obx(
                                      () => OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          side: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color: listDesire[index].onTap.value
                                                ? primaryColor
                                                : secondryColor,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 8,
                                            right: 8,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${listDesire[index].name.value}"
                                                  .toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: Global.font,
                                                color: listDesire[index]
                                                        .onTap
                                                        .value
                                                    ? primaryColor
                                                    : secondryColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          listDesire[index].onTap.value =
                                              !listDesire[index].onTap.value;
                                          if (listDesire[index].onTap.value) {
                                            controller.listSelectedDesire.add(
                                                listDesire[index].name.value);
                                            if (kDebugMode) {
                                              print(
                                                  listDesire[index].name.value);
                                              print(controller
                                                  .listSelectedDesire);
                                            }
                                          } else {
                                            controller.listSelectedDesire
                                                .remove(listDesire[index]
                                                    .name
                                                    .value);
                                            if (kDebugMode) {
                                              print(controller
                                                  .listSelectedDesire);
                                            }
                                          }
                                          controller.desiresMap.addAll({
                                            'desires':
                                                controller.listSelectedDesire,
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5,
                              right: 10,
                              left: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Kinks & Desires",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                                  children:
                                      List.generate(listKinks.length, (index) {
                                    return Obx(
                                      () => OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          side: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color: listKinks[index].onTap.value
                                                ? primaryColor
                                                : secondryColor,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 8,
                                            right: 8,
                                          ),
                                          child: Center(
                                            child: Text(
                                              listKinks[index]
                                                  .name
                                                  .value
                                                  .toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: Global.font,
                                                color:
                                                    listKinks[index].onTap.value
                                                        ? primaryColor
                                                        : secondryColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          listKinks[index].onTap.value =
                                              !listKinks[index].onTap.value;
                                          if (listKinks[index].onTap.value) {
                                            controller.listSelectedKinks.add(
                                              listKinks[index].name.value,
                                            );
                                            if (kDebugMode) {
                                              print(
                                                  listKinks[index].name.value);
                                              print(
                                                  controller.listSelectedKinks);
                                            }
                                          } else {
                                            controller.listSelectedKinks.remove(
                                                listKinks[index].name.value);
                                            print(controller.listSelectedKinks);
                                          }
                                          controller.kinksMap.addAll({
                                            'kinks':
                                                controller.listSelectedKinks,
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, bottom: 5, right: 10, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Interest",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 12),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      controller.listSelectedInterest.length,
                                  itemBuilder: ((context, index) {
                                    return Container(
                                      padding: EdgeInsets.only(
                                        left: 8,
                                        right: 8,
                                        top: 8,
                                        bottom: 8,
                                      ),
                                      margin: EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[500]!,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              controller
                                                  .listSelectedInterest[index],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              onPressed: () {
                                                controller.listSelectedInterest
                                                    .removeAt(index);
                                                if (kDebugMode) {
                                                  print(controller
                                                      .listSelectedInterest);
                                                }
                                                controller.interestMap.addAll({
                                                  'interest': controller
                                                      .listSelectedInterest
                                                      .value,
                                                });
                                              },
                                              icon: Icon(Icons.cancel),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await controller.dialogInterest(context);
                                    
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.green[600],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          "Add new interest",
                                          style: TextStyle(
                                            color: Colors.green[600],
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
