import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../util/color.dart';

class ProfileController extends GetxController {
  // XFile image;
  ImagePicker imagePicker = ImagePicker();
  File croppedFile;

  updateProfileImage() {}

  Future<void> pickImage(ImageSource source, {bool metode = false}) async {
    final XFile file =
        await imagePicker.pickImage(source: source, imageQuality: 50);

    if (file == null) {
      return;
    }
    if (metode) {
      croppedFile = await ImageCropper.cropImage(
          sourcePath: file.path,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      // image = file;
      if(croppedFile != null){
        update();
      }
    }
    
  }
}
