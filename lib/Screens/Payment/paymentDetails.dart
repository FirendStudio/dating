import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hookup4u/util/color.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentDetails extends StatelessWidget {
  final List<PurchaseDetails> purchases;
  PaymentDetails(this.purchases);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Subscription details".tr().toString()),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: primaryColor,
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)),
                color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(38.0),
                        child: Text("Payment Summary:".tr().toString(),
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 23)),
                      ),
                    ]),
                    purchases.length > 0
                        ? ListView(
                            scrollDirection: Axis.vertical,
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            children: purchases
                                .map((index) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columns: [
                                            DataColumn(
                                                label: Text(
                                              "Plan".tr().toString(),
                                              style: TextStyle(
                                                //   color: primaryColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )),
                                            DataColumn(
                                                label: Text("Details".tr().toString(),
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      // color: primaryColor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ))),
                                          ],
                                          rows: [
                                            DataRow(cells: [
                                              DataCell(Text("Transaction_id",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ))),
                                              DataCell(
                                                  Text("${index.purchaseID}",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ))),
                                            ]),
                                            DataRow(cells: [
                                              DataCell(Text("product_id",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ))),
                                              DataCell(
                                                  Text("${index.productID}",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        // color: primaryColor,
                                                      ))),
                                            ]),
                                            DataRow(cells: [
                                              DataCell(Text("Subscribed on".tr().toString(),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ))),
                                              DataCell(Text(
                                                  DateTime.fromMillisecondsSinceEpoch(
                                                          int.parse(index
                                                              .transactionDate))
                                                      .toLocal()
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    // color: primaryColor,
                                                  ))),
                                            ]),
                                            DataRow(cells: [
                                              DataCell(Text("Status".tr().toString(),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ))),
                                              DataCell(Text(
                                                  index.billingClientPurchase
                                                          .isAutoRenewing
                                                      ? "Active".tr().toString()
                                                      : "Cancelled".tr().toString(),
                                                  style: TextStyle(
                                                    color: index
                                                            .billingClientPurchase
                                                            .isAutoRenewing
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontSize: 15,
                                                  ))),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          )
                        : Center(
                            child: CircularProgressIndicator(),
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
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                              child: Text(
                            "Back".tr().toString(),
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          )),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
