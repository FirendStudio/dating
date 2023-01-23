import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/Global.dart';
import 'package:hookup4u/presentation/notif/controllers/notif.controller.dart';
import 'package:intl/intl.dart';

import '../../../domain/core/model/user_model.dart';
import '../../../infrastructure/dal/util/color.dart';
import '../../../infrastructure/dal/util/general.dart';

class LikedWidget extends GetView<NotifController> {
  const LikedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.listLikedUser.isEmpty) {
          return Center(
              child: Text(
            "No Liked",
            style: TextStyle(color: secondryColor, fontSize: 16),
          ));
        }

        return Expanded(
          child: ListView.builder(
            itemCount: controller.listLikedUser.length,
            itemBuilder: (BuildContext context, int index) {
              // QueryDocumentSnapshot doc = data.listLikedUser[index];
              var likedUser = controller.listLikedUser[index];

              return InkWell(
                onTap: () async {
                  print(likedUser["LikedBy"]);
                  DocumentSnapshot userdoc = await queryCollectionDB("Users")
                      .doc(likedUser["LikedBy"])
                      .get();
                  if (!userdoc.exists) {
                    Global().showInfoDialog("User doesn't exist");
                    return;
                  }
                  UserModel userModel = UserModel.fromJson(
                      userdoc.data() as Map<String, dynamic>);
                  userModel.relasi.value =
                      await Global().getRelationship(userModel.id);
                  userModel.distanceBW = Global()
                      .calculateDistance(
                        globalController
                                .currentUser.value?.coordinates?['latitude'] ??
                            0,
                        globalController
                                .currentUser.value?.coordinates?['longitude'] ??
                            0,
                        userModel.coordinates?['latitude'] ?? 0,
                        userModel.coordinates?['longitude'] ?? 0,
                      )
                      .round();
                  Global().initProfil(userModel);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: secondryColor.withOpacity(.15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: secondryColor,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                25,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: likedUser['pictureUrl'],
                                fit: BoxFit.cover,
                                useOldImageOnUrlChange: true,
                                placeholder: (context, url) =>
                                    CupertinoActivityIndicator(
                                  radius: 20,
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: ListTile(
                            title: Text(
                              "You are liked by " + likedUser['userName'],
                              style: TextStyle(fontSize: 15),
                            ),
                            subtitle: Text(
                              DateFormat.MMMd('en_US').add_jm().format(
                                    (likedUser['timestamp']).toDate(),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
