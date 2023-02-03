import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/infrastructure/dal/util/color.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:hookup4u/presentation/notif/controllers/notif.controller.dart';
import 'package:intl/intl.dart';

class AdminNotificationWidget extends GetView<NotifController> {
  const AdminNotificationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Expanded(
        child: StreamBuilder(
            stream: queryCollectionDB('/Users/${Get.find<GlobalController>().currentUser.value?.id}/notification')
                .get()
                .asStream(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              debugPrint("listen userData Successfully- AdminNotification-->");
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return singleItem(snapshot.data.docs[index].data(),index);
                  },
                );
              } else {
                return Center(
                    child: Text(
                  "No Data",
                  style: TextStyle(color: secondryColor, fontSize: 16),
                ));
              }
            }),
      ),
    );
  }

  singleItem(data,index) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: primaryColor.withOpacity(.15)),
      padding:  EdgeInsets.symmetric(vertical:10,horizontal: 15),
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10,top:index==0?10:0 ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title'],
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            data['body'],
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                DateFormat.MMMd('en_US')
                    .add_jm()
                    .format((data['time'] as Timestamp).toDate())
                    .toString(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
