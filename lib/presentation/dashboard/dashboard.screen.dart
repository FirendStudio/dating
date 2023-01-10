import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/controller/global_controller.dart';
import 'package:hookup4u/presentation/dashboard/widget/blockuser_widget.dart';
import 'package:hookup4u/presentation/screens.dart';

import '../../infrastructure/dal/util/color.dart';
import 'controllers/dashboard.controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.onBack,
      child: Obx(
        () => Scaffold(
          body: Get.find<GlobalController>().currentUser.value == null
              ? Center(
                  child: Container(
                    height: 120,
                    width: 200,
                    child: Image.asset(
                      "asset/hookup4u-Logo-BP.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : Get.find<GlobalController>().currentUser.value!.isBlocked
                  ? BlockUserWidget()
                  : DefaultTabController(
                      length: 4,
                      initialIndex: 1,
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
                            ],
                          ),
                        ),
                        body: TabBarView(
                          children: [
                            // Center(
                            //   child: Profile(
                            //     data.currentUser,
                            //     data.isPuchased,
                            //     data.purchases,
                            //     data.items,
                            //   ),
                            // ),
                            Center(
                              child: HomeScreen(),
                            ),
                            // Center(
                            //     child: CardPictures2(
                            //         data.currentUser,
                            //         // data.users,
                            //         data.swipecount,
                            //         data.items)),
                            Center(
                              child: HomeScreen(),
                            ),
                            // Center(child: Notifications(data.currentUser)),
                            Center(
                              child: HomeScreen(),
                            ),
                            Center(
                              child: HomeScreen(),
                            ),
                          ],
                          physics: NeverScrollableScrollPhysics(),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
