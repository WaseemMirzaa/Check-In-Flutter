
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
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
    if (kDebugMode) {
      print('URL: $completeUrl');
    }
    ApiResponse response = await DioHelper.postRawData(completeUrl, params);
    if (response.body != null) {
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> mapData = json.decode(response.body);

      return mapData;
    } else {
      log('Stripe Response: ${response.body}--');
      return null;
    }
  }

  static Future<void> initPaymentSheet({required int amount, required String customerId, required void Function(bool result) callback}) async {
    try {
      final data = await createPaymentSheet(amount: amount, customerId: customerId);

      var customer = data?['customer'] ?? '';
      var paymentIntent = data?['paymentIntent'] ?? '';
      var clientSecret = data?['clientSecret'] ?? '';
      var ephemeralKey = data?['ephemeralKey'] ?? '';


      if (clientSecret.isNotEmpty) {
        // await Stripe.instance.initPaymentSheet(
        //   paymentSheetParameters: SetupPaymentSheetParameters(
        //     paymentIntentClientSecret: clientSecret,
        //     merchantDisplayName: 'Check In',
        //     customerId: customer,
        //     applePay: const PaymentSheetApplePay(
        //       merchantCountryCode: 'US',
        //     ),
        //     googlePay: const PaymentSheetGooglePay(
        //       currencyCode: 'USD',
        //       merchantCountryCode: 'US',
        //     ),
        //     customerEphemeralKeySecret: ephemeralKey,
        //     style: ThemeMode.dark,
        //   ),
        // );
        // await Stripe.instance.presentPaymentSheet();
        callback(true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception $e');
      }
      toast('Something went wrong. Try again later');
    }
  }
}