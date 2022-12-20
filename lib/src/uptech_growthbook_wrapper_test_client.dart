import 'package:growthbook_sdk_flutter/growthbook_sdk_flutter.dart';

/// A client to be stubbed into GrowthBookSDK to return explicitly
/// configured toggle states for automated tests.
class UptechGrowthBookWrapperTestClient extends BaseClient {
  UptechGrowthBookWrapperTestClient({this.seeds});

  final Map<String, dynamic>? seeds;

  @override
  consumeGetRequest(String path, OnSuccess onSuccess, OnError onError) async {
    final Map<String, dynamic> data = {
      'status': 200,
      'features': _seedsToHashFeatures(seeds),
      'dateUpdated': DateTime.now(),
    };
    onSuccess(data);
  }

  Map<String, dynamic> _seedsToHashFeatures(Map<String, dynamic>? seeds) {
    final Map<String, dynamic> emptyFeatures = {};
    if (seeds != null) {
      return seeds.map((key, value) => MapEntry(key, {'defaultValue': value}));
    } else {
      return emptyFeatures;
    }
  }
}
