import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hookup4u/presentation/auth/register/controllers/auth_register.controller.dart';

import '../../../../infrastructure/dal/util/color.dart';

class UserDOBWidget extends GetView<AuthRegisterController> {
  const UserDOBWidget({super.key});

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
                        "My\nbirthday is",
                        style: TextStyle(fontSize: 40),
                      ),
                      padding: EdgeInsets.only(left: 50, top: 120),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Container(
                    child: ListTile(
                      title: CupertinoTextField(
                        readOnly: true,
                        keyboardType: TextInputType.phone,
                        prefix: IconButton(
                          icon: (Icon(
                            Icons.calendar_today,
                            color: primaryColor,
                          )),
                          onPressed: () {},
                        ),
                        onTap: () => showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * .25,
                              child: GestureDetector(
                                child: CupertinoDatePicker(
                                  backgroundColor: Colors.white,
                                  initialDateTime: DateTime(2000, 10, 12),
                                  onDateTimeChanged: (DateTime newdate) {
                                    controller.dobController.text =
                                        newdate.day.toString() +
                                            '/' +
                                            newdate.month.toString() +
                                            '/' +
                                            newdate.year.toString();
                                    controller.selectedDate = newdate;
                                    controller.update();
                                  },
                                  maximumYear: 2002,
                                  minimumYear: 1800,
                                  maximumDate: DateTime(2002, 03, 12),
                                  mode: CupertinoDatePickerMode.date,
                                ),
                                onTap: () {
                                  print(controller.dobController.text);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        ),
                        placeholder: "DD/MM/YYYY",
                        controller: controller.dobController,
                      ),
                      subtitle: Text(" Your age will be public"),
                    ),
                  ),
                ),
                GetBuilder<AuthRegisterController>(builder: (data) {
                  return data.dobController.text.length > 0
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              onTap: () {
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
