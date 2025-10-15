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
        elevation: 0,
        title: const Text(
          'Manage Subscriptions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(
        () {
          final customerInfoList =
              (subscriptionController.customerInfo.value?.entitlements)
                      ?.active
                      .values
                      .toList() ??
                  [];
          final hasActiveSubscription = customerInfoList.isNotEmpty;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subscription Status Card
                  _buildSubscriptionStatusCard(
                      context, customerInfoList, hasActiveSubscription),

                  const SizedBox(height: 15),

                  // Quick Actions Section
                  if (hasActiveSubscription) ...[
                    _buildQuickActionsSection(context),
                    const SizedBox(height: 15),
                  ],

                  // Information Section
                  _buildInformationCard(context),

                  const SizedBox(height: 15),

                  // Important Notes
                  _buildImportantNotes(context),

                  const SizedBox(height: 15),

                  // Manage Subscription Button
                  _buildManageButton(context, hasActiveSubscription),

                  const SizedBox(height: 16),

                  // Support Contact
                  _buildSupportContact(context),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Subscription Status Card
  Widget _buildSubscriptionStatusCard(BuildContext context,
      List<EntitlementInfo> customerInfoList, bool hasActiveSubscription) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: hasActiveSubscription
              ? LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasActiveSubscription
                      ? Icons.check_circle
                      : Icons.info_outline,
                  color: hasActiveSubscription ? Colors.green : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasActiveSubscription
                        ? 'Active Subscription'
                        : 'No Active Subscription',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (hasActiveSubscription) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...customerInfoList
                  .map((info) => _buildSubscriptionItem(context, info)),
            ] else ...[
              const SizedBox(height: 12),
              const Text(
                'Subscribe to unlock premium features and enjoy an enhanced experience.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionItem(BuildContext context, EntitlementInfo info) {
    final daysRemaining =
        (DateTime.tryParse(info.expirationDate ?? '') ?? DateTime.now())
            .difference(DateTime.now())
            .inDays;
    final isExpiringSoon = daysRemaining <= 7;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExpiringSoon ? Colors.orange : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              "assets/images/instagram-verification-badge.png",
              height: 24,
              width: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getProductTitle(subscriptionController
                          .selectedPremiumProduct.value?.identifier ??
                      ""),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Expires in $daysRemaining days',
                        style: TextStyle(
                          color: isExpiringSoon ? Colors.orange : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpiringSoon)
            Icon(Icons.warning_amber, color: Colors.orange, size: 20),
        ],
      ),
    );
  }

  // Quick Actions Section
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.payment,
                title: 'Payment',
                subtitle: 'Update method',
                onTap: () => _launchSubscriptionManagement(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.receipt_long,
                title: 'Billing',
                subtitle: 'View history',
                onTap: () => _launchSubscriptionManagement(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Information Card
  Widget _buildInformationCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'How to Manage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.visibility,
              text: 'View your active subscriptions',
            ),
            _buildInfoItem(
              icon: Icons.payment,
              text: 'Change your payment method',
            ),
            _buildInfoItem(
              icon: Icons.cancel_outlined,
              text: 'Cancel a subscription',
            ),
            _buildInfoItem(
              icon: Icons.upgrade,
              text: 'Upgrade or downgrade your plan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Important Notes
  Widget _buildImportantNotes(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.priority_high, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Important Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNoteItem(
              '• Canceling your subscription maintains access until the end of your current billing period.',
            ),
            _buildNoteItem(
              '• Changes to your subscription take effect immediately.',
            ),
            _buildNoteItem(
              '• Refunds are subject to the app store\'s refund policy.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade800,
          height: 1.4,
        ),
      ),
    );
  }

  // Manage Button
  Widget _buildManageButton(BuildContext context, bool hasActiveSubscription) {
    return ElevatedButton(
      onPressed: _launchSubscriptionManagement,
      style: ElevatedButton.styleFrom(
        backgroundColor: appGreenColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            hasActiveSubscription
                ? 'Manage Subscription'
                : 'View Subscription Options',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Support Contact
  Widget _buildSupportContact(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Need help? Contact us at\n',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          children: [
            TextSpan(
              text: 'support@checkinhoops.net',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
              recognizer: TapGestureRecognizer()..onTap = _launchEmailApp,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  void _launchSubscriptionManagement() {
    try {
      if (Platform.isAndroid) {
        launchUrl(
          Uri.parse(
              'https://play.google.com/store/account/subscriptions?sku=individual&package=com.developlogix.checkinapp'),
          mode: LaunchMode.externalApplication,
        );
      } else if (Platform.isIOS) {
        launchUrl(
          Uri.parse("https://apps.apple.com/account/subscriptions"),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to open subscription management',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      print('Error launching subscription management: $e');
    }
  }

  void _launchEmailApp() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'support@checkinhoops.net',
      query: 'subject=Subscription Support&body=',
    );

    try {
      final canLaunch = await canLaunchUrl(params);
      if (canLaunch) {
        await launchUrl(params);
      } else {
        Get.snackbar(
          TempLanguage.emailErrorToastTitle,
          TempLanguage.emailErrorToastMessage,
          backgroundColor: appWhiteColor,
          borderWidth: 2,
          borderColor: redColor,
          colorText: appBlackColor,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to open email app',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      print('Error launching email: $e');
    }
  }

  String getProductTitle(String title) {
    if (Platform.isAndroid) {
      if (title.contains('monthly')) {
        return 'Monthly Premium';
      } else if (title.contains('yearly')) {
        return 'Yearly Premium';
      }
      return title.isNotEmpty ? title : 'Premium';
    } else {
      if (title.contains('monthly')) {
        return 'Monthly Premium';
      } else if (title.contains('yearly')) {
        return 'Yearly Premium';
      }
      return title.isNotEmpty ? title : 'Premium';
    }
  }
}
