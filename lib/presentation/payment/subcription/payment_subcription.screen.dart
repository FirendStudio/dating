import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';
import 'package:hookup4u/domain/core/interfaces/loading.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../infrastructure/dal/util/Global.dart';
import '../../../infrastructure/dal/util/color.dart';
import '../../../infrastructure/dal/util/general.dart';
import 'controllers/payment_subcription.controller.dart';

class PaymentSubcriptionScreen extends GetView<PaymentSubcriptionController> {
  const PaymentSubcriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20, right: 20),
                alignment: Alignment.topRight,
                child: IconButton(
                  alignment: Alignment.topRight,
                  color: Colors.black,
                  icon: Icon(
                    Icons.cancel,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ListTile(
                        dense: true,
                        title: Text(
                          "Get our premium plans",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.star,
                          color: Colors.blue,
                        ),
                        title: Text(
                          "Unlimited swipes!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.star,
                          color: Colors.green,
                        ),
                        title: Text(
                          "No restriction on distance!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.star,
                          color: Colors.green,
                        ),
                        title: Text(
                          "Unlimited connections and chat!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                            height: 100,
                            width: MediaQuery.of(context).size.width * .85,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Swiper(
                                key: UniqueKey(),
                                curve: Curves.linear,
                                autoplay: true,
                                physics: ScrollPhysics(),
                                itemBuilder: (BuildContext context, int index2) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            listAdds[index2]["icon"],
                                            color: listAdds[index2]["color"],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            listAdds[index2]["title"],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        listAdds[index2]["subtitle"],
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  );
                                },
                                itemCount: listAdds.length,
                                pagination: new SwiperPagination(
                                  alignment: Alignment.bottomCenter,
                                  builder: DotSwiperPaginationBuilder(
                                    activeSize: 10,
                                    color: secondryColor,
                                    activeColor: primaryColor,
                                  ),
                                ),
                                control: new SwiperControl(
                                  size: 20,
                                  color: primaryColor,
                                  disableColor: secondryColor,
                                ),
                                loop: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      controller.isLoading.value
                          ? Container(
                              height: Get.width * .8,
                              child: loadingWidget(Get.width * .8, null),
                            )
                          : controller.products.isNotEmpty
                              ? getProduct(
                                  context: context,
                                  product: controller.products.first,
                                  interval: getInterval(controller.products.first),
                                  intervalCount: "1",
                                  price: controller.products.first.price,
                                )
                              : Container(
                                  height: MediaQuery.of(context).size.width * .8,
                                  child: Center(
                                    child: Text("No active product found!!"),
                                  ),
                                ),
                      SizedBox(
                        height: 20,
                      ),
                      /* controller.isLoading.value
                          ? Container(
                              height: Get.width * .8,
                              child: loadingWidget(Get.width * .8, null),
                            )
                          : controller.products.isNotEmpty
                              ? Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Transform.rotate(
                                        angle: -pi / 2,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .16,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .8,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 2,
                                                  color: primaryColor)),
                                          child: Center(
                                            child: (CupertinoPicker(
                                              squeeze: 1.4,
                                              looping: true,
                                              magnification: 1.08,
                                              offAxisFraction: -.2,
                                              backgroundColor: Colors.white,
                                              scrollController:
                                                  FixedExtentScrollController(
                                                      initialItem: 0),
                                              itemExtent: 100,
                                              onSelectedItemChanged: (value) {
                                                controller
                                                        .selectedProduct.value =
                                                    controller.products[value];
                                              },
                                              children: controller.products
                                                  .map((product) {
                                                String duration = "0";
                                                if (product.id ==
                                                    "monthly_unjabbed") {
                                                  duration = "1";
                                                } else if (product.id ==
                                                    "quarterly_unjabbed") {
                                                  duration = "3";
                                                } else if (product.id ==
                                                    "weekly") {
                                                  duration = "1";
                                                } else {
                                                  duration = "0";
                                                }
                                                return Transform.rotate(
                                                  angle: pi / 2,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        productList(
                                                          context: context,
                                                          product: product,
                                                          interval: getInterval(
                                                            product,
                                                          ),
                                                          intervalCount:
                                                              duration,
                                                          price: product.price,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            )),
                                          ),
                                        ),
                                      ),
                                    ),
                                    controller.selectedProduct.value != null
                                        ? Center(
                                            child: ListTile(
                                              title: Text(
                                                controller.selectedProduct.value
                                                        ?.title ??
                                                    '',
                                                textAlign: TextAlign.center,
                                              ),
                                              subtitle: Text(
                                                controller.selectedProduct.value
                                                        ?.description ??
                                                    '',
                                                textAlign: TextAlign.center,
                                              ),
                                              trailing: Text(
                                                  "${controller.products.indexOf(controller.selectedProduct.value) + 1}/${controller.products.length}"),
                                            ),
                                          )
                                        : Container()
                                  ],
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.width * .8,
                                  child: Center(
                                    child: Text("No active product found!!"),
                                  ),
                                )*/
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
                      height: Get.height * .055,
                      width: Get.width * .55,
                      child: Center(
                        child: Text(
                          "CONTINUE",
                          style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onTap: () async {
                      // print(selectedProduct);
                      // return;
                      controller.selectedProduct.value = controller.products.first;
                      if (controller.selectedProduct.value != null)
                        controller.buyProduct(controller.selectedProduct.value!);
                      else {
                        Global().showInfoDialog(
                          "You must choose a subscription to continue.",
                        );
                      } /*  if (controller.selectedProduct.value != null)
                        controller
                            .buyProduct(controller.selectedProduct.value!);
                      else {
                        Global().showInfoDialog(
                          "You must choose a subscription to continue.",
                        );
                      }*/
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GestureDetector(
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () => launchUrlString(
                        "https://jablesscupid.com/privacy-policy/",
                      ),
                    ),
                    GestureDetector(
                      child: Text(
                        "Terms & Conditions",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () => launchUrlString(
                        "https://jablesscupid.com/terms-conditions/",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getInterval(ProductDetails product) {
    if (product.id == "monthly_unjabbed") {
      return "Month(s)";
    } else if (product.id == "quarterly_unjabbed") {
      return "Month(s)";
    } else if (product.id == "weekly") {
      return "Week(s)";
    } else if (product.id == "unlimited_no_ads_subscription") {
      return "Month(s)";
    } else {
      return "Year(s)";
    }
  }

  Widget productList({
    required BuildContext context,
    required String intervalCount,
    required String interval,
    required ProductDetails product,
    required String price,
  }) {
    return AnimatedContainer(
      curve: Curves.easeIn,
      height: 100,
      //setting up dimention if product get selected
      width: controller.selectedProduct.value != product //setting up dimention if product get selected
          ? Get.width * .19
          : Get.width * .22,
      decoration: controller.selectedProduct.value == product
          ? BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(width: 2, color: primaryColor),
            )
          : null,
      duration: Duration(milliseconds: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height * .02),
          Text(
            intervalCount,
            style: TextStyle(
              color: controller.selectedProduct.value != product ? Colors.black : primaryColor,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            interval,
            style: TextStyle(
              color: controller.selectedProduct.value != product ? Colors.black : primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: controller.selectedProduct.value != product ? Colors.black : primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget getProduct({
    required BuildContext context,
    required String intervalCount,
    required String interval,
    required ProductDetails product,
    required String price,
  }) {
    return Container(
      height: 80, //setting up dimention if product get selected
      width: 150,
      decoration: controller.selectedProduct.value == product
          ? BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(width: 2, color: primaryColor),
            )
          : null,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // SizedBox(height: MediaQuery.of(context).size.height * .02),
          Text(
            intervalCount,
            style: TextStyle(
              color: controller.selectedProduct.value != product ? Colors.black : primaryColor,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            interval,
            style: TextStyle(
              color: controller.selectedProduct.value != product ? Colors.black : primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: controller.selectedProduct.value != product ? Colors.black : primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
