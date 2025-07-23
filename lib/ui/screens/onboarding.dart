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
        child: Column(
          children: [
            // Skip button

            // Main illustration area - Larger, minimal margin
            Expanded(
              flex: 7,
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
                ],
              ),
            ),

            // Text content section - Compact spacing
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Welcome text - compact
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
                            text: "to\nCheck In Hoops Courts Page",
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

                    // Feature titles - tight spacing
                    Text(
                      "View the Court Images",
                      style: TextStyle(
                        fontFamily: TempLanguage.poppins,
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: appGreenColor,
                      ),
                    ),

                    Text(
                      "Rate The Court",
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
                      "Fill Up Court Gallery with your amazing photos and get a chance to win Hoop of the month for the court.",
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
                                    const SubscriptionScreen()),
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
                  ],
                ),
              ),
            ),

            // Minimal bottom spacing
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }
}
