import 'dart:io';

import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class NavtiveAdsComp extends StatefulWidget {
  const NavtiveAdsComp({super.key});

  @override
  _NativeTestAds createState() => _NativeTestAds();
}

class _NativeTestAds extends State<NavtiveAdsComp> {
  NativeAd? _nativeAd;
  bool _isLoading = true;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-7171017916477454/3594087778'
          : 'ca-app-pub-7171017916477454/4321045773',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('NativeAd loaded.');
          setState(() {
            _isLoading = false;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('NativeAd failedToLoad: $error');
          ad.dispose();
          setState(() {
            _isLoading = false;
            _isAdLoaded = false;
          });
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

  Widget _buildShimmerLoading() {
    return CustomContainer2(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 100.w,
            minHeight: 40.h,
            maxHeight: 40.h,
            maxWidth: 100.w,
          ),
          child: Container(
            color: Colors.white,
            child: Center(
              child: Text(
                'Ad Loading...',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If still loading, show shimmer
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    // If ad is loaded, show the ad
    if (_isAdLoaded && _nativeAd != null) {
      return Center(
        child: Align(
          alignment: Alignment.center,
          child: CustomContainer2(
            child: ClipRRect(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 100.w,
                  minHeight: 40.h,
                  maxHeight: 40.h,
                  maxWidth: 100.w,
                ),
                child: AdWidget(ad: _nativeAd!),
              ),
            ),
          ),
        ),
      );
    }

    // If ad failed to load, return empty space
    return const SizedBox.shrink();
  }
}
