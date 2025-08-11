import 'dart:io';

import 'package:check_in/controllers/subscription_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  ManageSubscriptionScreen({super.key});
  final SubscriptionController subscriptionController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Manage Subscriptions',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Obx(
          () => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subscription Details',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                      )),
                  _subscriptionContainer(
                      context,
                      (subscriptionController.customerInfo.value?.entitlements)
                              ?.active
                              .values
                              .toList() ??
                          []),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Manage Your Subscription',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Click on "Manage Subscription" to ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '• View your active subscriptions.\n'
                    '• Change your payment method.\n'
                    '• Cancel a subscription.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 100,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Please Note:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  RichText(
                    text: TextSpan(
                      text:
                          '• If you cancel your subscription, you will still have access to the service until the end of your current billing period.\n'
                          '• If you have any questions about managing or canceling your subscription, please contact at ',
                      style: TextStyle(
                          height: 2, fontSize: 14, color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'support@checkinhoops.net',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              void _launchEmailApp() async {
                                final Uri params = Uri(
                                  scheme: 'mailto',
                                  path: 'support@checkinhoops.net',
                                  query:
                                      'subject=Contact Us Inquiry&body=Name: ',
                                );

                                final String url = params.toString();
                                bool canLaunch = false;
                                try {
                                  canLaunch = await canLaunchUrl(params);
                                } catch (e) {
                                  print(e);
                                }

                                if (canLaunch) {
                                  await launchUrl(params);
                                } else {
                                  Get.snackbar(
                                      TempLanguage.emailErrorToastTitle,
                                      TempLanguage.emailErrorToastMessage,
                                      backgroundColor: appWhiteColor,
                                      borderWidth: 4,
                                      borderColor: redColor,
                                      colorText: appBlackColor);
                                  print('Could not launch email app.');
                                }
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        if (Platform.isAndroid) {
                          launchUrl(
                              Uri.parse(
                                  'https://play.google.com/store/account/subscriptions?sku=individual&package=com.developlogix.checkinapp'),
                              mode: LaunchMode.externalApplication);
                        } else if (Platform.isIOS) {
                          launchUrl(
                              Uri.parse(
                                  "https://apps.apple.com/account/subscriptions"),
                              mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appGreenColor),
                    child: Text(
                      'Manage Subscription',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // RoundedLoadingButton(
                  //   controller: RoundedLoadingButtonController(),
                  //   onPressed: () async {},
                  //   child: const Text('cancel-subscription').tr(),
                  // ),
                ],
              )),
        ),
      ),
    );
  }

  Container _subscriptionContainer(
      BuildContext context, List<EntitlementInfo> customerInfoList) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(width: 0.3, color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (EntitlementInfo info in customerInfoList)
            ListTile(
                minVerticalPadding: 20,
                leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Image.asset(
                        "assets/images/instagram-verification-badge.png",
                        height: 20,
                        width: 20)),
                title: Text(
                  getProductTitle(subscriptionController
                          .selectedPremiumProduct.value?.identifier ??
                      ""),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                subtitle: RichText(
                  text: TextSpan(
                      text: 'Active'.padRight(8),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blueAccent,
                          ),
                      children: [
                        const TextSpan(text: '('),
                        TextSpan(
                          text:
                              "Expire in ${(DateTime.tryParse(info.expirationDate ?? '') ?? DateTime.now()).difference(DateTime.now()).inDays.toString()} days",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.red),
                        ),
                        const TextSpan(text: ')')
                      ]),
                )),
        ],
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
        return 'Monthly Premium';
      } else if (title.contains('yearly')) {
        return 'Yearly Premium';
      }
      return title;
    }
  }
  // Container _noSubscriptionContainer(BuildContext context) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 20),
  //     decoration: BoxDecoration(
  //       border: Border.all(width: 0.3, color: Colors.blueGrey),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: ListTile(
  //       trailing: const Icon(FeatherIcons.chevronRight),
  //       minVerticalPadding: 20,
  //       leading: CircleAvatar(
  //           backgroundColor: Theme.of(context).primaryColor,
  //           child: Image.asset(premiumImage, height: 20, width: 20)),
  //       title: Text(
  //         'subscribe-to-access-features',
  //         style:
  //             Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
  //       ).tr(),
  //     ),
  //   );
  // }
}
