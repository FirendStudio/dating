import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/TabsController.dart';

import 'LoginController.dart';

class NotificationController extends GetxController{
  final db = FirebaseFirestore.instance;
  CollectionReference matchReference;
  CollectionReference docReference;
  int indexNotif = 0;
  List listLikedUserAll = [];
  List listLikedUser = [];

  initNotification(){
    // print("Jalankan 1 ");
    if(matchReference == null){
      docReference = FirebaseFirestore.instance.collection("Users");
      matchReference = db
          .collection("Users")
          .doc(Get.find<LoginController>().userId)
          .collection('Matches');
      initListLikedUser();
      // print("Jalankan 2 ");
      // db.collection("Users")
      //     .doc(Get.find<LoginController>().userId)
      //     .collection('LikedBy').orderBy('LikedBy', descending: true)
      //     .snapshots().listen((event) {
      //   print("LikedBy");
      //   print(event.docs.first['userName']);
      //   listLikedUser = event.docs;
      //
      //
      // });
    }

  }

  initListLikedUser(){

    listLikedUser = [];
    if(listLikedUserAll.isEmpty){
      return;
    }
    List checkedUser = Get.find<TabsController>().checkedUser;
    if(checkedUser.isEmpty){
      listLikedUser.assignAll(listLikedUserAll);
      update();
      return;
    }



    for(int index2=0; index2<=listLikedUserAll.length-1; index2++){
      print(listLikedUserAll[index2]['LikedBy']);
      bool cek = false;
      for(int index=0; index<= checkedUser.length-1; index++){
        if(listLikedUserAll[index2]['LikedBy'] == checkedUser[index]){
          cek = true;
        }
        if(cek){
          break;
        }
      }
      if(!cek){
        listLikedUser.add(listLikedUserAll[index2]);
      }

    }

    update();
  }

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