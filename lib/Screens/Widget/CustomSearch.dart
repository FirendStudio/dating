import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/NotificationController.dart';
import 'package:hookup4u/Controller/TabsController.dart';

import '../../Controller/LoginController.dart';
import '../../util/color.dart';
import '../Tab.dart';

class CustomSearch extends SearchDelegate<String>{

  @override
  List<Widget> buildActions(BuildContext context) {
    // action for app bar
    return[
      IconButton(icon: Icon(Icons.clear), onPressed: (){
        query = "";
      },)
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon of the left of app bar
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation),
      onPressed: (){
        // close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // sow some result based on the selection

    return Text("");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final suggestionSearches = query.isEmpty? []
        : Get.find<TabsController>().users.where((p) => p.name.toLowerCase().startsWith(query)).toList();
    return ListView.builder(itemBuilder: (context, index)=> ListTile(
      onTap: () async {

        print("Test");

        ArtDialogResponse response = await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
              showCancelBtn: true,
              // denyButtonText: "Cancel",
              title: "Do you want to add " + suggestionSearches[index].name + "?",
              confirmButtonText: "Add",
              customColumns: [
                Container(
                  margin: EdgeInsets.only(
                      bottom: 12.0
                  ),
                  child: Image.network(
                    suggestionSearches[index].imageUrl[0]['url'] ?? "",
                    errorBuilder: (context, url, error) =>
                        Icon(Icons.error),
                  ),

                )
              ]
            ),
        );

        if(response==null) {
          return;
        }

        bool cekTap = false;
        if(response.isTapConfirmButton) {
          cekTap = true;
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.success,
                  title: "Success"
              )
          );

          if (Get.find<TabsController>().likedByList.contains(suggestionSearches[index].id)) {
            print("Masuk sini");
            showDialog(
                context: context,
                builder: (ctx) {
                  Future.delayed(
                      Duration(milliseconds: 1700),
                          () {
                        Navigator.pop(ctx);
                      });
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 80),
                    child: Align(
                      alignment:
                      Alignment.topCenter,
                      child: Card(
                        child: Container(
                          height: 100,
                          width: 300,
                          child: Center(
                              child: Text(
                                "It's a match\n With ",
                                textAlign:
                                TextAlign.center,
                                style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 30,
                                    decoration:
                                    TextDecoration
                                        .none),
                              )
                            // .tr(args: ['${widget.users[index].name}']),
                          ),
                        ),
                      ),
                    ),
                  );
                });
            print(Get.find<LoginController>().userId);
            print(suggestionSearches[index].id);
            await Get.find<NotificationController>().docReference
                .doc(Get.find<LoginController>().userId)
                .collection("Matches")
                .doc(suggestionSearches[index].id)
                .set(
                {
                  'Matches': suggestionSearches[index].id,
                  'isRead': false,
                  'userName': suggestionSearches[index].name,
                  'pictureUrl': suggestionSearches[index].imageUrl[0]['url'] ?? "",
                  'timestamp': FieldValue.serverTimestamp()
                },
                SetOptions(merge : true)
            );
            await Get.find<NotificationController>().docReference
                .doc(suggestionSearches[index].id)
                .collection("Matches")
                .doc(Get.find<LoginController>().userId)
                .set(
                {
                  'Matches': Get.find<LoginController>().userId,
                  'userName': suggestionSearches[index].name,
                  'pictureUrl': (Get.find<TabsController>().currentUser.imageUrl[0].runtimeType == String)?Get.find<TabsController>().currentUser.imageUrl[0] : Get.find<TabsController>().currentUser.imageUrl[0]['url'],
                  'isRead': false,
                  'timestamp': FieldValue.serverTimestamp()
                },
                SetOptions(merge : true)
            );
          }

          await Get.find<NotificationController>().docReference
              .doc(Get.find<LoginController>().userId)
              .collection("CheckedUser")
              .doc(suggestionSearches[index].id)
              .set(
              {
                'userName': suggestionSearches[index].name,
                'pictureUrl': suggestionSearches[index].imageUrl[0]['url'] ?? "",
                'LikedUser': suggestionSearches[index].id,
                'timestamp':
                FieldValue.serverTimestamp(),
              },
              SetOptions(merge : true)
          );
          await Get.find<NotificationController>().docReference
              .doc(suggestionSearches[index].id)
              .collection("LikedBy")
              .doc(Get.find<LoginController>().userId)
              .set(
              {
                'userName': suggestionSearches[index].name,
                'pictureUrl': suggestionSearches[index].imageUrl[0]['url'] ?? "",
                'LikedBy': Get.find<LoginController>().userId,
                'timestamp':
                FieldValue.serverTimestamp()
              },
              SetOptions(merge : true)
          );

          bool cek = false;
          int cekIndex = 0;
          print("loop");
          for(int index=0; index <=Get.find<TabsController>().users.length-1; index++){
            print("start loop");
            if(Get.find<TabsController>().users[index].id == suggestionSearches[index].id){
              cekIndex = index;
              cek = true;
              print("stop lop");
              break;
            }

          }
          // listLikedUser.removeAt(indexNotif);
          // update();
          if(!cek){
            return;
          }
          Get.find<TabsController>().userRemoved.clear();
          Get.find<TabsController>().userRemoved.add(Get.find<TabsController>().users[cekIndex]);
          Get.find<TabsController>().users.removeAt(cekIndex);
          Get.find<TabsController>().update();
          await Future.delayed(Duration(seconds: 2));
          Get.back();
          Get.back();
          return;
        }

      },
      leading: Icon(Icons.person_add),
      title: RichText(
        text: TextSpan(
            text: suggestionSearches[index].name,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            // children: [
            //   TextSpan(
            //       text: suggestionSearches[index].name,
            //       style: TextStyle(color: Colors.grey)
            //   )
            // ]
        ),
      ),
    ),
      itemCount: suggestionSearches.length,

    );
  }

}