import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  XFile image;
  ImagePicker imagePicker = ImagePicker();

  updateProfileImage() {}

  Future<void> pickImage(ImageSource source, {bool metode = false}) async {
    final XFile file =
        await imagePicker.pickImage(source: source, imageQuality: 50);

    if (file == null) {
      return;
    }
    if (metode) {
      image = file;
    }
    update();
  }
}
