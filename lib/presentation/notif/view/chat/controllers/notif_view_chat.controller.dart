import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/model/ChatModel.dart';
import 'package:hookup4u/domain/core/model/user_model.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:hookup4u/presentation/notif/controllers/notif.controller.dart';
import '../../../../../domain/core/model/RoomModel.dart';
import '../../../../../infrastructure/dal/util/Global.dart';
import '../../../../../infrastructure/navigation/routes.dart';

class NotifViewChatController extends GetxController {
  StreamSubscription<QuerySnapshot>? streamChat;
  TextEditingController? textController;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? streamRoomModel;
  RxList<ChatsModel> listChat = RxList();
  RxList<ChatsModel> listChatAll = RxList();
  late UserModel userSecond;
  Rxn<RoomModel> selectedRoom = Rxn();
  String chatId = "";
  bool isBlocked = false;
  RxBool isWritting = false.obs;

  @override
  void onInit() {
    super.onInit();
    initChatScreen();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    streamChat?.cancel();
    streamRoomModel?.cancel();
    streamChat = null;
    streamRoomModel = null;
  }

  initChatScreen() async {
    textController = TextEditingController();
    chatId = Get.arguments['chatId'];
    userSecond = Get.arguments['userSecond'];
    listChat.value = [];
    if (kDebugMode) {
      print("object    -$chatId");
    }
    listenRoomModel();
    listenChat();
  }

  listenChat() {
    if (streamChat != null) {
      return;
    }
    print(chatId);
    streamChat = queryCollectionDB("chats")
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((event) async {
      // print("Masuk chat");
      // print(event.docs);
      if (event.docs.isEmpty) {
        return;
      }
      listChatAll.value = [];
      for (var doc in event.docs) {
        Timestamp timeStamp = doc['time'] ?? Timestamp.fromDate(DateTime.now());
        var data = doc.data();
        data.addAll({
          "idDoc": doc.id,
          "time": (timeStamp.toDate()).toIso8601String(),
        });
        listChatAll.add(ChatsModel.fromJson(data));
      }
      filterChatHistory(chatId);
      await Get.find<NotifController>().filterMatches();
    });
  }

  listenRoomModel() {
    streamRoomModel = queryCollectionDB("chats")
        .doc(chatId)
        .snapshots()
        .listen((event) async {
      if (event.exists == false) {
        print("Not Exist");
        Global().setNewOptionMessage(chatId);
        return;
      }
      selectedRoom.value = RoomModel.fromJson(event.data()!);
      filterChatHistory(chatId);
    });
  }

  filterChatHistory(String chatId) {
    if (listChatAll.isEmpty || selectedRoom.value == null) {
      return;
    }
    listChat.assignAll(listChatAll);
    bool check = false;
    var split = chatId.split("-");
    if (split[0] == globalController.currentUser.value?.id &&
        selectedRoom.value?.isclear1 == true) {
      check = true;
    }
    if (split[1] == globalController.currentUser.value?.id &&
        selectedRoom.value?.isclear2 == true) {
      check = true;
    }
    if (check) {
      listChat.removeWhere((element) {
        return element.type != "Disconnect";
      });
    }
  }

  clearChatHistory(String chatId) async {
    String clearID = "";
    var split = chatId.split("-");
    if (split[0] == globalController.currentUser.value?.id) {
      clearID = "isclear1";
      if (selectedRoom.value?.isclear1 == true) {
        Get.back();
        Get.snackbar("Information", "You've already clear history");
        return;
      }
    }
    if (split[1] == globalController.currentUser.value?.id) {
      clearID = "isclear2";
      if (selectedRoom.value?.isclear2 == true) {
        Get.back();
        Get.snackbar("Information", "You've already clear history");
        return;
      }
    }
    await queryCollectionDB("chats").doc(chatId).set({
      clearID: true,
    }, SetOptions(merge: true));
    Get.offAllNamed(Routes.DASHBOARD);
  }

  Future<Null> sendText(String text, UserModel sender, UserModel second) async {
    textController?.clear();
    queryCollectionDB("chats").doc(chatId).collection('messages').add({
      'type': 'Msg',
      'text': text,
      'sender_id': sender.id,
      'receiver_id': second.id,
      'isRead': false,
      'image_url': '',
      'time': FieldValue.serverTimestamp(),
    }).then((documentReference) {
      globalController.sendChatFCM(
        idUser: second.id,
        name: globalController.currentUser.value?.name ?? "",
      );
      isWritting.value = false;
    }).catchError((e) {
      isWritting.value = false;
      Global().showInfoDialog(e.toString());
    });
  }

  void sendImage(
      {required String messageText,
      required String imageUrl,
      required UserModel sender,
      required UserModel second}) {
    queryCollectionDB("chats").doc(chatId).collection('messages').add({
      'type': 'Image',
      'text': messageText,
      'sender_id': sender.id,
      'receiver_id': second.id,
      'isRead': false,
      'image_url': imageUrl,
      'time': FieldValue.serverTimestamp(),
    }).then(
      (value) => globalController.sendChatFCM(
        idUser: second.id,
        name: globalController.currentUser.value?.name ?? "",
      ),
    );
  }

  // Future<void> onJoin(callType, UserModel sender, UserModel second) async {
  //   if (!isBlocked) {
  //     // await for camera and mic permissions before pushing video page

  //     await handleCameraAndMic(callType);
  //     await chatReference.add({
  //       'type': 'Call',
  //       'text': callType,
  //       'sender_id': sender.id,
  //       'receiver_id': second.id,
  //       'isRead': false,
  //       'image_url': "",
  //       'time': FieldValue.serverTimestamp(),
  //     });

  //     // push video page with given channel name
  //     // await Navigator.push(
  //     //   context,
  //     //   MaterialPageRoute(
  //     //     builder: (context) => DialCall(
  //     //         channelName: widget.chatId,
  //     //         receiver: widget.second,
  //     //         callType: callType),
  //     //   ),
  //     // );
  //   } else {
  //     Global().showInfoDialog("Blocked !");
  //   }
  // }
}
