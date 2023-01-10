import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hookup4u/presentation/auth/register/controllers/auth_register.controller.dart';
import '../../../../infrastructure/dal/util/color.dart';

class UsernameWidget extends GetView<AuthRegisterController> {
  const UsernameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => controller.onBack(),
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 50),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: FloatingActionButton(
              elevation: 10,
              child: IconButton(
                color: secondryColor,
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => controller.onBack(),
              ),
              backgroundColor: Colors.white38,
              onPressed: () => controller.onBack(),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Padding(
                      child: Text(
                        "My username is",
                        style: TextStyle(fontSize: 40),
                      ),
                      padding: EdgeInsets.only(left: 50, top: 120),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      Container(
                        child: TextFormField(
                          controller: controller.usernameController,
                          style: TextStyle(fontSize: 23),
                          decoration: InputDecoration(
                            hintText: "Enter your username",
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor)),
                            // helperText: "This is the name others member will see on the App",
                            // helperStyle:
                            // TextStyle(color: secondryColor, fontSize: 15),
                          ),
                          onChanged: (value) {
                            controller.update();
                            // setState(() {
                            //   username = value;
                            // });
                          },
                        ),
                      ),
                      Text(
                        "This is the name others members will see on the App.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            // fontStyle: FontStyle.normal,
                            color: secondryColor),
                      )
                    ],
                  ),
                ),
                GetBuilder<AuthRegisterController>(builder: (data) {
                  return data.usernameController.text.length > 0
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 40),
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
                                height:
                                    MediaQuery.of(context).size.height * .065,
                                width: MediaQuery.of(context).size.width * .75,
                                child: Center(
                                  child: Text(
                                    "CONTINUE",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                // controller.dataUser.addAll({
                                //   'UserName': "${controller.usernameController}"
                                // });
                                // if (kDebugMode) {
                                //   print(controller.dataUser);
                                // }
                                controller.indexView.value++;
                              },
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * .065,
                                width: MediaQuery.of(context).size.width * .75,
                                child: Center(
                                  child: Text(
                                    "CONTINUE",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: secondryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                        );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
