import 'dart:async';
import 'dart:io';

import 'package:check_in/controllers/subscription_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/purchase_result.dart';
import 'package:purchases_flutter/models/store_product_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';

class SubscriptionScreen extends StatefulWidget {
  SubscriptionScreen({super.key, this.isFromOnboarding = false});
  bool isFromOnboarding;
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // bool isMonthlySelected = true;

  SubscriptionController subscriptionController =
      Get.put(SubscriptionController());
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await subscriptionController.fetchPremiumProducts();
        if (subscriptionController.premiumProducts.isNotEmpty) {
          subscriptionController.selectPremiumProduct(
              subscriptionController.premiumProducts.first);
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Obx(
        () => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header section with background image
                Stack(
                  children: [
                    Container(
                      height: 50.h, // Fixed height for image section
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/subscription_bg.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    if (widget.isFromOnboarding)
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: TextButton(
                            onPressed: _completeOnboarding,
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                fontFamily: TempLanguage.poppins,
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!widget.isFromOnboarding)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: Container(
                            decoration: BoxDecoration(
                                color: appGreenColor, shape: BoxShape.circle),
                            child: TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Icon(
                                  Icons.arrow_back_ios_new_outlined,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ),
                  ],
                ),

                // Content section
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Subscribers now get to",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: TempLanguage.poppins,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: appGreenColor,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Features list
                        Column(
                          children: [
                            _buildFeatureItem("Rate courts like a pro"),
                            SizedBox(height: 0.8.h),
                            _buildFeatureItem(
                                "Snap it and share it to the gallery"),
                            SizedBox(height: 0.8.h),
                            _buildFeatureItem(
                                "Share your thoughts and write up a comment"),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Plan selection toggle
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              for (StoreProduct product
                                  in subscriptionController.premiumProducts)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      subscriptionController
                                          .selectPremiumProduct(product);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: subscriptionController
                                                    .selectedPremiumProduct
                                                    .value
                                                    ?.identifier ==
                                                product.identifier
                                            ? appGreenColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          getProductTitle(product.identifier),
                                          style: TextStyle(
                                            fontFamily: TempLanguage.poppins,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: subscriptionController
                                                        .selectedPremiumProduct
                                                        .value
                                                        ?.identifier ==
                                                    product.identifier
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10),

                        // Selected plan details
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: appGreenColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Selected Plan: ${getProductTitle(subscriptionController.selectedPremiumProduct.value?.identifier ?? "")}",
                                style: TextStyle(
                                  fontFamily: TempLanguage.poppins,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Icon(Icons.check,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 2.w),
                                  Text(
                                    (subscriptionController
                                                    .selectedPremiumProduct
                                                    .value
                                                    ?.identifier ??
                                                "")
                                            .contains('monthly')
                                        ? "Valid for 30 days"
                                        : "Valid for 365 days",
                                    style: TextStyle(
                                      fontFamily: TempLanguage.poppins,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Icon(Icons.check,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 2.w),
                                  Text(
                                    (subscriptionController
                                                    .selectedPremiumProduct
                                                    .value
                                                    ?.identifier ??
                                                "")
                                            .contains('monthly')
                                        ? "Monthly Reset - Perfect For Starter"
                                        : "Yearly Reset",
                                    style: TextStyle(
                                      fontFamily: TempLanguage.poppins,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 2.h),

                              // Buy Now button
                              Container(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (subscriptionController
                                        .hasSelectedPremiumProduct) {
                                      PurchaseResult? data =
                                          await subscriptionController
                                              .purchaseProduct(
                                                  subscriptionController
                                                      .selectedPremiumProduct
                                                      .value!);
                                      if (data != null) {
                                        Get.to(() => Home());
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "Buy now",
                                    style: TextStyle(
                                      fontFamily: TempLanguage.poppins,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (Platform.isIOS) ...[
                          SizedBox(
                            height: 5,
                          ),
                          TextButton(
                              child: const Text('Restore Purchase'),
                              onPressed: () async {
                                try {
                                  CustomerInfo customerInfo =
                                      await Purchases.restorePurchases();
                                } on PlatformException catch (e) {
                                  Fluttertoast.showToast(
                                      msg: e.message ??
                                          'Error restoring purchases');
                                  // Error restoring purchases
                                } catch (e) {
                                  Fluttertoast.showToast(
                                      msg: 'Error restoring purchases');
                                } finally {}
                              }),
                        ],
                        SizedBox(
                            height: 4.h), // Extra bottom padding for scrolling
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getProductTitle(String title) {
    if (Platform.isAndroid) {
      if (title.contains('monthly')) {
        return 'Monthly';
      } else if (title.contains('yearly')) {
        return 'Yearly';
      }
      return title;
    } else {
      if (title.contains('monthly')) {
        return 'Monthly';
      } else if (title.contains('yearly')) {
        return 'Yearly';
      }
      return title;
    }
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.3.h),
          child: Icon(
            Icons.check,
            color: appGreenColor,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
