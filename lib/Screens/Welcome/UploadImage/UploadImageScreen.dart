import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/ProfileController.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Controller/LoginController.dart';
import '../../../util/Global.dart';
import '../../../util/color.dart';
import '../AllowLocation.dart';

class UploadImageScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  UploadImageScreen(this.userData);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (data) {
      return SafeArea(
          child: Scaffold(
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
              ),
            ],
          ),
        ),
        body: Column(children: [
          
          SizedBox(
            height: 100,
          ),

          Expanded(
            flex: 7,
            child:Column(
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: (data.croppedFile == null)
                    ? Image.asset("asset/images/ic_profile.png",
                    height: 200,
                    )
                    : Image.file(data.croppedFile,
                      height: 200,
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        iconSize: 50,
                        color: Colors.black,
                        onPressed: () {
                          data.pickImage(ImageSource.camera,
                              metode: true);
                        },
                        icon: Icon(Icons.photo_camera)),
                    IconButton(
                        iconSize: 50,
                        color: Colors.black,
                        onPressed: () {
                          data.pickImage(ImageSource.gallery,
                              metode: true);
                        },
                        icon: Icon(Icons.image)),
                  ]
                ),
                SizedBox(
                  height: 30,
                ),

                Text(
                  "You need to upload at least one image as part of the " + 
                  "registration process. Once you have completed the registration" + 
                  " you will be able to add more photos to your profile." + 
                  "\n\n Your profile image must not contain any nudity and be only of yourself.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: Global.font,
                  ),
                ),
              ],
            ) ,
          ),
          SizedBox(
            height: 30,
          ),
          Expanded(
            flex: 1,
            child: Padding(
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
                        "CONTINUE",
                        style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: FontWeight.bold),
                      ))),
                  onTap: () async {
                    print(userData);
                    // Get.to(() => UploadImageScreen(userData));
                    if(data.croppedFile == null){
                      Get.snackbar("Information", "You Must Choose Image First",
                        snackPosition: SnackPosition.TOP
                      );
                      return;
                    }
                    await Get.find<LoginController>().setUserData(userData);
                    await Get.find<LoginController>().updateFirstImageProfil(data.croppedFile);
                    
                  },
                ),
              ),
            ),
          )
        ]),
      ));
    });
  }
}
