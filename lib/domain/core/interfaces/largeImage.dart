import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/interfaces/loading.dart';
import '../../../infrastructure/dal/util/color.dart';

class LargeImage extends StatelessWidget {
  final largeImage;
  LargeImage(this.largeImage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
      ),
      backgroundColor: primaryColor,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CachedNetworkImage(
                    fit: BoxFit.contain,
                    placeholder: (context, url) => loadingWidget(null, null),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    height: Get.height * .75,
                    width: Get.width,
                    imageUrl: largeImage ?? '',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FloatingActionButton(
                      backgroundColor: primaryColor,
                      child: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context)),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
