import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isMonthlySelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section with background image
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
                        "Subscribe now to get",
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
                          _buildFeatureItem(
                              "Rate courts like a pro - no limits"),
                          SizedBox(height: 0.8.h),
                          _buildFeatureItem(
                              "Snap it. Share it. Own the gallery"),
                          SizedBox(height: 0.8.h),
                          _buildFeatureItem(
                              "Speak your game - leave a comment"),
                          SizedBox(height: 0.8.h),
                          _buildFeatureItem(
                              "Shine bright! Be our Hoop of the Month ⭐"),
                        ],
                      ),

                      SizedBox(height: 3.h),

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
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => isMonthlySelected = true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isMonthlySelected
                                        ? appGreenColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Monthly Plan",
                                      style: TextStyle(
                                        fontFamily: TempLanguage.poppins,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isMonthlySelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => isMonthlySelected = false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !isMonthlySelected
                                        ? appGreenColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Yearly Plan",
                                      style: TextStyle(
                                        fontFamily: TempLanguage.poppins,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: !isMonthlySelected
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

                      SizedBox(height: 2.h),

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
                              "Selected Plan: ${isMonthlySelected ? 'Monthly' : 'Yearly'}",
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
                                  isMonthlySelected
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
                                  isMonthlySelected
                                      ? "Monthly Reset"
                                      : "Yearly Reset",
                                  style: TextStyle(
                                    fontFamily: TempLanguage.poppins,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            if (isMonthlySelected)
                              Row(
                                children: [
                                  Icon(Icons.check,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 2.w),
                                  Text(
                                    "Perfect For Starter",
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
                                onPressed: () {
                                  // Handle purchase
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Buy Now in ${isMonthlySelected ? '1.99\$' : '23.88\$'}",
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
    );
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
