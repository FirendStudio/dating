import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hookup4u/domain/core/interfaces/loading.dart';
import 'package:hookup4u/domain/core/model/ChatModel.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../domain/core/interfaces/largeImage.dart';
import '../../../../domain/core/interfaces/report/report_user.dart';
import '../../../../infrastructure/dal/util/Global.dart';
import '../../../../infrastructure/dal/util/color.dart';
import 'controllers/notif_view_chat.controller.dart';

class NotifViewChatScreen extends GetView<NotifViewChatController> {
  const NotifViewChatScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(NotifViewChatController());
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.red,
          centerTitle: true,
          elevation: 0,
          title: Text(controller.userSecond.name),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Get.back(),
          ),
          actions: <Widget>[
            PopupMenuButton(onSelected: ((value) async {
              if (value == "value1") {
                await showDialog(
                  barrierDismissible: true,
                  context: Get.context!,
                  builder: (context) => ReportUser(
                    currentUser: globalController.currentUser.value!,
                    seconduser: controller.userSecond,
                  ),
                );
              }
              if (value == "value2") {
                Global().leaveWidget(
                  globalController.currentUser.value!,
                  controller.userSecond,
                  controller.chatId,
                  "chat",
                );
              }
              if (value == "value3") {
                if (controller.listChat.first.senderId !=
                    globalController.currentUser.value!.id) {
                  Get.snackbar("Information", "Sorry you are not authorized");
                  return;
                }
                Global().restoreLeaveWidget(
                  globalController.currentUser.value!,
                  controller.userSecond,
                  controller.listChat.first.idDoc ?? "",
                  controller.chatId,
                  "chat",
                );
              }

              if (value == "value4") {
                Global().disconnectWidget(
                  globalController.currentUser.value!,
                  controller.userSecond,
                  controller.chatId,
                  "chat",
                );
              }
            }), itemBuilder: (ct) {
              return [
                PopupMenuItem(
                  value: 'value1',
                  child: Container(
                    // width: 150,
                    height: 30,
                    child: Text(
                      "Report Member",
                    ),
                  ),
                ),
                if (controller.listChat.isEmpty ||
                    controller.listChat.first.type != "Leave" &&
                        controller.listChat.first.type != "Disconnect")
                  PopupMenuItem(
                    value: 'value2',
                    child: Container(
                      height: 30,
                      child: Text(
                        "Leave Conversation",
                      ),
                    ),
                  ),
                if (controller.listChat.isNotEmpty &&
                    controller.listChat.first.type == "Leave" &&
                    controller.listChat.first.senderId ==
                        globalController.currentUser.value!.id &&
                    controller.listChat.first.type != "Disconnect")
                  PopupMenuItem(
                    value: 'value3',
                    child: Container(
                      height: 30,
                      child: Text(
                        "Resume Conversation",
                      ),
                    ),
                  ),
                if (controller.listChat.isNotEmpty &&
                    controller.listChat.first.type != "Disconnect")
                  PopupMenuItem(
                    value: 'value4',
                    child: Container(
                      height: 30,
                      child: Text(
                        "Permanently Disconnect",
                      ),
                    ),
                  ),
              ];
            })
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: primaryColor,
            body: ClipRRect(
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    // if (controller.listChat.isEmpty)
                    //   Container(
                    //     height: 15,
                    //     width: 15,
                    //     child: CircularProgressIndicator(
                    //       valueColor: AlwaysStoppedAnimation(primaryColor),
                    //       strokeWidth: 2,
                    //     ),
                    //   ),
                    Expanded(
                      child: Obx(
                        () => ListView(
                          reverse: true,
                          children: generateMessages(controller.listChat.value),
                        ),
                      ),
                    ),

                    Divider(height: 1.0),
                    Container(
                      alignment: Alignment.bottomCenter,
                      decoration:
                          BoxDecoration(color: Theme.of(context).cardColor),
                      child: messageWidget(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget messageWidget() {
    if (controller.listChat.isEmpty) {
      return buildTextComposer();
    }
    if (controller.isBlocked) {
      return Text("Sorry You can't send message!");
    }
    if (controller.listChat.isNotEmpty &&
        controller.listChat.first.type == "Leave") {
      return Container();
    }
    if (controller.listChat.isNotEmpty &&
        controller.listChat.first.type == "Disconnect") {
      return Container();
    }
    return buildTextComposer();
  }

  // var blockedBy;
  // checkblock() {
  //   chatController.chatReference.doc('blocked').snapshots().listen((onData) {
  //     if (onData.data != null) {
  //       // blockedBy = onData.data['blockedBy'];
  //       // if (onData.data['isBlocked']) {
  //       blockedBy = onData['blockedBy'];
  //       if (onData['isBlocked']) {
  //         chatController.isBlocked = true;
  //       } else {
  //         chatController.isBlocked = false;
  //       }
  //       data.update();
  //       // if (mounted) setState(() {});
  //     }
  //     // print(onData.data['blockedBy']);
  //   });
  // }

  List<Widget> generateSenderLayout(ChatsModel chatsModel) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              // child: documentSnapshot.data['image_url'] != ''
              child: chatsModel.imageUrl != ''
                  ? InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              top: 2.0,
                              bottom: 2.0,
                              right: 15,
                            ),
                            child: Stack(
                              children: <Widget>[
                                CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      loadingWidget(null, null),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  height: Get.height * .65,
                                  width: Get.width * .9,
                                  imageUrl: chatsModel.imageUrl ?? '',
                                  fit: BoxFit.fitWidth,
                                ),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child:
                                      // documentSnapshot.data['isRead'] == false
                                      chatsModel.isRead == false
                                          ? Icon(
                                              Icons.done,
                                              color: secondryColor,
                                              size: 15,
                                            )
                                          : Icon(
                                              Icons.done_all,
                                              color: primaryColor,
                                              size: 15,
                                            ),
                                ),
                              ],
                            ),
                            height: 150,
                            width: 150.0,
                            color: secondryColor.withOpacity(.5),
                            padding: EdgeInsets.all(5),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              chatsModel.time != null
                                  ? DateFormat.yMMMd('en_US')
                                      .add_jm()
                                      .format(
                                        DateTime.parse(
                                          chatsModel.time ??
                                              DateTime.now().toIso8601String(),
                                        ),
                                      )
                                      .toString()
                                  : "",
                              style: TextStyle(
                                color: secondryColor,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(Get.context!).push(
                          CupertinoPageRoute(
                            builder: (context) => LargeImage(
                              chatsModel.imageUrl,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 10.0,
                      ),
                      width: Get.width * 0.65,
                      margin: EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0,
                        left: 80.0,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  // documentSnapshot.data['text'],
                                  chatsModel.text ?? "",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                chatsModel.time != null
                                    ? DateFormat.MMMd('en_US')
                                        .add_jm()
                                        .format(
                                          DateTime.parse(
                                            chatsModel.time ??
                                                DateTime.now()
                                                    .toIso8601String(),
                                          ),
                                        )
                                        .toString()
                                    : "",
                                style: TextStyle(
                                  color: secondryColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              // documentSnapshot.data['isRead'] == false
                              chatsModel.isRead == false
                                  ? Icon(
                                      Icons.done,
                                      color: secondryColor,
                                      size: 15,
                                    )
                                  : Icon(
                                      Icons.done_all,
                                      color: primaryColor,
                                      size: 15,
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> generateMessages(List<ChatsModel> snapshot) {
    print(controller.listChat.value);
    return snapshot
        .map<Widget>(
          (doc) => Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: doc.type == "Call"
                  ? [
                      Text(doc.time != null
                          ? "${doc.text} : " +
                              DateFormat.yMMMd('en_US')
                                  .add_jm()
                                  .format(DateTime.parse(doc.time ??
                                      DateTime.now().toIso8601String()))
                                  .toString() +
                              " by ${doc.senderId == globalController.currentUser.value?.id ? "You" : "${controller.userSecond.name}"}"
                          : "")
                    ]
                  // : doc.data['sender_id'] != sender.id
                  : doc.type == "Disconnect"
                      ? [
                          if (doc.senderId !=
                              globalController.currentUser.value?.id)
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: 20,
                                  bottom: 20,
                                  right: 15,
                                  left: 15,
                                ),
                                margin: EdgeInsets.only(
                                  right: 15,
                                  left: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[100],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      doc.text ?? "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        clearHistoryChatWidget(
                                          controller.chatId,
                                        );
                                      },
                                      child: Container(
                                        // width:150,
                                        padding: EdgeInsets.only(
                                          left: 18,
                                          right: 18,
                                          top: 12,
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                          color: Colors.black,
                                        ),
                                        child: Text(
                                          "Clear Chat History",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (doc.senderId ==
                              globalController.currentUser.value?.id)
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: 20,
                                  bottom: 20,
                                  right: 15,
                                  left: 15,
                                ),
                                margin: EdgeInsets.only(
                                  right: 15,
                                  left: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[100],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "You are now permanently disconnected from this member",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        clearHistoryChatWidget(
                                          controller.chatId,
                                        );
                                      },
                                      child: Container(
                                        // width:150,
                                        padding: EdgeInsets.only(
                                          left: 18,
                                          right: 18,
                                          top: 12,
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                          color: Colors.black,
                                        ),
                                        child: Text(
                                          "Clear Chat History",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ]
                      : doc.type == "Leave"
                          ? [
                              (doc.senderId !=
                                      globalController.currentUser.value?.id)
                                  ? Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          top: 20,
                                          bottom: 20,
                                          right: 15,
                                          left: 15,
                                        ),
                                        margin: EdgeInsets.only(
                                          right: 15,
                                          left: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow[100],
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              doc.text ?? "",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              "Leaving the conversation means that this member no longer wants" +
                                                  " to chat and can't be contacted unless they decide to resume the conversation",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          print(
                                              controller.listChat.first.idDoc);
                                          Global().restoreLeaveWidget(
                                            globalController.currentUser.value!,
                                            controller.userSecond,
                                            controller.listChat.first.idDoc ??
                                                '',
                                            controller.chatId,
                                            "chat",
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: 20,
                                            bottom: 20,
                                            right: 15,
                                            left: 15,
                                          ),
                                          margin: EdgeInsets.only(
                                            right: 15,
                                            left: 15,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.yellow[100],
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                "You have left this chat",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                  left: 18,
                                                  right: 18,
                                                  top: 12,
                                                  bottom: 12,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5),
                                                  ),
                                                  color: Colors.black,
                                                ),
                                                child: Text(
                                                  "Resume chat",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                            ]
                          : doc.senderId !=
                                  globalController.currentUser.value?.id
                              ? generateReceiverLayout(doc)
                              : generateSenderLayout(doc),
            ),
          ),
        )
        .toList();
  }

  // List<Widget> generateChatWidget(var doc) {
  //   if (doc['sender_id'] != widget.sender.id) {
  //     return generateReceiverLayout(doc);
  //   }
  //   return generateSenderLayout(doc);
  // }

  List<Widget> generateReceiverLayout(ChatsModel documentSnapshot) {
    if (documentSnapshot.isRead == false) {
      print(documentSnapshot.idDoc);
      queryCollectionDB("chats")
          .doc(controller.chatId)
          .collection('messages')
          .doc(documentSnapshot.idDoc)
          .update({
        'isRead': true,
      });
    }
    return messagesIsRead(documentSnapshot);
  }

  messagesIsRead(ChatsModel chatsModel) {
    return <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            child: CircleAvatar(
              backgroundColor: secondryColor,
              radius: 25.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(90),
                child: CachedNetworkImage(
                  imageUrl:
                      (controller.userSecond.imageUrl.runtimeType == String)
                          ? controller.userSecond.imageUrl[0]
                          : controller.userSecond.imageUrl[0]['url'],
                  useOldImageOnUrlChange: true,
                  placeholder: (context, url) => CupertinoActivityIndicator(
                    radius: 15,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            onTap: () async {
              controller.userSecond.relasi.value =
                  await Global().getRelationship(controller.userSecond.id);
              controller.userSecond.distanceBW = Global()
                  .calculateDistance(
                    globalController
                            .currentUser.value?.coordinates?['latitude'] ??
                        0,
                    globalController
                            .currentUser.value?.coordinates?['longitude'] ??
                        0,
                    controller.userSecond.coordinates?['latitude'] ?? 0,
                    controller.userSecond.coordinates?['longitude'] ?? 0,
                  )
                  .round();
              Global().initProfil(controller.userSecond);
            },
          ),
        ],
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: chatsModel.imageUrl != ''
                  ? InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.only(
                                top: 2.0, bottom: 2.0, right: 15),
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Center(
                                child: CupertinoActivityIndicator(
                                  radius: 10,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              height: Get.height * .65,
                              width: Get.width * .9,
                              imageUrl: chatsModel.imageUrl ?? '',
                              fit: BoxFit.fitWidth,
                            ),
                            height: 150,
                            width: 150.0,
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            padding: EdgeInsets.all(5),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                                chatsModel.time != null
                                    ? DateFormat.yMMMd('en_US')
                                        .add_jm()
                                        .format(DateTime.parse(chatsModel
                                                .time ??
                                            DateTime.now().toIso8601String()))
                                        .toString()
                                    : "",
                                style: TextStyle(
                                  color: secondryColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                )),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(Get.context!).push(CupertinoPageRoute(
                          builder: (context) => LargeImage(
                            chatsModel.imageUrl,
                          ),
                        ));
                      },
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 10.0,
                      ),
                      width: Get.width * 0.65,
                      margin: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 10),
                      decoration: BoxDecoration(
                        color: secondryColor.withOpacity(.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  chatsModel.text ?? "",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                chatsModel.time != null
                                    ? DateFormat.MMMd('en_US')
                                        .add_jm()
                                        .format(DateTime.parse(chatsModel
                                                .time ??
                                            DateTime.now().toIso8601String()))
                                        .toString()
                                    : "",
                                style: TextStyle(
                                  color: secondryColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
            ),
          ],
        ),
      ),
    ];
  }

  Widget getDefaultSendButton() {
    return Obx(() {
      return IconButton(
        icon: Transform.rotate(
          angle: -pi / 9,
          child: Icon(
            Icons.send,
            size: 25,
          ),
        ),
        color: primaryColor,
        onPressed: controller.isWritting.value
            ? () => controller.sendText(
                  (controller.textController?.text ?? "").trimRight(),
                  globalController.currentUser.value!,
                  controller.userSecond,
                )
            : null,
      );
    });
  }

  Widget buildTextComposer() {
    return Obx(
      () => IconTheme(
        data: IconThemeData(
            color: controller.isWritting.value ? primaryColor : secondryColor),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: Icon(
                    Icons.photo_camera,
                    color: primaryColor,
                  ),
                  onPressed: () async {
                    var image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    int timestamp = new DateTime.now().millisecondsSinceEpoch;
                    if (image != null) {
                      FirebaseStorage storage = FirebaseStorage.instance;
                      Reference ref = storage.ref().child(
                          'chats/${controller.chatId}/img_' +
                              timestamp.toString() +
                              '.jpg');
                      UploadTask uploadTask = ref.putFile(File(image.path));
                      uploadTask.then((res) async {
                        String fileUrl = await res.ref.getDownloadURL();
                        controller.sendImage(
                          messageText: 'Photo',
                          imageUrl: fileUrl,
                          sender: globalController.currentUser.value!,
                          second: controller.userSecond,
                        );
                      });
                    }
                  },
                ),
              ),
              new Flexible(
                child: new TextField(
                  controller: controller.textController,
                  maxLines: 15,
                  minLines: 1,
                  autofocus: false,
                  onChanged: (String messageText) {
                    controller.isWritting.value = messageText.trim().length > 0;
                    // print("Jalan disini");
                  },
                  decoration: new InputDecoration.collapsed(
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    hintText: "Send a message...",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: getDefaultSendButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  clearHistoryChatWidget(String idChat) async {
    return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: CupertinoAlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Clear History Chat")],
            ),
            content: Column(
              children: [
                Text(
                  "Are you sure you want to clear chat?",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () => controller.clearChatHistory(idChat),
                        child: Container(
                          margin: EdgeInsets.only(
                              left: 0, top: 4, bottom: 4, right: 6),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                            // borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Text(
                            "Yes",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 6,
                            top: 4,
                            bottom: 4,
                            right: 0,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                          ),
                          child: Text(
                            "No",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            insetAnimationCurve: Curves.decelerate,
            actions: [],
          ),
        );
      },
    );
  }
}
