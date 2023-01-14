import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/dal/util/color.dart';
import '../../../infrastructure/dal/util/general.dart';
import 'controllers/payment_details.controller.dart';

class PaymentDetailsScreen extends GetView<PaymentDetailsController> {
  const PaymentDetailsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: Text("Subscription details"),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: primaryColor,
      body: Container(
        height: Get.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(38.0),
                      child: Text(
                        "Payment Summary:",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(
                            "Plan",
                            style: TextStyle(
                              //   color: primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Details",
                            style: TextStyle(
                              fontSize: 15,
                              // color: primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                      rows: [
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                "Transaction_id",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                "${globalController.paymentModel?.purchasedId}",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                "product_id",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                "${globalController.paymentModel?.packageId}",
                                style: TextStyle(
                                  fontSize: 15,
                                  // color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if(globalController.paymentModel?.date != null && globalController.paymentModel!.date!.toIso8601String().isNotEmpty)
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                "Subscribed on",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                DateFormat.MMMd('en_US')
                                    .add_jm()
                                    .format(globalController.paymentModel!.date!),
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                "Status",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                "Active",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  height: 60,
                  width: 250,
                  child: InkWell(
                    child: Card(
                      color: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "Back",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
