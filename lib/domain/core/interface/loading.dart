import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';

Widget loadingWidget(double height, BorderRadius? borderRadius) {
  return Container(
    height: height,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            // topLeft: Radius.circular(50), topRight: Radius.circular(50)
            ),
        color: Colors.white),
    child: Stack(
      children: [
        Center(
          child: customLoadingWidget(text: "Loading ....", color: primaryColor),
        )
      ],
    ),
  );
}

Widget customLoadingWidget({String text = "", Color color = Colors.blue}) {
  return Column(
    children: [
      ClipOval(
          child: SpinKitDoubleBounce(
        color: color,
        size: 50.0,
      )),
      if (text.isNotEmpty)
        SizedBox(
          height: 15,
        ),
      if (text.isNotEmpty)
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontFamily: Global.font,
          ),
        )
    ],
  );
}
