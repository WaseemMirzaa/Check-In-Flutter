import 'dart:async';

import 'package:check_in/Services/firebase_service.dart';
import 'package:check_in/core/constant/subscription_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionController extends GetxController {
  // Loading state
  final RxBool isLoading = false.obs;

  // Customer info stream
  final Rx<CustomerInfo?> customerInfo = Rx<CustomerInfo?>(null);
  StreamSubscription<CustomerInfo>? _customerInfoSubscription;

  // Selected products
  final Rx<StoreProduct?> selectedPremiumProduct = Rx<StoreProduct?>(null);

  // Available products
  final RxList<StoreProduct> premiumProducts = <StoreProduct>[].obs;

  // Loading states for products
  final RxBool isPremiumProductsLoading = false.obs;

  // Error states
  final RxString premiumProductsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCustomerInfoStream();
    fetchPremiumProducts();
  }

  @override
  void onClose() {
    _customerInfoSubscription?.cancel();
    super.onClose();
  }

  // Initialize customer info stream
  void _initializeCustomerInfoStream() {
    if (FirebaseAuth.instance.currentUser != null) {
      Purchases.addCustomerInfoUpdateListener((info) {
        customerInfo.value = info;
        FirebaseService.updateCustomerInfo(info);
      });
    }
  }

  // Select Premium product
  void selectPremiumProduct(StoreProduct product) {
    selectedPremiumProduct.value = product;
  }

  // Fetch Premium products
  Future<void> fetchPremiumProducts() async {
    try {
      isPremiumProductsLoading.value = true;
      premiumProductsError.value = '';

      List<StoreProduct> availableProducts = await Purchases.getProducts(
          SubscriptionConstants.premiumProductIds());

      availableProducts.sort((a, b) => a.price.compareTo(b.price));

      premiumProducts.value = availableProducts;

      if (kDebugMode) {
        print('Premium products: $availableProducts');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Platform exception fetching Premium products: $e');
      }
      premiumProductsError.value = 'Error fetching products';
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching premium products: $e');
      }
      premiumProductsError.value = 'Error fetching products';
    } finally {
      isPremiumProductsLoading.value = false;
    }
  }

  // Refresh all products
  Future<void> refreshProducts() async {
    await Future.wait([
      fetchPremiumProducts(),
    ]);
  }

  // Purchase a product
  Future<PurchaseResult?> purchaseProduct(StoreProduct product) async {
    try {
      isLoading.value = true;
      PurchaseResult purchaseInfo =
          await Purchases.purchase(PurchaseParams.storeProduct(product));
      return purchaseInfo;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        if (kDebugMode) {
          print('Purchase error: $e');
        }
        // Handle other errors
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Purchase error: $e');
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Restore purchases
  Future<CustomerInfo?> restorePurchases() async {
    try {
      isLoading.value = true;
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Restore purchases error: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Restore purchases error: $e');
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Get current customer info
  Future<CustomerInfo?> getCurrentCustomerInfo() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      this.customerInfo.value = customerInfo;
      return customerInfo;
    } catch (e) {
      if (kDebugMode) {
        print('Get customer info error: $e');
      }
      return null;
    }
  }

  // Check if user has active subscription for a product
  Future<bool> hasActiveSubscription(String productId) async {
    await getCurrentCustomerInfo();
    final info = customerInfo.value;
    if (info == null) return false;

    return info.entitlements.active.containsKey(productId);
  }

  // Check if user has any active Premium subscription
  bool hasActivePremiumSubscription() {
    CustomerInfo? info = customerInfo.value;

    if (info == null) {
      return false;
    } else {
      List<EntitlementInfo> activeEntitlements =
          info.entitlements.active.values.toList();
      return activeEntitlements.isNotEmpty;
    }
  }

  // Get active subscriptions
  List<String> getActiveSubscriptions() {
    final info = customerInfo.value;
    if (info == null) return [];

    return info.entitlements.active.keys.toList();
  }

  // Clear selected products
  void clearSelectedProducts() {
    selectedPremiumProduct.value = null;
  }

  // Purchase selected Premium product
  Future<PurchaseResult?> purchaseSelectedPremiumProduct() async {
    final product = selectedPremiumProduct.value;
    if (product == null) return null;

    return await purchaseProduct(product);
  }

  // Helper getters
  bool get hasPremiumProducts => premiumProducts.isNotEmpty;
  bool get hasPremiumProductsError => premiumProductsError.value.isNotEmpty;
  bool get hasSelectedPremiumProduct => selectedPremiumProduct.value != null;
}
