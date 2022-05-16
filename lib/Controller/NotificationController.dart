import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/TabsController.dart';

import '../models/Relationship.dart';
import 'LoginController.dart';

class NotificationController extends GetxController{
  final db = FirebaseFirestore.instance;
  CollectionReference matchReference;
  CollectionReference docReference;
  Relationship relationUser;
  List <Pending> listPendingReq = [];
  List <Pending> listPendingAcc = [];
  int indexNotif = 0;
  List listLikedUserAll = [];
  List listLikedUser = [];
  List listMatchUser = [];

  initNotification(){
    // print("Jalankan 1 ");
    if(docReference == null){
      docReference = FirebaseFirestore.instance.collection("Users");
      db.collection("Users")
      .doc(Get.find<LoginController>().userId)
      .collection('Matches').orderBy('timestamp', descending: true)
      .snapshots().listen((event) {
        listMatchUser = event.docs;
        update();
      });
      FirebaseFirestore.instance.collection("Relationship")
      .doc(Get.find<LoginController>().userId)
      .snapshots().listen((event) async {
        print("relationship");
        if(!event.exists){
          await setNewRelationship(Get.find<LoginController>().userId);
          return;
        }
        print(event.data());
        relationUser = Relationship.fromDocument(event.data());
        listPendingReq.assignAll(relationUser.pendingReq);
        listPendingAcc.assignAll(relationUser.pendingAcc);
        update();

      });

      // initListLikedUser();
    }

  }
  
  Future <bool> addNewPendingAcc({@required String userName, @required String imageUrl, @required String Uid}) async {
    bool cek = false;

    if(listPendingAcc.isNotEmpty){
      for(int index=0; index<= listPendingAcc.length-1; index++){
        if(Uid == listPendingAcc[index].reqUid){
          cek = true;
          break;
        }
      }
      if(cek){
        return false;
      }
    }

    listPendingAcc.add(
        Pending(userName: userName, imageUrl: imageUrl,
            reqUid: Uid, createdAt: DateTime.now())
    );
    List listUpdateAcc = listPendingAcc.map((player) => player.toJson()).toList();
    Map <String, dynamic> updateAcc = {
      "pendingAcc" : listUpdateAcc,
    };
    print(updateAcc);

    await FirebaseFirestore.instance.collection("Relationship")
    .doc(Get.find<LoginController>().userId)
    .set(updateAcc,SetOptions(merge : true));
    return true;
  }

  Future <bool> addNewPendingReq({@required String userName, @required String imageUrl, @required String Uid}) async {

    DocumentSnapshot data = await FirebaseFirestore.instance.collection("Relationship")
        .doc(Uid).get();

    if(!data.exists){
      await setNewRelationship(Uid);
      data = await FirebaseFirestore.instance.collection("Relationship")
          .doc(Uid).get();
    }
    Relationship relationUserRequested = Relationship.fromDocument(data.data());

    bool cek = false;
    if(relationUserRequested.pendingReq.isNotEmpty){
      for(int index=0; index<= relationUserRequested.pendingReq.length-1; index++){
        if(Get.find<LoginController>().userId == relationUserRequested.pendingReq[index].reqUid){
          cek = true;
          break;
        }
      }
      if(cek){
        return false;
      }
    }

    relationUserRequested.pendingReq.add(
        Pending(userName: Get.find<TabsController>().currentUser.name, imageUrl: Get.find<TabsController>().currentUser.imageUrl[0]['url'],
            reqUid: Get.find<TabsController>().currentUser.id, createdAt: DateTime.now())
    );
    List listUpdateReq = relationUserRequested.pendingReq.map((player) => player.toJson()).toList();
    Map <String, dynamic> updateReq = {
      "pendingReq" : listUpdateReq,
    };
    print(updateReq);

    await FirebaseFirestore.instance.collection("Relationship")
        .doc(Uid)
        .set(updateReq,SetOptions(merge : true));
    return true;
  }

  setNewRelationship(String uid) async {
    Map <String, dynamic> newRelation = {
      "userId" : uid,
      "partner" : {
        "partnerId" : "",
        "partnerImage" : "",
      },
      "inRelationship" : false,
      "pendingReq" : [],
      "pendingAcc" : [],
      "updateAt": FieldValue.serverTimestamp()
    };

    await FirebaseFirestore.instance
        .collection("Relationship")
        .doc(uid)
        .set(newRelation,
        SetOptions(merge : true)
    );
  }

  // initListLikedUser(){
  //
  //   listLikedUser = [];
  //   if(listLikedUserAll.isEmpty){
  //     return;
  //   }
  //   List checkedUser = Get.find<TabsController>().checkedUser;
  //   if(checkedUser.isEmpty){
  //     listLikedUser.assignAll(listLikedUserAll);
  //     update();
  //     return;
  //   }
  //
  //
  //
  //   for(int index2=0; index2<=listLikedUserAll.length-1; index2++){
  //     print(listLikedUserAll[index2]['LikedBy']);
  //     bool cek = false;
  //     for(int index=0; index<= checkedUser.length-1; index++){
  //       if(listLikedUserAll[index2]['LikedBy'] == checkedUser[index]){
  //         cek = true;
  //       }
  //       if(cek){
  //         break;
  //       }
  //     }
  //     if(!cek){
  //       listLikedUser.add(listLikedUserAll[index2]);
  //     }
  //
  //   }
  //
  //   update();
  // }

  removeUserSwipe(int indexNotif){
    bool cek = false;
    int cekIndex = 0;
    for(int index=0; index <=Get.find<TabsController>().users.length-1; index++){

      if(Get.find<TabsController>().users[index].id == listLikedUser[indexNotif]['LikedBy']){
        cekIndex = index;
        cek = true;
        break;
      }

    }
    listLikedUser.removeAt(indexNotif);
    update();
    if(!cek){
      return;
    }
    Get.find<TabsController>().userRemoved.clear();
    Get.find<TabsController>().userRemoved.add(Get.find<TabsController>().users[cekIndex]);
    Get.find<TabsController>().users.removeAt(cekIndex);
    Get.find<TabsController>().update();
  }

}