import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';

class TestAdisInteg extends StatefulWidget {
  const TestAdisInteg({super.key});

  @override
  State<TestAdisInteg> createState() => _TestAdisIntegState();
}

class _TestAdisIntegState extends State<TestAdisInteg> {

  bool isBannerLoaded = false;
  late BannerAd bannerAd;

  initializeBannerAd() async{
    bannerAd = BannerAd(size: AdSize.banner, adUnitId: 'ca-app-pub-9186158101020180/1628016986', listener: BannerAdListener(onAdLoaded: (ad){
      setState(() {
        isBannerLoaded = true;
      });
    },onAdFailedToLoad: (ad, error){
      ad.dispose();
      isBannerLoaded=false;
      print(error);
    }), request: AdRequest());
    bannerAd.load();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(height: 100.h,width: 100.w,child: isBannerLoaded == true ? AdWidget(ad: bannerAd) : SizedBox()),
    );
  }
}
