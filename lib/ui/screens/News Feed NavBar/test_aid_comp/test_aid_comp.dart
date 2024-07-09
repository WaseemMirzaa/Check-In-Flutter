import 'dart:io';

import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';

class NativeTestAds extends StatefulWidget {
  const NativeTestAds({super.key});

  @override
  _NativeTestAds createState() => _NativeTestAds();
}

class _NativeTestAds extends State<NativeTestAds> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create the ad objects and load ads.
    _nativeAd = NativeAd(
      adUnitId: Platform.isAndroid ?  'ca-app-pub-7171017916477454/3594087778' : 'ca-app-pub-7171017916477454/4321045773',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('NativeAd loaded.');
          setState(() {
            _nativeAdIsLoaded = true;
          });
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
        child: _nativeAdIsLoaded ? CustomContainer1(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 300,
                minHeight: 350,
                maxHeight: 400,
                maxWidth: 450,
              ),
              child: _nativeAdIsLoaded
                  ? AdWidget(ad: _nativeAd!)
                  : const SizedBox.shrink(), // Show loading indicator while ad is loading
            ),
          ),
        ) : const SizedBox.shrink(),
      ),
    );
  }
}
