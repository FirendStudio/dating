import 'dart:convert';

// Payment paymentFromJson(String str) => Payment.fromDocument(json.decode(str));

// String paymentToJson(Payment data) => json.encode(data.toJson());

class VerifyModel {
  VerifyModel({
    this.code = "",
    this.idUser = "",
    this.imageUrl = "",
    this.name = "",
    this.phoneNumber = "",
    this.reasonVerified = "",
    this.verified = 0,
    this.dateUpdated,
  });

  String code;
  String idUser;
  String imageUrl;
  String name;
  String phoneNumber;
  String reasonVerified;
  int verified;
  DateTime? dateUpdated;

  factory VerifyModel.fromDocument(Map<String, dynamic> json) => VerifyModel(
    code: json["code"],
    idUser: json["idUser"],
    imageUrl: json["imageUrl"],
    name: json["name"],
    phoneNumber: json["phoneNumber"],
    reasonVerified: json["reason_verified"] ?? "",
    verified: json["verified"],
    dateUpdated: DateTime.parse(json["date_updated"] ?? DateTime.now().toIso8601String()),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "idUser": idUser,
    "imageUrl" : imageUrl,
    "name": name,
    "phoneNumber": phoneNumber,
    "reason_verified" : reasonVerified,
    "verified": verified,
    "date": dateUpdated?.toIso8601String(),
  };
}
