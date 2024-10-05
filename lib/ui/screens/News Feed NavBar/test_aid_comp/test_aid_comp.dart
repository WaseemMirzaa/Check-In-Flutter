import 'dart:io';

import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';

class NavtiveAdsComp extends StatefulWidget {
  const NavtiveAdsComp({super.key});

  @override
  _NativeTestAds createState() => _NativeTestAds();
}

class _NativeTestAds extends State<NavtiveAdsComp> {
  NativeAd? _nativeAd;
  RxBool _nativeAdIsLoaded = false.obs; // use obs to make reactive

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create the ad objects and load ads.
    _nativeAd = NativeAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-7171017916477454/3594087778'
          : 'ca-app-pub-7171017916477454/4321045773',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('NativeAd loaded.');
          _nativeAdIsLoaded.value = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('NativeAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('NativeAd onAdClosed.'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white12,
        callToActionTextStyle: NativeTemplateTextStyle(
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black38,
          backgroundColor: Colors.white70,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Align(
        alignment: Alignment.center,
        child: Obx(() //handle through getx obx
            {
          return _nativeAdIsLoaded.value
              ? CustomContainer1(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 100.w,
                        minHeight: 50.h,
                        maxHeight: 50.h,
                        maxWidth: 100.w,
                      ),
                      child: AdWidget(ad: _nativeAd!),
                    ),
                  ),
                )
              : const SizedBox.shrink(); // Display nothing when ad isn't loaded
        }),
      ),
    );
  }
}
