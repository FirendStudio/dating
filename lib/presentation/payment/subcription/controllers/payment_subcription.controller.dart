import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
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
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    streamSubscription?.cancel();
  }

  void initialize() async {
    print("initialize()-------call->${isAvailable.value}");
    isAvailable.value = await iap.isAvailable();
    print("initialize()-------isAvailable->${isAvailable.value}");
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
          await paymentWrapper.finishTransaction(transaction).catchError((onError) {
            print('finishTransaction Error $onError');
          });
        });
      }

      /*    streamSubscription = iap.purchaseStream.listen((data) {
        print("listen--streamSubscription-->$data");
        purchases.assignAll(data);
        purchases.forEach(
          (purchase) async {
            await verifyPuchase(purchase.productID);
          },
        );
      });*/
      var result = await FlutterInappPurchase.instance.initialize();
      print("getPastPurchases========?$result");
      getPastPurchases();
      streamSubscription = iap.purchaseStream.listen((purchaseDetailsList) {
        print("listen--streamSubscription-->$purchaseDetailsList");
        purchases.assignAll(purchaseDetailsList);
        purchases.forEach(
          (purchase) async {
            await verifyPurchase(purchase.productID, false);
          },
        );
      }, onDone: () {
        // streamSubscription?.cancel();
      }, onError: (error) {
        // handle error here.
      });
      /*    streamSubscription?.onError(
        (error) {
          print("purchase.status==error===>streamSubscription=>");

          Global().showInfoDialog(error != null ? error : "Oops !! something went wrong. Try Again");
        },
      );*/
    }
    isLoading.value = false;
  }

  void getPastPurchases() async {
    print('getPastPurchases----calll ---->>>');
    // remove this if you want to restore past purchases in iOS
    if (Platform.isIOS) {
      return;
    }

    List<PurchasedItem>? purchasedItems = await FlutterInappPurchase.instance.getAvailablePurchases();

    // log('purchasedItem 2---->>>${json.decode(purchasedItems.toString())}');

    print('purchasedItem 1---->>>${purchasedItems.toString()}');
    if (purchasedItems!.length > 0) {
      for (var purchasedItem in purchasedItems) {
        bool isValid = false;
        if (Platform.isAndroid) {
          Map map = json.decode(purchasedItem.transactionReceipt!);
          print('getPastPurchases----map ---->>>${map.toString()}');

          print('getPastPurchases------isSubscribe --->>>>${globalController.isPurchased.value}');
          bool cancelOrNot = map['acknowledged'];
          globalController.isPurchased.value = cancelOrNot;
          DateTime now = DateTime.now();

          await globalController.setUpdatePayment(
              uid: globalController.currentUser.value?.id ?? "",
              status: true,
              packageId: purchasedItem.productId ?? "",
              date: DateTime(
                  now.year, now.month + 1, now.day, now.hour, now.minute, now.second, now.millisecond, now.microsecond),
              purchasedId: purchasedItem.transactionId ?? "",
              isFrom: "getPastPurchases");

          print(
              'getPastPurchases globalController.isPurchased.value-----isSubscribe --->>>>${globalController.isPurchased.value}');
        }
      }
    } else {
      log('purchasedItem 1--null-->>>${purchasedItems.toString()}');
    }
  }

  Future<void> getProducts(List<String> _productIds) async {
    print(_productIds.length);
    if (_productIds.length > 0) {
      Set<String> ids = Set.from(["unlimited_no_ads_subscription"]);
      // Set<String> ids = Set.from(_productIds);
      print(ids);
      ProductDetailsResponse response = await iap.queryProductDetails(ids);
      products.value = response.productDetails;
      if (kDebugMode) {
        print("Print Produk");
        print(products.length);
      }
      // products.forEach((element) {});
      print("getProducts==l=>${products.length}");
      selectedProduct.value = products.length > 0 ? products[0] : null;
    }
  }

  Future<List<String>> fetchPackageIds() async {
    List<String> packageId = [];

    QuerySnapshot<Map<String, dynamic>> data =
        await queryCollectionDB("Packages").where('status', isEqualTo: true).get();
    if (data.docs.isNotEmpty) {
      packageId.addAll(data.docs.map((e) => e['id']));
      debugPrint("fetchPackageIds=====>$packageId");
    }
    return packageId;
  }

  Future<void> verifyPurchase(String id, bool isFromPastPurchase) async {
    PurchaseDetails? purchase = hasPurchased(id);
    print("call--verifyPuchase--from $isFromPastPurchase");
    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      print("purchase.status==purchased===>${purchase.status}");
      print("purchase.status=purchased==productID==>${purchase.productID}");
      print("purchase.status==purchased=.error?.messag==>${purchase.error?.message}");
      print("purchase.status==purchased=.verificationData.sourc==>${purchase.verificationData.source}");
      print(
          "purchase.status==purchased=.verificationData.localVerificationDat==>${purchase.verificationData.localVerificationData}");
      print(
          "purchase.status==purchased=.verificationData.serverVerificationDat==>${purchase.verificationData.serverVerificationData}");
      print("purchase.status==purchased=.transactionDate}==>${purchase.transactionDate}");
      print("purchase.status==purchased=.pendingCompletePurchase}==>${purchase.pendingCompletePurchase}");
      print("purchase.status==purchased=.error?.detail==>${purchase.error?.details}");
      print("purchase.status==purchased=.error?.cod==>${purchase.error?.code}");
      print("purchase.status=purchased==productID==>${purchase.productID}");
      // Get.find<GlobalController>().isPurchased.value = true;
      // if (Platform.isIOS) {
      await iap.completePurchase(purchase);
      globalController.isPurchased.value = true;

      DateTime? date;
      var now = new DateTime.now();
      if (purchase.productID == "quarterly_unjabbed") {
        date = DateTime(
            now.year, now.month + 3, now.day, now.hour, now.minute, now.second, now.millisecond, now.microsecond);
      } else if (purchase.productID == "monthly_unjabbed") {
        date = DateTime(
            now.year, now.month + 1, now.day, now.hour, now.minute + 5, now.second, now.millisecond, now.microsecond);
      } else if (purchase.productID == "weekly") {
        date = DateTime.now().add(Duration(days: 7));
        // date = DateTime(now.year, now.month, now.day + 7);
      } else if (purchase.productID == "unjabbed_monthly") {
        date = DateTime(
            now.year, now.month + 2, now.day, now.hour, now.minute, now.second, now.millisecond, now.microsecond);
      } else if (purchase.productID == "unlimited_no_ads_subscription") {
        date = DateTime(
            now.year, now.month, now.day, now.hour, now.minute + 1, now.second, now.millisecond, now.microsecond);
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
          isFrom: "verifyPuchase");
      //}
      if (!isFromPastPurchase) {
        ArtDialogResponse response = await ArtSweetAlert.show(
          context: Get.context!,
          barrierDismissible: false,
          artDialogArgs: ArtDialogArgs(
            confirmButtonText: "Ok",
            type: ArtSweetAlertType.success,
            title: "Confirmation",
            text: "You have now successfully subscribed to our app!",
          ),
        );
        if (response.isTapConfirmButton) {
          Get.offAllNamed(
            Routes.DASHBOARD,
          );
        }
      }
      return;
    } else if (purchase != null && purchase.status == PurchaseStatus.error) {
      print("purchase.status==error===>${purchase.error?.message}");
      print("purchase.status==error===>${purchase.verificationData.source}");
      print("purchase.status==error===>${purchase.verificationData.localVerificationData}");
      print("purchase.status==error===>${purchase.verificationData.serverVerificationData}");
      print("purchase.status==error===>${purchase.transactionDate}");
      print("purchase.status==error===>${purchase.pendingCompletePurchase}");
      print("purchase.status==error===>${purchase.error?.details}");
      print("purchase.status==error===>${purchase.error?.code}");
      print("purchase.status=error==productID==>${purchase.productID}");
      /*
      if (purchase.error?.message == "BillingResponse.itemAlreadyOwned") {
        globalController.isPurchased.value = true;
        Get.back();
      } else {
        await globalController.setUpdatePayment(
            uid: globalController.currentUser.value?.id ?? "",
            packageId: "",
            status: false,
            date: DateTime.now(),
            purchasedId: "",
            isFrom: "PurchaseStatus.canceled");
      }*/
      /*   await globalController.setUpdatePayment(
          uid: globalController.currentUser.value?.id ?? "",
          packageId: "",
          status: false,
          date: DateTime.now(),
          purchasedId: "",
          isFrom: "PurchaseStatus.error");*/
      await Alert(
        context: Get.context!,
        type: AlertType.info,
        title: "subscription",
        desc:
            "It appears that you have already associated this subscription with another account. To activate a free trial subscription on this account, you will need to cancel the current subscription in the Google Play Store.",
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Get.back(),
            width: 120,
          )
        ],
      ).show();
    } else if (purchase != null && purchase.status == PurchaseStatus.canceled) {
      print("purchase.status==canceled===>${purchase.status}");
      print("purchase.status=canceled==productID==>${purchase.productID}");
      await globalController.setUpdatePayment(
          uid: globalController.currentUser.value?.id ?? "",
          packageId: "",
          status: false,
          date: DateTime.now(),
          purchasedId: "",
          isFrom: "PurchaseStatus.canceled");
    } else if (purchase != null && purchase.status == PurchaseStatus.pending) {
      print("purchase.status==pending===>${purchase.status}");
      print("purchase.status=pending==productID==>${purchase.productID}");
    } else if (purchase != null && purchase.status == PurchaseStatus.restored) {
      print("purchase.status==restored===>${purchase.status}");
      print("purchase.status=restored==productID==>${purchase.productID}");
    }
    return;
  }

  PurchaseDetails? hasPurchased(String productId) {
    return purchases.firstWhereOrNull((purchase) => purchase.productID == productId);
  }

  void buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      var resultBuyProduct = await iap.buyNonConsumable(purchaseParam: purchaseParam);
      print("buyProduct---->$resultBuyProduct");
    } catch (e, stack) {
      print("buyProduct---->$e $stack");
      Get.snackbar("Information", "You've already Subcribed");
      return;
    }
  }
}
