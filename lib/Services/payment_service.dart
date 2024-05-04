
import 'dart:convert';
import 'dart:developer';

import 'package:check_in/auth_service.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nb_utils/nb_utils.dart';

import 'dio_config.dart';

class PaymentService {

  static Future<String> createStripeCustomer({required String email}) async {
    String params = DioHelper.getJsonString({"email": email});
    String completeUrl = '${DioHelper.baseURL}createStripeCustomer';
    dynamic response = await DioHelper.postRawData(completeUrl, params);
    if (response.body != null) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return data["customerId"];
    } else {
      return '';
    }
  }

  static Future<Map<String, dynamic>?> createPaymentSheet(
      {required int amount, required String customerId}) async {
    String params = DioHelper.getJsonString({
      "amount": amount,
      "customerId": customerId,
    });

    var completeUrl = '${DioHelper.baseURL}initPaymentSheet';

    ApiResponse response = await DioHelper.postRawData(completeUrl, params);
    if (response.body != null) {
      Map<String, dynamic> mapData = json.decode(response.body);
      return mapData;
    } else {
      log('Stripe Response: ${response.body}--');
      throw Exception();
    }
  }

  static Future<void> initPaymentSheet({required BuildContext context, required int amount, required String customerId}) async {
    try {
      final data = await createPaymentSheet(amount: amount, customerId: customerId);

      var customer = data?['customer'] ?? '';
      var paymentIntent = data?['paymentIntent'] ?? '';
      var clientSecret = data?['clientSecret'] ?? '';
      var ephemeralKey = data?['ephemeralKey'] ?? '';


      if (clientSecret.isNotEmpty) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Check In',
            customerId: customer,
            applePay: const PaymentSheetApplePay(
              merchantCountryCode: 'US',
            ),
            googlePay: const PaymentSheetGooglePay(
              currencyCode: 'USD',
              merchantCountryCode: 'US',
            ),
            customerEphemeralKeySecret: ephemeralKey,
            style: ThemeMode.dark,
          ),
        );
        await Stripe.instance.presentPaymentSheet();

        showConfirmDialogCustom(
          context,
          barrierDismissible: false,
          cancelable: false,
          title: 'You are now officially verified, enjoy the blue check!',
          dialogType: DialogType.ACCEPT,
          positiveText: 'Ok',
          onAccept: (ctx){
            Navigator.pop(ctx);
            Navigator.pop(context);
          },
          onCancel: (ctx){
            Navigator.pop(ctx);
            Navigator.pop(context);
          }
        );

        await FirebaseFirestore.instance.collection(Collections.USER).doc(FirebaseAuth.instance.currentUser?.uid ?? '')
        .update({'isVerified': true,});
        userController.userModel.value.copyWith(isVerified: true);
      }
    } catch (e) {
      showConfirmDialogCustom(
        context,
        barrierDismissible: false,
        cancelable: false,
        title: 'Something went wrong. Try again later',
        dialogType: DialogType.RETRY,
        positiveText: 'Ok',
        onAccept: (ctx){
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
        onCancel: (ctx){
          Navigator.pop(ctx);
          Navigator.pop(context);
        }
      );
    }
  }
}