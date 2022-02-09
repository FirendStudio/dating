import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hookup4u/models/user_model.dart';

class Notify {
  final UserModel sender;
  final Timestamp time;
  final bool isRead;

  Notify({
    this.sender,
    this.time,
    this.isRead,
  });
}
