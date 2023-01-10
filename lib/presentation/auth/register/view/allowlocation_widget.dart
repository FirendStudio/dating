import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:hookup4u/presentation/auth/register/controllers/auth_register.controller.dart';

import '../../../../infrastructure/dal/util/Global.dart';
import '../../../../infrastructure/dal/util/color.dart';

class AllowLocationWidget extends GetView<AuthRegisterController> {
  const AllowLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.onBack,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 50),
                child: FloatingActionButton(
                  heroTag: UniqueKey(),
                  elevation: 10,
                  child: IconButton(
                    color: secondryColor,
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: controller.onBack,
                  ),
                  backgroundColor: Colors.white38,
                  onPressed: controller.onBack,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: secondryColor.withOpacity(.2),
                        radius: 110,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 90,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: RichText(
                      text: TextSpan(
                        text: "Enable location",
                        style: TextStyle(color: Colors.black, fontSize: 40),
                        children: [
                          TextSpan(
                              text:
                                  "\nYou'll need to provide a \nlocation\nin order to search users around you.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: secondryColor,
                                  textBaseline: TextBaseline.alphabetic,
                                  fontSize: 18)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(50.0),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            primaryColor.withOpacity(.5),
                            primaryColor.withOpacity(.8),
                            primaryColor,
                            primaryColor
                          ],
                        ),
                      ),
                      height: Get.height * .065,
                      width: Get.width * .75,
                      child: Center(
                        child: Text(
                          "ALLOW LOCATION",
                          style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      try {
                        var currentLocation =
                            await Global().getLocationCoordinates();
                        print(currentLocation);
                        if (currentLocation != null) {
                          controller.selectedCoordinate.value = currentLocation;
                          controller.indexView++;
                          return;
                        }
                        Get.snackbar("Information", "Address not found");
                      } catch (e) {
                        Get.snackbar("Information", e.toString());
                      }
                    },
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
