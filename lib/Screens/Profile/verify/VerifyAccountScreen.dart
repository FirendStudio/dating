import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Controller/TabsController.dart';
import 'package:hookup4u/Controller/VerifyProfileController.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import '../../../Controller/WelcomeController.dart';
// import 'package:easy_localization/easy_localization.dart';

class VerifyAccountScreen extends StatelessWidget {
  final UserModel currentUser = Get.find<TabsController>().currentUser;
  // VerifyAccountScreen(this.currentUser);
  var welcomeController = Get.put(WelcomeController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyProfileController>(builder: (data){
      return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          title: Text(
            "Phone number settings",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: Container(
          width: Get.width,
          decoration: BoxDecoration(
              // borderRadius: BorderRadius.only(
              //     topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: RichText(
                  text: TextSpan(
                    text: "Verification Status : ",
                    style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                      TextSpan(
                        text: (currentUser.verified == 0)?"Unverified" : "Verified",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: (currentUser.verified == 0)?Colors.red:Colors.greenAccent
                        )
                      ),
                    ]
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  left:15.0, right: 15, bottom: 5, top: 10),
                child: Text("To get verified we will send you a code which you will need to write down on a A4 sheet of paper.")
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left:15.0, right: 15, bottom: 5, top: 10),
                child: Text("Please make sure that the numbers are written in large font and can easily be seen.")
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left:15.0, right: 15, bottom: 5, top: 10),
                child: Text("You will then take a selfie displaying your face alongside the sheet of paper.")
              ),

              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: ListTile(
                  leading:(currentUser.phoneNumber.isEmpty)?Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: primaryColor),
                      ),
                    ),
                    child: CountryCodePicker(
                      onChanged: (value) {
                        data.countryCode = value.dialCode;
                      },
                      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                      initialSelection: 'IN',
                      favorite: [data.countryCode, 'IN'],
                      // optional. Shows only country name and flag
                      showCountryOnly: false,
                      // optional. Shows only country name and flag when popup is closed.
                      showOnlyCountryWhenClosed: false,
                      // optional. aligns the flag and the Text left
                      alignLeft: false,
                    ),
                  ):null,
                  title: Container(
                    child: TextFormField(
                      enabled: (currentUser.phoneNumber.isNotEmpty)?false:true,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: 20),
                      cursorColor: primaryColor,
                      controller: data.phoneNumController,
                      onChanged: (value) {
                        data.cont = true;
                        data.update();
                      },
                      decoration: InputDecoration(
                        hintText: "Enter your number",
                        hintStyle: TextStyle(fontSize: 18),
                        focusColor: primaryColor,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor)),
                      ),
                    ),
                  )
                )
              ),

              Center(
                child: InkWell(
                  onTap: (){
                    bool updateNumber = false;
                    // Navigator.push(
                    //     context,
                    //     CupertinoPageRoute(
                    //         builder: (context) => OTP(updateNumber)));
                  },
                  child: Container(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      child: Center(
                        child: Text("Send me the verification code",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                // fontFamily: Global.font,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)
                        ),
                      )
                  )
                ),
              )
              

              
            ],
          ),
        ),
      );
    });
  }
}
