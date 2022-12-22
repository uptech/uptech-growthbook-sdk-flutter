import 'package:growthbook_sdk_flutter/growthbook_sdk_flutter.dart';

/// A client to be stubbed into GrowthBookSDK to return explicitly
/// configured toggle states for automated tests.
class UptechGrowthBookWrapperTestClient extends BaseClient {
  UptechGrowthBookWrapperTestClient({this.seeds, this.rules});

  final Map<String, bool>? seeds;
  final List<Map<String, dynamic>>? rules;

  @override
  consumeGetRequest(String path, OnSuccess onSuccess, OnError onError) async {
    final Map<String, dynamic> data = {
      'status': 200,
      'features': _seedsToHashFeatures(seeds, rules),
      'dateUpdated': DateTime.now(),
    };
    onSuccess(data);
  }

  Map<String, dynamic> _seedsToHashFeatures(
      Map<String, bool>? seeds, List<Map<String, dynamic>>? rules) {
    final Map<String, dynamic> emptyFeatures = {};
    if (seeds != null) {
      return seeds.map((key, value) {
        return MapEntry(key, {'defaultValue': value, 'rules': rules ?? []});
      });
    } else {
      return emptyFeatures;
    }
  }
}
