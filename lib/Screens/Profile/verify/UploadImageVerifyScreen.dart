import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/TabsController.dart';
import 'package:hookup4u/Controller/VerifyProfileController.dart';
import 'package:image_picker/image_picker.dart';

import '../../../util/color.dart';

class UploadImageVerifyScreen extends StatelessWidget {
  const UploadImageVerifyScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyProfileController>(builder: (data) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Account Verification",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: Container(
          padding: const EdgeInsets.only(
                left: 15.0, right: 15, bottom: 5, top: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                      text: "Verification Status : ",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: [
                        TextSpan(
                            text:(Get.find<TabsController>().currentUser.verified == 0)
                                ? "Unverified":(Get.find<TabsController>().currentUser.verified == 1)
                                ? "On Verification Admin":(Get.find<TabsController>().currentUser.verified == 2)
                                ? "Rejected"
                                : "Verified",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:Colors.red)),
                      ]),
                ),
                SizedBox(height: 30,),
                Text("To get verified we will send you a code which you will need to write down on a A4 sheet of paper."
                + "\n\nPlease make sure that the numbers are written in large font and can easily be seen."
                + "\n\nYou will then take a selfie displaying your face alongside the sheet of paper."),
                SizedBox(height: 50,),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: (data.croppedFile == null)
                      ? Image.asset("asset/images/ic_profile.png",
                      height: 200,
                      )
                      : Image.file(data.croppedFile,
                        height: 200,
                      )
                  ),
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
                SizedBox(height: 20,),
                Center(
                  child: InkWell(
                    onTap: () async {
                      if(data.croppedFile == null){
                        Get.snackbar("Information", "Please select your photo first");
                        return;
                      }
                      data.uploadFile(data.croppedFile);
                    },
                    child: Container(
                      height: Get.size.height * .065,
                      width: Get.size.width * .75,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Center(
                        child: Text("Upload Photo",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      )
                    )
                  ),
                )
                
              ],
            ),
          ) 
        )
      );
    });
  }
}
