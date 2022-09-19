import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/user_model.dart';
import '../util/snackbar.dart';
import 'NotificationController.dart';
import 'TabsController.dart';

class ChatController extends GetxController {
  bool isBlocked = false;
  final db = FirebaseFirestore.instance;
  CollectionReference chatReference;
  TextEditingController textController = new TextEditingController();
  bool isWritting = false;
  StreamSubscription<QuerySnapshot> streamMessage;
  StreamSubscription<QuerySnapshot> streamChat;
  QuerySnapshot listMessageSnapshot;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> listChatSnapshot = [];
  bool checkStreamChat = false;

  initChatScreen(String chatId) async {
    print("object    -${chatId}");
    streamMessage = null;
    var check = await FirebaseFirestore.instance.collection("chats").doc(chatId).get();
    print(check.id);
    if(!check.exists){
      print("Not Exist");
      setNewOptionMessage(chatId);
    }
    chatReference = db.collection("chats").doc(chatId).collection('messages');
    streamMessage = chatReference
      .orderBy('time', descending: true)
      .snapshots()
      .listen((event) {
        listMessageSnapshot = event;
        update();
    });
    
  }

  chatIdCustom(idUser, idSender) {
    String groupChatId = "";
    if (idUser.hashCode <= idSender.hashCode) {
      return groupChatId = '${idUser}-${idSender}';
    } else {
      return groupChatId = '${idSender}-${idUser}';
    }
  }




  initListChat(List<String> listIDChat){
    if(listIDChat.isEmpty){
      return;
    }
    streamChat = FirebaseFirestore.instance.collection("chats").where("active", isEqualTo: false).where("docId", whereIn: listIDChat).snapshots().listen((event) async {
      print("Masuk List Chat");
      listChatSnapshot = event.docs;
      // if(event.docs.isNotEmpty){
      //   print(event.docs.first.data());
        
      // }
      await Get.find<NotificationController>().filterMatches();
      checkStreamChat = true;
      Get.find<NotificationController>().update();
      Get.find<TabsController>().update();
      update();
      print("Jumlah docs : " + event.docs.length.toString());
    });
  }

  setNewOptionMessage(String chatId){
    FirebaseFirestore.instance.collection("chats").doc(chatId).set({
      "active" : true,
      "docId" : chatId
    });
  }

