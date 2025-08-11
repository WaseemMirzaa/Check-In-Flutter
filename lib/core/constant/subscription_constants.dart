import 'dart:io';

class SubscriptionConstants {
  static const List<String> kPremierProductIdsAndroid = <String>[
    'monthly-premium',
    'yearly-premium',
  ];

  // Premier product ids for iOS (Apple AppStore)
  static const List<String> kPremierProductIdsiOS = <String>[
    'monthly_premium',
    'yearly_premium',
  ];

  static List<String> premiumProductIds() {
    if (Platform.isAndroid) {
      return [
        'premium',
        'yearly-premium',
      ];
    } else if (Platform.isIOS) {
      return [
        'checkin_monthly_pro',
        'checkin_yearly_pro',
      ];
    } else {
      return [];
    }
  }

  static final String _revenueCatApiKeyAndroid =
      'goog_mzxPLkMkEUxfbEblxQSseSTSIco';
  static final String _revenueCatApiKeyIOS = 'appl_SYTKBkJRWFCuYSovCrINwphLAJj';

  static String get revenueCatApiKey =>
      Platform.isAndroid ? _revenueCatApiKeyAndroid : _revenueCatApiKeyIOS;
}
