import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hookup4u/infrastructure/dal/util/general.dart';
import 'package:hookup4u/infrastructure/navigation/routes.dart';

bool isNonPersonalizedAds = false;

Random random = Random();

String get interstitialAdUnitId {
  if (Platform.isAndroid) {
    return "ca-app-pub-9920967673222897/6754332183";
    // return 'ca-app-pub-3940256099942544/1033173712';

  } else if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/4411468910';
  } else {
    throw UnsupportedError("Unsupported platform");
  }
}

class InterstitalAd {
  static bool isReadyToShowAd = true;
  static bool firstAdShowDelayed = true;
  static InterstitialAd? _interstitialAd;
  static RewardedInterstitialAd? _rewardedInterstitialAd;

  static Future<void> loadInterstitialAd() async {
    if (_interstitialAd == null) {
      print("adsCount=====>${globalController.adsCount.value}");
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: new AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('ads=====>$ad loaded');
            _interstitialAd = ad;
            showInterstitialAd();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('ads=====>InterstitialAd failed to load: $error');
            globalController.adsCount.value = 0;
            _interstitialAd = null;
          },
        ),
      );
    }
    //_createRewardedInterstitialAd();
  }

  static void createRewardedInterstitialAd() {
    if (_rewardedInterstitialAd == null) {
      RewardedInterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/5354046379',
        request: AdRequest(nonPersonalizedAds: isNonPersonalizedAds),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('$ad loaded.');

            _rewardedInterstitialAd = ad;
            showInterstitialAd();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');

            _rewardedInterstitialAd = null;
          },
        ),
      );
    }
  }

  static Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          print('ads=====>ad onAdShowedFullScreenContent.');
          globalController.adsCount.value = 0;
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('ads=====>$ad onAdDismissedFullScreenContent : route : ');
          globalController.adsCount.value = 0;
          Get.toNamed(Routes.DASHBOARD);
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('ads=====>$ad onAdFailedToShowFullScreenContent: $error : route : ');
          globalController.adsCount.value = 0;
          Get.toNamed(Routes.DASHBOARD);
        },
        onAdClicked: (ad) async {
          print("ads=====>ad onAdClicked");
          globalController.adsCount.value = 0;
          Get.toNamed(Routes.DASHBOARD);
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }
}
