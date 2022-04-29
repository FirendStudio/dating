import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserModel {
  final String id;
  final String name;
  final bool isBlocked;
  String address;
  final Map coordinates;
  final String sexualOrientation;
  final bool showingOrientation;
  final String gender;
  final bool showingGender;
  final List showMe;
  final int age;
  final String phoneNumber;
  int maxDistance;
  Timestamp lastmsg;
  final Map ageRange;
  final Map editInfo;
  List imageUrl = [];
  var distanceBW;
  final String status;
  final Map LoginID;
  final String metode;
  final List desires;
  final List kinks;
  final List interest;
  UserModel({
    @required this.id,
    @required this.age,
    @required this.address,
    this.isBlocked,
    this.coordinates,
    @required this.name,
    @required this.imageUrl,
    this.phoneNumber,
    this.lastmsg,
    this.gender,
    this.showingGender,
    this.showMe,
    this.ageRange,
    this.maxDistance,
    this.editInfo,
    this.distanceBW,
    this.sexualOrientation,
    this.showingOrientation,
    this.status,
    this.desires,
    this.kinks,
    this.interest,
    @required this.LoginID,
    @required this.metode,
  });
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
        id: doc['userId'],
        // isBlocked: doc['isBlocked'] != null ? doc['isBlocked'] : false,
        isBlocked: false,
        phoneNumber: doc['phoneNumber'],
        name: doc['UserName'],
        editInfo: doc['editInfo'],
        ageRange: doc['age_range'],
        showMe: doc['showGender'],
        gender: doc['editInfo']['userGender'] ?? "woman",
        showingGender: doc['editInfo']['showOnProfile'] ?? true,
        maxDistance: doc['maximum_distance'],
        sexualOrientation: doc['sexualOrientation']['orientation'] ?? "",
        showingOrientation: doc['sexualOrientation']['showOnProfile'] ?? "",
        status: doc['status'] ?? 'single',
        desires: doc['desires'] ?? [],
        kinks: doc.data().toString().contains('kinks') ? doc['kinks'] : [],
        interest: doc.data().toString().contains('interest') ? doc['interest'] : [],
        age: ((DateTime.now().difference(DateTime.parse(doc["user_DOB"]))
            .inDays) / 365.2425).truncate(),
        address: doc['location']['address'],
        coordinates: doc['location'],
        LoginID : doc.data().toString().contains('LoginID') ? doc['LoginID'] : {},
        metode : doc.data().toString().contains('metode') ? doc['metode'] : "",
        // university: doc['editInfo']['university'],
        imageUrl: doc['Pictures'] != null
            ? List.generate(doc['Pictures'].length, (index) {
                return doc['Pictures'][index];
              })
            : []);
  }
}
