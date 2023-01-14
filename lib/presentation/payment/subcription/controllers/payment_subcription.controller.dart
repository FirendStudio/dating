import 'dart:async';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../../infrastructure/dal/util/Global.dart';

class PaymentSubcriptionController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isAvailable = false.obs;
  InAppPurchase iap = InAppPurchase.instance;

  RxList<ProductDetails> products = RxList();
  RxList<PurchaseDetails> purchases = RxList();
  Rxn<ProductDetails> selectedProduct = Rxn();
  StreamSubscription? streamSubscription;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    streamSubscription?.cancel();
  }

  void initialize() async {
    isAvailable.value = await iap.isAvailable();
    print(isAvailable.value);
    if (isAvailable.value) {
      List<Future> futures = [
        getProducts(await fetchPackageIds()),
        //_getpastPurchases(false),
      ];
      await Future.wait(futures);
      // print(futures);

      /// removing all the pending puchases.
      if (Platform.isIOS) {
        var paymentWrapper = SKPaymentQueueWrapper();
        var transactions = await paymentWrapper.transactions();
        transactions.forEach((transaction) async {
          print(transaction.transactionState);
          await paymentWrapper
              .finishTransaction(transaction)
              .catchError((onError) {
            print('finishTransaction Error $onError');
          });
        });
      }

      streamSubscription = iap.purchaseStream.listen((data) {
        print(purchases);
        purchases.assignAll(data);
        purchases.forEach(
          (purchase) async {
            await verifyPuchase(purchase.productID);
          },
        );
      });
      streamSubscription?.onError(
        (error) {
          Global().showInfoDialog(error != null
              ? error
              : "Oops !! something went wrong. Try Again");
        },
      );
    }
    isLoading.value = false;
  }

  Future<void> getProducts(List<String> _productIds) async {
    print(_productIds.length);
    if (_productIds.length > 0) {
      Set<String> ids = Set.from(_productIds);
      print(ids);
      ProductDetailsResponse response = await iap.queryProductDetails(ids);
      products.value = response.productDetails;
      if (kDebugMode) {
        print("Print Produk");
        print(products.length);
      }
      // products.forEach((element) {});

      selectedProduct.value = products.length > 0 ? products[0] : null;
    }
  }

  Future<List<String>> fetchPackageIds() async {
    List<String> packageId = [];

    QuerySnapshot<Map<String, dynamic>> data =
        await queryCollectionDB("Packages")
            .where('status', isEqualTo: true)
            .get();
    if (data.docs.isNotEmpty) {
      packageId.addAll(data.docs.map((e) => e['id']));
    }
    return packageId;
  }

  Future<void> verifyPuchase(String id) async {
    PurchaseDetails? purchase = hasPurchased(id);
    print(purchase?.status);
    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      print(purchase.productID);

      // if (Platform.isIOS) {
      await iap.completePurchase(purchase);
      DateTime? date;
      var now = new DateTime.now();
      if (purchase.productID == "quarterly_unjabbed") {
        date = DateTime(now.year, now.month + 3, now.day);
      } else if (purchase.productID == "monthly_unjabbed") {
        date = DateTime(now.year, now.month + 1, now.day);
      } else if (purchase.productID == "weekly") {
        date = DateTime(now.year, now.month, now.day + 7);
      }
      print("Masuk Sini");
      if (date == null) {
        Global().showInfoDialog("Package not Found");
        return;
      }
      await globalController.setUpdatePayment(
        uid: globalController.currentUser.value?.id ?? "",
        status: true,
        packageId: purchase.productID,
        date: date,
        purchasedId: purchase.purchaseID ?? "",
      );
      //}
      ArtDialogResponse response = await ArtSweetAlert.show(
        context: Get.context!,
        artDialogArgs: ArtDialogArgs(
          confirmButtonText: "Ok",
          type: ArtSweetAlertType.success,
          title: "Confirmation",
          text: "You have now successfully subscribed to our app!",
        ),
      );
      if (response.isTapConfirmButton) {
        Get.offAllNamed(Routes.DASHBOARD);
      }
      return;
    } else if (purchase != null && purchase.status == PurchaseStatus.error) {
      await Alert(
        context: Get.context!,
        type: AlertType.error,
        title: "Failed",
        desc: "Oops !! something went wrong. Try Again",
        buttons: [
          DialogButton(
            child: Text(
              "Retry",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Get.back(),
            width: 120,
          )
        ],
      ).show();
    }
    return;
  }

  PurchaseDetails? hasPurchased(String productId) {
    return purchases
        .firstWhereOrNull((purchase) => purchase.productID == productId);
  }

  void buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      await iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print(e);
      Get.snackbar("Information", "You've already Subcribed");
      return;
    }
  }
}
