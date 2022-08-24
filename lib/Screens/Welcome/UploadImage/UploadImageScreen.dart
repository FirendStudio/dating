import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/ProfileController.dart';
import 'package:image_picker/image_picker.dart';

import '../../../util/color.dart';

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
              height: 120,
            ),
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.all(12),
                      width: Get.width,
                      height: 300,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.redAccent,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: (data.image == null)
                          ? Image.asset("asset/images/logo2.png")
                          : Image.file(File(data.image.path))),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          iconSize: 50,
                          color: Colors.black,
                          onPressed: () {
                            data.pickImage(ImageSource.camera, metode: true);
                          },
                          icon: Icon(Icons.camera)),
                        IconButton(
                          iconSize: 50,
                          color: Colors.black,
                          onPressed: () {
                            data.pickImage(ImageSource.gallery, metode: true);
                          },
                          icon: Icon(Icons.image)
                        ),
                      ]
                    )
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text("")
            )
          ]),
        )
      );
    });
    
  }
}
