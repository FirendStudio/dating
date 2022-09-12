import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/ChatController.dart';
import 'package:hookup4u/Screens/Chat/largeImage.dart';
import 'package:hookup4u/Screens/Info/Information.dart';
import 'package:hookup4u/Screens/reportUser.dart';
import 'package:hookup4u/ads/ads.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:easy_localization/easy_localization.dart';

import '../../Controller/NotificationController.dart';
import '../../Controller/TabsController.dart';
import '../Calling/dial.dart';

class ChatPage extends StatefulWidget {
  final UserModel sender;
  final String chatId;
  final UserModel second;
  ChatPage({this.sender, this.chatId, this.second});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // final UserModel sender;
  // final String chatId;
  // final UserModel widget.second;
  // ChatPage({this.widget.sender, this.chatId, this.widget.second});
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ChatController chatController = Get.put(ChatController());
  // Ads _ads = new Ads();

  // @override
  void initState() {
    // _ads.myInterstitial()
    //   ..load()
    //   ..show();
    // print("object    -${chatId}");
    super.initState();
    // checkblock();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        chatController.onback();
        return await true;
      },
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
              backgroundColor: Colors.red,
              centerTitle: true,
              elevation: 0,
              title: Text(widget.second.name),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.white,
                onPressed: () => Navigator.pop(Get.context),
              ),
              actions: <Widget>[
                // IconButton(
                //     icon: Icon(Icons.call), onPressed: () => onJoin("AudioCall")),
                // IconButton(
                //     icon: Icon(Icons.video_call),
                //     onPressed: () => onJoin("VideoCall")),
                PopupMenuButton(itemBuilder: (ct) {
                  return [
                    PopupMenuItem(
                      value: 'value1',
                      child: InkWell(
                        onTap: () => showDialog(
                            barrierDismissible: true,
                            context: Get.context,
                            builder: (context) => ReportUser(
                                  currentUser: widget.sender,
                                  seconduser: widget.second,
                                )).then((value) => Navigator.pop(ct)),
                        child: Container(
                            // width: 150,
                            height: 30,
                            child: Text(
                              "Report Member",
                            )),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'value2',
                      child: InkWell(
                        onTap: () {
                          chatController.leaveWidget(widget.sender, widget.second, widget.chatId, "chat");
                        },
                        child: Container(
                            // width: 150,
                            height: 30,
                            child: Text(
                              "Leave Conversation",
                            )),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'value3',
                      child: InkWell(
                        onTap: (){
                          chatController.disconnectWidget(widget.sender, widget.second, widget.chatId, "chat");
                        },
                        child: Container(
                            // width: 150,
                            height: 30,
                            child: Text(
                              "Permanently Disconnect",
                            )),
                      ),
                    ),
                    // PopupMenuItem(
                    //   height: 30,
                    //   value: 'value2',
                    //   child: InkWell(
                    //     child: Text(isBlocked ? "Unblock user" : "Block user"),
                    //     onTap: () {
                    //       Navigator.pop(ct);
                    //       showDialog(
                    //         Get.context: Get.context,
                    //         builder: (BuildContext ctx) {
                    //           return AlertDialog(
                    //             title: Text(isBlocked ? 'Unblock' : 'Block'),
                    //             content: Text('Do you want to ' + "${isBlocked ? 'Unblock' : 'Block'} " "${widget.second.name}"),
                    //             actions: <Widget>[
                    //               TextButton(
                    //                 onPressed: () =>
                    //                     Navigator.of(Get.context).pop(false),
                    //                 child: Text('No'),
                    //               ),
                    //               TextButton(
                    //                 onPressed: () async {
                    //                   Navigator.pop(ctx);
                    //                   if (isBlocked &&
                    //                       blockedBy == sender.id) {
                    //                     chatReference.doc('blocked').set({
                    //                       'isBlocked': !isBlocked,
                    //                       'blockedBy': sender.id,
                    //                     });
                    //                   } else if (!isBlocked) {
                    //                     chatReference.doc('blocked').set({
                    //                       'isBlocked': !isBlocked,
                    //                       'blockedBy': sender.id,
                    //                     });
                    //                   } else {
                    //                     CustomSnackbar.snackbar(
                    //                         "You can't unblock", _scaffoldKey);
                    //                   }
                    //                 },
                    //                 child: Text('Yes'),
                    //               ),
                    //             ],
                    //           );
                    //         },
                    //       );
                    //     },
                    //   ),
                    // )
                  ];
                })
              ]),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: primaryColor,
              body: ClipRRect(
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(50.0),
                //   topRight: Radius.circular(50.0),
                // ),
                child: Container(
                  decoration: BoxDecoration(
                    // image: DecorationImage(
                    //     fit: BoxFit.fitWidth,
                    //     image: AssetImage("asset/chat.jpg")),
                    // borderRadius: BorderRadius.only(
                    //     topLeft: Radius.circular(50),
                    //     topRight: Radius.circular(50)),
                    color: Colors.white
                  ),
                  padding: EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GetBuilder<ChatController>(builder: (data){
                        if(data.listMessageSnapshot == null){
                          return Container(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(primaryColor),
                              strokeWidth: 2,
                            ),
                          );
                        }
                        
                        return Expanded(
                          child: ListView(
                            reverse: true,
                            children: generateMessages(data.listMessageSnapshot, data),
                          ),
                        );
                      }),
                      
                      // StreamBuilder<QuerySnapshot>(
                      //   stream: chatController.chatReference.orderBy('time', descending: true).snapshots(),
                      //   builder: (BuildContext Get.context,
                      //       AsyncSnapshot<QuerySnapshot> snapshot) {
                      //     if (!snapshot.hasData)
                      //       return Container(
                      //         height: 15,
                      //         width: 15,
                      //         child: CircularProgressIndicator(
                      //           valueColor: AlwaysStoppedAnimation(primaryColor),
                      //           strokeWidth: 2,
                      //         ),
                      //       );
                      //     return Expanded(
                      //       child: ListView(
                      //         reverse: true,
                      //         children: generateMessages(snapshot, data),
                      //       ),
                      //     );
                      //   },
                      // ),
                      Divider(height: 1.0),
                      GetBuilder<ChatController>(builder: (data){
                        return Container(
                          alignment: Alignment.bottomCenter,
                          decoration:
                              BoxDecoration(color: Theme.of(context).cardColor),
                          child: messageWidget(data),
                        );
                      })
                      
                      
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }

  Widget messageWidget(ChatController data){
    if(data.listMessageSnapshot == null){
      return  _buildTextComposer(data);
    }
    if(chatController.isBlocked){
      return Text("Sorry You can't send message!");
    }
    if(data.listMessageSnapshot.docs.isNotEmpty && data.listMessageSnapshot.docs.first['type'] == "Leave"){
      return Container();
    }
    return  _buildTextComposer(data);
  }

  var blockedBy;
  checkblock(ChatController data) {
    chatController.chatReference.doc('blocked').snapshots().listen((onData) {
      if (onData.data != null) {
        // blockedBy = onData.data['blockedBy'];
        // if (onData.data['isBlocked']) {
        blockedBy = onData['blockedBy'];
        if (onData['isBlocked']) {
          chatController.isBlocked = true;
        } else {
          chatController.isBlocked = false;
        }
        data.update();
        // if (mounted) setState(() {});
      }
      // print(onData.data['blockedBy']);
    });
  }

  List<Widget> generateSenderLayout(DocumentSnapshot documentSnapshot, ChatController data) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              // child: documentSnapshot.data['image_url'] != ''
                child: documentSnapshot['image_url'] != ''
                  ? InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.only(
                                top: 2.0, bottom: 2.0, right: 15),
                            child: Stack(
                              children: <Widget>[
                                CachedNetworkImage(
                                  placeholder: (context, url) => Center(
                                    child: CupertinoActivityIndicator(
                                      radius: 10,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  height: Get.height * .65,
                                  width: Get.width * .9,
                                  // imageUrl: documentSnapshot.data['image_url'] ?? '',
                                  imageUrl: documentSnapshot['image_url'] ?? '',
                                  fit: BoxFit.fitWidth,
                                ),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child:
                                      // documentSnapshot.data['isRead'] == false
                                      documentSnapshot['isRead'] == false
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
                                )
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
                                // documentSnapshot.data["time"] != null
                                documentSnapshot["time"] != null
                                    ? DateFormat.yMMMd('en_US')
                                        .add_jm()
                                        // .format(documentSnapshot.data["time"]
                                        .format(documentSnapshot["time"]
                                            .toDate())
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
                        Navigator.of(Get.context).push(
                          CupertinoPageRoute(
                            builder: (context) => LargeImage(
                              // documentSnapshot.data['image_url'],
                              documentSnapshot['image_url'],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      width: MediaQuery.of(Get.context).size.width * 0.65,
                      margin: EdgeInsets.only(
                          top: 8.0, bottom: 8.0, left: 80.0, right: 10),
                      decoration: BoxDecoration(
                          color: primaryColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  // documentSnapshot.data['text'],
                                  documentSnapshot['text'],
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
                                // documentSnapshot.data["time"] != null
                                documentSnapshot["time"] != null
                                    ? DateFormat.MMMd('en_US')
                                // .add_jm().format(documentSnapshot.data["time"]
                                    .add_jm().format(documentSnapshot["time"]
                                    .toDate()).toString()
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
                              documentSnapshot['isRead'] == false
                                  ? Icon(
                                Icons.done,
                                color: secondryColor,
                                size: 15,
                              )
                                  : Icon(
                                Icons.done_all,
                                color: primaryColor,
                                size: 15,
                              )
                            ],
                          ),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.end,
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: <Widget>[
                          //     Expanded(
                          //       child: Container(
                          //         child: Text(
                          //           // documentSnapshot.data['text'],
                          //           documentSnapshot['text'],
                          //           style: TextStyle(
                          //             color: Colors.black87,
                          //             fontSize: 16.0,
                          //             fontWeight: FontWeight.w600,
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     Row(
                          //       mainAxisAlignment: MainAxisAlignment.end,
                          //       children: <Widget>[
                          //         Text(
                          //           // documentSnapshot.data["time"] != null
                          //           documentSnapshot["time"] != null
                          //               ? DateFormat.MMMd('en_US')
                          //             // .add_jm().format(documentSnapshot.data["time"]
                          //               .add_jm().format(documentSnapshot["time"]
                          //               .toDate()).toString()
                          //               : "",
                          //           style: TextStyle(
                          //             color: widget.secondryColor,
                          //             fontSize: 13.0,
                          //             fontWeight: FontWeight.w600,
                          //           ),
                          //         ),
                          //         SizedBox(
                          //           width: 5,
                          //         ),
                          //         // documentSnapshot.data['isRead'] == false
                          //         documentSnapshot['isRead'] == false
                          //             ? Icon(
                          //                 Icons.done,
                          //                 color: widget.secondryColor,
                          //                 size: 15,
                          //               )
                          //             : Icon(
                          //                 Icons.done_all,
                          //                 color: primaryColor,
                          //                 size: 15,
                          //               )
                          //       ],
                          //     ),
                          //   ],
                          // ),
                        ],
                      )),
            ),
          ],
        ),
      ),
    ];
  }

  _messagesIsRead(documentSnapshot, ChatController data) {
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
                  imageUrl: (widget.second.imageUrl.runtimeType == String)?widget.second.imageUrl[0] : widget.second.imageUrl[0]['url'],
                  useOldImageOnUrlChange: true,
                  placeholder: (context, url) => CupertinoActivityIndicator(
                    radius: 15,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            onTap: () async {
              await Get.find<NotificationController>().initRelationPartner(Uid: widget.second.id);
              if(Get.find<NotificationController>().relationUser.inRelationship){
                await Get.find<NotificationController>().initUserPartner(Uid: Get.find<NotificationController>().relationUser.partner.partnerId);
              }
              Get.find<NotificationController>().cekFirstInfo(widget.second);
              showDialog(
                  barrierDismissible: false,
                  context: Get.context,
                  builder: (context) {
                    return Info(widget.second, widget.sender, null, "");
                  });
            } ,
          ),
        ],
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: documentSnapshot['image_url'] != ''
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
                          height: MediaQuery.of(Get.context).size.height * .65,
                          width: MediaQuery.of(Get.context).size.width * .9,
                          imageUrl: documentSnapshot['image_url'] ?? '',
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
                            documentSnapshot["time"] != null
                                ? DateFormat.yMMMd('en_US').add_jm()
                                .format(documentSnapshot["time"]
                                        .toDate())
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
                    Navigator.of(Get.context).push(CupertinoPageRoute(
                      builder: (context) => LargeImage(
                        documentSnapshot['image_url'],
                      ),
                    ));
                  },
                )
              : Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                  width: MediaQuery.of(Get.context).size.width * 0.65,
                  margin: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 10),
                  decoration: BoxDecoration(
                      color: secondryColor.withOpacity(.3),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              documentSnapshot['text'],
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
                            documentSnapshot["time"] != null
                                ? DateFormat.MMMd('en_US')
                                .add_jm()
                                .format(documentSnapshot["time"]
                                .toDate())
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
                  )
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> generateReceiverLayout(DocumentSnapshot documentSnapshot, ChatController data) {
    // if (!documentSnapshot.data['isRead']) {
    if (!documentSnapshot['isRead']) {
      print(documentSnapshot.id);
      chatController.chatReference.doc(documentSnapshot.id).update({
        'isRead': true,
      });

      // return _messagesIsRead(documentSnapshot, data);
    }
    return _messagesIsRead(documentSnapshot, data);
  }

  generateMessages(QuerySnapshot snapshot, ChatController data) {
    return snapshot.docs.map<Widget>((doc) => Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: doc['type'] == "Call" ? [
          Text(doc["time"] != null
            ? "${doc['text']} : " +
              DateFormat.yMMMd('en_US')
                .add_jm()
                .format(doc["time"].toDate())
                .toString() +
              " by ${doc['sender_id'] == widget.sender.id ? "You" : "${widget.second.name}"}"
            : "")
          ]
          // : doc.data['sender_id'] != sender.id
          :doc['type'] == "Disconnect"?[
            if(doc['sender_id'] != widget.sender.id)
            Expanded(
              child:Container(
                padding: EdgeInsets.only(
                  top: 20, bottom: 20,
                  right: 15, left: 15
                ),
                margin: EdgeInsets.only(
                  right: 15, left: 15
                ),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Column(
                  children: [
                    Text(doc['text'],
                    textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                  ],
                )
              )
            ),
            Container()
          ]
          : doc['type'] == "Leave"?[
            (doc['sender_id'] != widget.sender.id)?
            Expanded(
              child:Container(
                padding: EdgeInsets.only(
                  top: 20, bottom: 20,
                  right: 15, left: 15
                ),
                margin: EdgeInsets.only(
                  right: 15, left: 15
                ),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Column(
                  children: [
                    Text(doc['text'],
                    textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                    SizedBox(height: 20,),
                    Text("Leaving the conversation means that this member no longer wants"
                     + " to chat and can't be contacted unless they decide to resume the conversation",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                  ],
                )
              )
            )
            :Expanded(
              child:InkWell(
                onTap:() async{
                  data.restoreLeaveWidget(widget.sender, widget.second, data.listMessageSnapshot.docs.first.id, widget.chatId, "chat");
                },
                child:Container(
                  padding: EdgeInsets.only(
                    top: 20, bottom: 20,
                    right: 15, left: 15
                  ),
                  margin: EdgeInsets.only(
                    right: 15, left: 15
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Column(
                    children: [
                      Text("You have left this chat",
                      textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic
                        ),
                      ),
                      SizedBox(height: 20,),
                      Container(
                        width:150,
                        padding:EdgeInsets.only(
                          left:18, right: 18, top: 12, bottom: 12
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color:Colors.black
                        ),
                        child:Text("Resume chat", 
                          textAlign:TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      )
                    ],
                  )
                )
              )
            )
          ]
          : doc['sender_id'] != widget.sender.id
            ? generateReceiverLayout(doc, data)
            : generateSenderLayout(doc, data)
      ),
      
    )).toList();
  }
  List<Widget> generateChatWidget(var doc, ChatController data){
    if(doc['sender_id'] != widget.sender.id){
      return generateReceiverLayout(doc, data);
    }
    return generateSenderLayout(doc, data);
  }

  Widget getDefaultSendButton(ChatController data) {
    return IconButton(
      icon: Transform.rotate(
        angle: -pi / 9,
        child: Icon(
          Icons.send,
          size: 25,
        ),
      ),
      color: primaryColor,
      onPressed: data.isWritting
          ? () => data.sendText(chatController.textController.text.trimRight(), widget.sender, widget.second)
          : null,
    );
  }

  Widget _buildTextComposer(ChatController data) {
    
    return IconTheme(
        data: IconThemeData(color: data.isWritting ? primaryColor : secondryColor),
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
                      var image = await ImagePicker().pickImage(
                          source: ImageSource.gallery);
                      int timestamp = new DateTime.now().millisecondsSinceEpoch;
                      // StorageReference storageReference = FirebaseStorage
                      //     .instance
                      //     .ref()
                      //     .child('chats/${chatId}/img_' +
                      //         timestamp.toString() +
                      //         '.jpg');
                      // StorageUploadTask uploadTask =
                      //     storageReference.putFile(image);
                      // await uploadTask.onComplete;
                      // String fileUrl = await storageReference.getDownloadURL();
                      if(image != null){
                        FirebaseStorage storage = FirebaseStorage.instance;
                        Reference ref = storage.ref().child('chats/${widget.chatId}/img_'
                            + timestamp.toString() +'.jpg');
                        UploadTask uploadTask = ref.putFile(File(image.path));
                        uploadTask.then((res) async {
                          String fileUrl = await res.ref.getDownloadURL();
                          data.sendImage(messageText: 'Photo', imageUrl: fileUrl, sender: widget.sender, second: widget.second);
                        });
                      }

                    }),
              ),
              new Flexible(
                child: new TextField(
                  controller: chatController.textController,
                  maxLines: 15,
                  minLines: 1,
                  autofocus: false,
                  onChanged: (String messageText) {
                    chatController.isWritting = messageText.trim().length > 0;
                    print("Jalan disini");
                    data.update();
                  },
                  decoration: new InputDecoration.collapsed(
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(18)),
                      hintText: "Send a message..."),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: getDefaultSendButton(data),
              ),
            ],
          ),
        ));
  }



  // await PermissionHandler().requestPermissions(callType == "VideoCall"
  //     ? [PermissionGroup.camera, PermissionGroup.microphone]
  //     : [PermissionGroup.microphone]);
}
