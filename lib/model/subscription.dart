import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String plan, productId, purchaseAt, expireAt, store;
  bool isActive, sandBox, wilRenew;

  Subscription({
    required this.plan,
    required this.purchaseAt,
    required this.expireAt,
    required this.productId,
    required this.store,
    required this.isActive,
    required this.sandBox,
    required this.wilRenew,
  });

  factory Subscription.fromFirestore(Map<String, dynamic> d) {
    return Subscription(
        plan: d['plan'] ?? '',
        purchaseAt: d['purchased_at'] ?? '',
        expireAt: d['end_at'] ?? '',
        productId: d['product_id'] ?? '',
        store: d['store'] ?? '',
        isActive: d['is_active'] ?? false,
        sandBox: d['sandbox'] ?? false,
        wilRenew: d['will_renew'] ?? false);
  }

  static Map<String, dynamic> toMap(Subscription d) {
    return {
      'plan': d.plan,
      'purchased_at': d.purchaseAt,
      'end_at': d.expireAt,
      'product_id': d.productId,
      'store': d.store,
      'is_active': d.isActive,
      'sandbox': d.sandBox,
      'will_renew': d.wilRenew,
    };
  }
}

class SubscriptionPlan {
  final String id;
  final String title;
  final String description;
  final String price;
  final String period;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.period,
    this.isPopular = false,
  });
}
