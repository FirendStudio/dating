import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hookup4u/Screens/Home.dart';
import 'package:hookup4u/Screens/Profile/profile.dart';
import 'package:hookup4u/Screens/Splash.dart';
import 'package:hookup4u/Screens/blockUserByAdmin.dart';
import 'package:hookup4u/Screens/notifications.dart';
import '../Controller/TabsController.dart';
import 'Chat/home_screen.dart';
import 'Home.dart';
import 'package:hookup4u/util/color.dart';
// import 'package:easy_localization/easy_localization.dart';


class Tabbar extends StatefulWidget {
  final bool isPaymentSuccess;
  final String plan;
  Tabbar(this.plan, this.isPaymentSuccess);
  @override
  TabbarState createState() => TabbarState();
}

//_
class TabbarState extends State<Tabbar> {

  TabsController tabsController = Get.put(TabsController());

  @override
  void initState() {
    super.initState();
    // Show payment success alert.

    if (widget.isPaymentSuccess != null && widget.isPaymentSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // await Alert(
        //   context: context,
        //   type: AlertType.success,
        //   title: "Confirmation",
        //   desc: "You have successfully subscribed to our",
        //       // .tr(args: ['${widget.plan}']).toString(),
        //   buttons: [
        //     DialogButton(
        //       child: Text(
        //         "Ok",
        //         style: TextStyle(color: Colors.white, fontSize: 20),
        //       ),
        //       onPressed: () => Navigator.pop(context),
        //       width: 120,
        //     )
        //   ],
        // ).show();

        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Confirmation",
                text: "You have now successfully subscribed to our app!"
            )
        );
      });
    }
    tabsController.initAllTab(context);
    // firstLoginApp();
    // _getpastPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TabsController>(builder: (data){
      return WillPopScope(
        onWillPop: () {
          return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Exit'),
                content: Text('Do you want to exit the app?'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () => SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop'),
                    child: Text('Yes'),
                  ),
                ],
              );
            },
          );
        },
        child: Scaffold(
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () async {
          //     await getUserList();
          //   },
          // ),
          body: data.currentUser == null
              ? Center(child: Splash())
              : data.currentUser.isBlocked
              ? BlockUser()
              : DefaultTabController(
            length: 4,
            initialIndex: widget.isPaymentSuccess != null
                ? widget.isPaymentSuccess
                ? 0
                : 1
                : 1,
            child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: primaryColor,
                  automaticallyImplyLeading: false,
                  title: TabBar(
                      labelColor: Colors.white,
                      indicatorColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      isScrollable: false,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(
                          icon: Icon(
                            Icons.person,
                            size: 30,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.whatshot,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.notifications,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.message,
                          ),
                        )
                      ]),
                ),
                body: TabBarView(
                  children: [
                    Center(
                        child: Profile(
                            data.currentUser, data.isPuchased, data.purchases, data.items)),
                    Center(
                        child: CardPictures2(
                            data.currentUser,
                            // data.users,
                            data.swipecount, data.items)),
                    Center(child: Notifications(data.currentUser)),
                    Center(
                        child: HomeScreen(
                            data.currentUser, data.matches, data.newmatches)),
                  ],
                  physics: NeverScrollableScrollPhysics(),
                )),
          ),
        ),
      );
    });

  }
}