import 'package:growthbook_sdk_flutter/growthbook_sdk_flutter.dart';
import 'uptech_growthbook_wrapper_test_client.dart';

/// Thin wrapper around the GrowthBookSDK to facilitate both
/// live client and stubbed out client for use case in
/// automated testing.
class UptechGrowthBookWrapper {
  UptechGrowthBookWrapper({required this.apiKey});
  final String apiKey;
  late GrowthBookSDK _client;

  /// Initialize for use in app
  void init() {
    _client = _createLiveClient(apiKey);
  }

  /// Initialize for use in automated test suite
  void initForTests({Map<String, bool>? seeds}) {
    _client = _createTestClient(seeds: seeds);
  }

  /// Force a refresh of toggles from the server
  Future<void> refresh() async {
    return _client.refresh();
  }

  /// Check if a feature is on/off
  bool isOn(String featureId) {
    return _client.feature(featureId).on ?? false;
  }

  GrowthBookSDK _createLiveClient(String apiKey) {
    return GBSDKBuilderApp(
      apiKey: apiKey,
      hostURL: 'https://cdn.growthbook.io/',
      growthBookTrackingCallBack: (gbExperiment, gbExperimentResult) {},
    ).initialize();
  }

  GrowthBookSDK _createTestClient({Map<String, bool>? seeds}) {
    final gbContext = GBContext(
      apiKey: 'some-garbage-key-because-we-are-not-using-it',
      hostURL: 'https://cdn.growthbook.io/',
      trackingCallBack: (gbExperiment, gbExperimentResult) {},
    );
    return GrowthBookSDK(
      context: gbContext,
      client: UptechGrowthBookWrapperTestClient(seeds: seeds),
      features: _seedsToGBFeatures(seeds: seeds),
    );
  }

  Map<String, GBFeature> _seedsToGBFeatures({Map<String, bool>? seeds}) {
    if (seeds != null) {
      return seeds
          .map((key, value) => MapEntry(key, GBFeature(defaultValue: value)));
    } else {
      return {};
    }
  }
}