  onback() {
    streamMessage.cancel();
    // Get.back();
  }
  leaveWidget(UserModel sender, UserModel second, String idChat, String type) async {
    return await showDialog(
        context: Get.context,
        builder: (BuildContext context) {
          return Material(
              color: Colors.transparent,
              child: CupertinoAlertDialog(
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [Text("Leave Conversation")]),
                  content: Column(
                    children: [
                      Text(
                        "Are you sure that you would like to leave this conversation?",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: () => leaveFunction(sender, second, idChat, type),
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: 0, top: 4, bottom: 4, right: 6),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[400],
                                      ),
                                      // borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    child: Text(
                                      "Yes",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ))),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: () {
                                  Get.back();
                                  if(type == "chat"){
                                    Get.back();
                                  }
                                  
                                },
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: 6, top: 4, bottom: 4, right: 0),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[400],
                                      ),
                                      // borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    child: Text(
                                      "No",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ))),
                          ),
                        ],
                      ),
                    ],
                  ),
                  insetAnimationCurve: Curves.decelerate,
                  actions: []));
        });
  }

  leaveFunction(UserModel sender, UserModel second, String idChat, String type) async {
    await FirebaseFirestore.instance.collection("chats").doc(idChat).collection('messages').add({
      'type': 'Leave',
      'text': "${sender.name} has left the conversation.",
      'sender_id': sender.id,
      'receiver_id': second.id,
      'isRead': false,
      'image_url': "",
      'time': FieldValue.serverTimestamp(),
    }).then((value) async {
      // if(type == "notif"){
      //   await Get.find<NotificationController>().filterMatches();
      // }
      Get.find<NotificationController>().sendLeaveFCM(
        idUser: second.id,
        name: Get.find<TabsController>().currentUser.name,
      );
      await Get.find<NotificationController>().filterMatches();
      update();
      Get.find<NotificationController>().update();
      Get.find<TabsController>().update();
      if(type=='chat'){
        Get.back();
      }
      Get.back();
    });
  }

  restoreLeaveWidget(UserModel sender, UserModel second, String idMessage, String idChat, String type) async {
    return await showDialog(
        context: Get.context,
        builder: (BuildContext context) {
          return Material(
              color: Colors.transparent,
              child: CupertinoAlertDialog(
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [Text("Resume Chat")]),
                  content: Column(
                    children: [
                      Text(
                        "Are you sure that you want to resume this chat?",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: () => restoreLeaveFunction(sender, second, idMessage, idChat, type),
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: 0, top: 4, bottom: 4, right: 6),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[400],
                                      ),
                                      // borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    child: Text(
                                      "Yes",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ))),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: 6, top: 4, bottom: 4, right: 0),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[400],
                                      ),
                                      // borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    child: Text(
                                      "No",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ))),
                          ),
                        ],
                      ),
                    ],
                  ),
                  insetAnimationCurve: Curves.decelerate,
                  actions: []));
        });
  }

  restoreLeaveFunction(UserModel sender, UserModel second, String idMessage, String chatId, String type) async {
    
    await FirebaseFirestore.instance.collection("chats").doc(chatId).collection('messages').doc(idMessage).delete().then((value) async {
      if(type == "notif"){
        await Get.find<NotificationController>().filterMatches();
        Get.find<NotificationController>().update();
        Get.find<TabsController>().update();
      }
      Get.find<NotificationController>().sendRestoreLeaveFCM(
        idUser: second.id,
        name: Get.find<TabsController>().currentUser.name,
      );
      // if(type != "notif"){
      //   Get.back();
      // }
      Get.back();
    });
    
  }

  disconnectWidget(UserModel sender, UserModel second, String idChat, String type) async {
    return await showDialog(
      context: Get.context,
      builder: (BuildContext context) {
        return Material(
            color: Colors.transparent,
            child: CupertinoAlertDialog(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [Text("Permanently Disconnect")]),
                content: Column(
                  children: [
                    Text(
                      "This action will permanently disconnect you from ${second.name}."
                      + "\nAre you sure you want to proceed?",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                              onTap: () => disconnectFunction(sender, second, idChat, type),
                              child: Container(
                                  margin: EdgeInsets.only(
                                      left: 0, top: 4, bottom: 4, right: 6),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[400],
                                    ),
                                    // borderRadius: BorderRadius.all(Radius.circular(20))
                                  ),
                                  child: Text(
                                    "Yes",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ))),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                              onTap: () {
                                Get.back();
                                if(type == "chat"){
                                  Get.back();
                                }
                                
                              },
                              child: Container(
                                  margin: EdgeInsets.only(
                                      left: 6, top: 4, bottom: 4, right: 0),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[400],
                                    ),
                                    // borderRadius: BorderRadius.all(Radius.circular(20))
                                  ),
                                  child: Text(
                                    "No",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ))),
                        ),
                      ],
                    ),
                  ],
                ),
                insetAnimationCurve: Curves.decelerate,
                actions: []));
      });
  }

  disconnectFunction(UserModel sender, UserModel second, String chatId, String type) async {
    var result = await FirebaseFirestore.instance.collection("chats").doc(chatId).collection('messages')
    .orderBy('time', descending: true).limit(1).get();
    
    if(result.docs.isNotEmpty && result.docs.first['type']=="Leave"){
      if(kDebugMode){
        print(result.docs.first['type']);
      }
      await FirebaseFirestore.instance.collection("chats").doc(chatId).collection('messages').doc(result.docs.first.id).delete();
    }
    // Get.back();
    // return;
    await FirebaseFirestore.instance.collection("chats").doc(chatId).collection('messages').add({
      'type': 'Disconnect',
      'text': "${sender.name} has blocked you",
      'sender_id': sender.id,
      'receiver_id': second.id,
      'isRead': false,
      'image_url': "",
      'time': FieldValue.serverTimestamp(),
    });
    FirebaseFirestore.instance.collection("chats").doc(chatId).set({
      "active" : false,
      "docId" : chatId
    }).then((value) {
      Get.find<NotificationController>().sendDisconnectFCM(
        idUser: second.id,
        name: Get.find<TabsController>().currentUser.name,
      );
      if(type=="notif"){
        Get.back();
        return;
      }
      Get.to(()=>Tabbar(null, null));
    });
  }


  Future<Null> sendText(String text, UserModel sender, UserModel second) async {
    textController.clear();
    chatReference.add({
      'type': 'Msg',
      'text': text,
      'sender_id': sender.id,
      'receiver_id': second.id,
      'isRead': false,
      'image_url': '',
      'time': FieldValue.serverTimestamp(),
    }).then((documentReference) {
      Get.find<NotificationController>().sendChatFCM(
        idUser: second.id,
        name: Get.find<TabsController>().currentUser.name,
      );
      isWritting = false;
      update();
    }).catchError((e) {});
  }

  void sendImage(
      {String messageText,
      String imageUrl,
      UserModel sender,
      UserModel second}) {
    chatReference.add({
      'type': 'Image',
      'text': messageText,
      'sender_id': sender.id,
      'receiver_id': second.id,
      'isRead': false,
      'image_url': imageUrl,
      'time': FieldValue.serverTimestamp(),
    }).then((value) => Get.find<NotificationController>().sendChatFCM(
          idUser: second.id,
          name: Get.find<TabsController>().currentUser.name,
        ));
  }

  Future<void> onJoin(callType, UserModel sender, UserModel second,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    if (!isBlocked) {
      // await for camera and mic permissions before pushing video page

      await handleCameraAndMic(callType);
      await chatReference.add({
        'type': 'Call',
        'text': callType,
        'sender_id': sender.id,
        'receiver_id': second.id,
        'isRead': false,
        'image_url': "",
        'time': FieldValue.serverTimestamp(),
      });

      // push video page with given channel name
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => DialCall(
      //         channelName: widget.chatId,
      //         receiver: widget.second,
      //         callType: callType),
      //   ),
      // );
    } else {
      CustomSnackbar.snackbar("Blocked !", scaffoldKey);
    }
  }
  clearChatHistory(){
    print("test");
  }
}

Future<void> handleCameraAndMic(callType) async {
  if (callType == "VideoCall") {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    print(statuses);
  } else {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
    ].request();
    print(statuses);
  }
}
