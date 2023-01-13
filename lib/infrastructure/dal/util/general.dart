import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/config.dart';
import '../../../domain/core/model/CustomTapModel.dart';
import '../controller/global_controller.dart';

RxDouble progressLoading = 0.0.obs;
String env = ConfigEnvironments.getEnvironments()['path']!;
var globalController = Get.put(GlobalController());

CollectionReference<Map<String, dynamic>> queryCollectionDB(String path) {
  return FirebaseFirestore.instance.collection(env + path);
}

DocumentReference<Map<String, dynamic>> queryDocDB(String path) {
  return FirebaseFirestore.instance.doc(env + path);
}

List<CustomTapModel> orientationlist = [
  CustomTapModel(name: "straight".obs, onTap: false.obs),
  CustomTapModel(name: "gay".obs, onTap: false.obs),
  CustomTapModel(name: "lesbian".obs, onTap: false.obs),
  CustomTapModel(name: "bisexual".obs, onTap: false.obs),
  CustomTapModel(name: "bi-curious".obs, onTap: false.obs),
  CustomTapModel(name: "pansexual".obs, onTap: false.obs),
  CustomTapModel(name: "polysexual".obs, onTap: false.obs),
  CustomTapModel(name: "queer".obs, onTap: false.obs),
  CustomTapModel(name: "androgynobexual".obs, onTap: false.obs),
  CustomTapModel(name: "androsexual".obs, onTap: false.obs),
  CustomTapModel(name: "asexual".obs, onTap: false.obs),
  CustomTapModel(name: "autosexual".obs, onTap: false.obs),
  CustomTapModel(name: "demisexual".obs, onTap: false.obs),
  CustomTapModel(name: "gray a".obs, onTap: false.obs),
  CustomTapModel(name: "gynosexual".obs, onTap: false.obs),
  CustomTapModel(name: "heteroflexible".obs, onTap: false.obs),
  CustomTapModel(name: "homoflexible".obs, onTap: false.obs),
  CustomTapModel(name: "objectumsexual".obs, onTap: false.obs),
  CustomTapModel(name: "omnisexual".obs, onTap: false.obs),
  CustomTapModel(name: "skoliosexual".obs, onTap: false.obs),
];

List<CustomTapModel> listGender = [
  CustomTapModel(name: "man".obs, onTap: false.obs),
  CustomTapModel(name: "woman".obs, onTap: false.obs),
  CustomTapModel(name: "other".obs, onTap: false.obs),
  CustomTapModel(name: "agender".obs, onTap: false.obs),
  CustomTapModel(name: "androgynous".obs, onTap: false.obs),
  CustomTapModel(name: "bigender".obs, onTap: false.obs),
  CustomTapModel(name: "gender fluid".obs, onTap: false.obs),
  CustomTapModel(name: "gender non conforming".obs, onTap: false.obs),
  CustomTapModel(name: "gender queer".obs, onTap: false.obs),
  CustomTapModel(name: "gender questioning".obs, onTap: false.obs),
  CustomTapModel(name: "intersex".obs, onTap: false.obs),
  CustomTapModel(name: "non-binary".obs, onTap: false.obs),
  CustomTapModel(name: "pangender".obs, onTap: false.obs),
  CustomTapModel(name: "trans human".obs, onTap: false.obs),
  CustomTapModel(name: "trans man".obs, onTap: false.obs),
  CustomTapModel(name: "trans woman".obs, onTap: false.obs),
  CustomTapModel(name: "transfeminime".obs, onTap: false.obs),
  CustomTapModel(name: "transmasculine".obs, onTap: false.obs),
  CustomTapModel(name: "two-spirit".obs, onTap: false.obs),
];

List<CustomTapModel> listDesire = [
  CustomTapModel(name: "relationship".obs, onTap: false.obs),
  CustomTapModel(name: "friendship".obs, onTap: false.obs),
  CustomTapModel(name: "casual".obs, onTap: false.obs),
  CustomTapModel(name: "fwb".obs, onTap: false.obs),
  CustomTapModel(name: "fun".obs, onTap: false.obs),
  CustomTapModel(name: "dates".obs, onTap: false.obs),
  CustomTapModel(name: "texting".obs, onTap: false.obs),
  CustomTapModel(name: "threesome".obs, onTap: false.obs),
];

List<CustomTapModel> listStatus = [
  CustomTapModel(name: "single".obs, onTap: false.obs),
  CustomTapModel(name: "man + woman couple".obs, onTap: false.obs),
  CustomTapModel(name: "man + man couple".obs, onTap: false.obs),
  CustomTapModel(name: "woman + woman couple".obs, onTap: false.obs),
];

List<CustomTapModel> listShowMe = [
  CustomTapModel(name: "men".obs, onTap: false.obs),
  CustomTapModel(name: "women".obs, onTap: false.obs),
  CustomTapModel(name: "man + woman couples".obs, onTap: false.obs),
  CustomTapModel(name: "man + man couples".obs, onTap: false.obs),
  CustomTapModel(name: "woman + woman couples".obs, onTap: false.obs),
  CustomTapModel(name: "gender fluid".obs, onTap: false.obs),
  CustomTapModel(name: "gender non conforming".obs, onTap: false.obs),
  CustomTapModel(name: "gender queer".obs, onTap: false.obs),
  CustomTapModel(name: "agender".obs, onTap: false.obs),
  CustomTapModel(name: "androgynous".obs, onTap: false.obs),
  CustomTapModel(name: "gender questioning".obs, onTap: false.obs),
  CustomTapModel(name: "intersex".obs, onTap: false.obs),
  CustomTapModel(name: "non-binary".obs, onTap: false.obs),
  CustomTapModel(name: "pangender".obs, onTap: false.obs),
  CustomTapModel(name: "trans human".obs, onTap: false.obs),
  CustomTapModel(name: "trans man".obs, onTap: false.obs),
  CustomTapModel(name: "trans woman".obs, onTap: false.obs),
  CustomTapModel(name: "transfeminime".obs, onTap: false.obs),
  CustomTapModel(name: "transmasculine".obs, onTap: false.obs),
  CustomTapModel(name: "two-spirit".obs, onTap: false.obs),
];

final List listAdds = [
  {
    'icon': Icons.whatshot,
    'color': Colors.indigo,
    'title': "Subscribe now",
    'subtitle': "for unlimited matches and contacts",
  },
  // {
  //   'icon': Icons.whatshot,
  //   'color': Colors.indigo,
  //   'title': "Get matches faster",
  //   'subtitle': "Boost your profile once a month",
  // },
  // {
  //   'icon': Icons.favorite,
  //   'color': Colors.lightBlueAccent,
  //   'title': "more likes",
  //   'subtitle': "Get free rewindes",
  // },
  // {
  //   'icon': Icons.star_half,
  //   'color': Colors.amber,
  //   'title': "Increase your chances",
  //   'subtitle': "Get unlimited free likes",
  // },
  // {
  //   'icon': Icons.location_on,
  //   'color': Colors.purple,
  //   'title': "Swipe around the world",
  //   'subtitle': "Passport to anywhere with hookup4u",
  // },
  // {
  //   'icon': Icons.vpn_key,
  //   'color': Colors.orange,
  //   'title': "Control your profile",
  //   'subtitle': "highly secured",
  // }
];
