import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/purchase_history.dart';
import 'package:check_in/model/subscription.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';

class FirebaseService {
  static final firestore = FirebaseFirestore.instance;
  Future updateSubscription(String userId, Subscription subscription) async {
    final DocumentReference ref =
        firestore.collection(Collections.USER).doc(userId);
    final data = Subscription.toMap(subscription);
    await ref.update({'subscription': data});
  }

  Future savePurchaseHistory(UserModel user, PurchaseHistory history) async {
    final Map<String, dynamic> data = PurchaseHistory.getMap(history);
    final DocumentReference ref = firestore.collection('purchases').doc();
    await ref.set(data);
  }

  static void updateCustomerInfo(CustomerInfo customerInfo) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference ref =
        FirebaseFirestore.instance.collection(Collections.USER).doc(userId);
    List<Subscription> activeSubscriptions = [];
    List<Subscription> allSubscriptions = [];
    for (var subscription in customerInfo.entitlements.active.values) {
      Subscription subs = Subscription(
          plan: subscription.identifier,
          purchaseAt: subscription.latestPurchaseDate,
          expireAt: subscription.expirationDate ?? '',
          productId: subscription.productIdentifier,
          store: subscription.store.name,
          isActive: subscription.isActive,
          sandBox: subscription.isSandbox,
          wilRenew: subscription.willRenew);
      activeSubscriptions.add(subs);
    }
    for (var subscription in customerInfo.entitlements.all.values) {
      Subscription subs = Subscription(
          plan: subscription.identifier,
          purchaseAt: subscription.latestPurchaseDate,
          expireAt: subscription.expirationDate ?? '',
          productId: subscription.productIdentifier,
          store: subscription.store.name,
          isActive: subscription.isActive,
          sandBox: subscription.isSandbox,
          wilRenew: subscription.willRenew);

      allSubscriptions.add(subs);
    }
    Map<String, dynamic> data = {
      'active_subscriptions':
          activeSubscriptions.map((e) => Subscription.toMap(e)).toList(),
      'all_subscriptions':
          allSubscriptions.map((e) => Subscription.toMap(e)).toList()
    };
    ref.update(data);
  }
}
