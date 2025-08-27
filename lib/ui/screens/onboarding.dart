import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/ui/screens/subscription_screen.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    // Main illustration area - Responsive height
                    Container(
                      height:
                          constraints.maxHeight * 0.56, // 56% of screen height
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Image.asset(
                                'assets/images/onboarding_bg.png',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 4.w, top: 1.h),
                              child: TextButton(
                                onPressed: _completeOnboarding,
                                child: Text(
                                  "Skip",
                                  style: TextStyle(
                                    fontFamily: TempLanguage.poppins,
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Text content section - Responsive
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        children: [
                          SizedBox(height: 2.h),

                          // Welcome text - responsive
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Welcome ",
                                  style: TextStyle(
                                    fontFamily: TempLanguage.poppins,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: appGreenColor,
                                  ),
                                ),
                                TextSpan(
                                  text: "to\nthe Check In Hoops Courts Report",
                                  style: TextStyle(
                                    fontFamily: TempLanguage.poppins,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 1.h),

                          // Feature titles - compact
                          Text(
                            "Share photos and videos",
                            style: TextStyle(
                              fontFamily: TempLanguage.poppins,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              color: appGreenColor,
                            ),
                          ),

                          SizedBox(height: 0.5.h),

                          Text(
                            "Leave ratings and reviews",
                            style: TextStyle(
                              fontFamily: TempLanguage.poppins,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          SizedBox(height: 1.h),

                          // Description - compact
                          Text(
                            "Explore court side views from other hoopers",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: TempLanguage.poppins,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // Get Started button
                          Container(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SubscriptionScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appGreenColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                "Buy Premium and Get Started",
                                style: TextStyle(
                                  fontFamily: TempLanguage.poppins,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
