import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:growthbook_sdk_flutter/growthbook_sdk_flutter.dart';
import 'uptech_growthbook_wrapper_test_client.dart';

Future<Map<String, dynamic>> loadOverridesFromAssets(String assetsPath) async {
  try {
    final json = await rootBundle.loadString(assetsPath, cache: false);
    return jsonDecode(json);
  } catch (e) {
    return {};
  }
}

/// Thin wrapper around the GrowthBookSDK to facilitate both
/// live client and stubbed out client for use case in
/// automated testing.
class UptechGrowthBookWrapper {
  UptechGrowthBookWrapper({required this.apiKeyUrl});

  late GrowthBookSDK _client;
  final String apiKeyUrl;
  final Map<String, dynamic> _overrides = {};
  final Map<String, dynamic> _attributes = {};

  /// Initialize for use in app, seeds allow you to specify value of
  /// toggles prior to fetching remote toggle states. These will be
  /// the values if on init it fails to fetch the toggles from the remote.
  void init(
      {Map<String, dynamic>? seeds,
      Map<String, dynamic>? overrides,
      Map<String, dynamic>? attributes}) {
    _overrides.clear();
    _attributes.clear();
    if (overrides != null) {
      _overrides.addAll(overrides);
    }
    if (attributes != null) {
      _attributes.addAll(attributes);
    }
    _client = _createLiveClient(apiKeyUrl: apiKeyUrl, seeds: seeds);
  }

  /// Initialize for use in automated test suite
  void initForTests(
      {Map<String, dynamic>? seeds,
      Map<String, dynamic>? overrides,
      Map<String, dynamic>? attributes,
      List<Map<String, dynamic>>? rules}) {
    _overrides.clear();
    _attributes.clear();
    if (overrides != null) {
      _overrides.addAll(overrides);
    }
    if (attributes != null) {
      _attributes.addAll(attributes);
    }
    _client = _createTestClient(seeds: seeds, rules: rules);
  }

  /// Force a refresh of toggles from the server
  Future<void> refresh() async {
    return await _client.refresh();
  }

  void setAttributes(Map<String, dynamic> attributes) {
    if (_client.context.attributes != null) {
      _client.context.attributes?.addEntries(attributes.entries);
    } else {
      _client.context.attributes = attributes;
    }
  }

  /// Check if a feature is on/off
  bool isOn(String featureId) {
    final hasOverride = _overrides.containsKey(featureId);

    if (hasOverride) {
      final value = _overrides[featureId];
      return value == true;
    }

    return _client.feature(featureId).on ?? false;
  }

  /// Return the value of a feature.
  /// If the feature does not have a value configured, returns null.
  dynamic value(String featureId) {
    final hasOverride = _overrides.containsKey(featureId);

    if (hasOverride) {
      return _overrides[featureId];
    }

    return _client.feature(featureId).value;
  }

  GrowthBookSDK _createLiveClient({
    required String apiKeyUrl,
    required Map<String, dynamic>? seeds,
  }) {
    final dividingIndex = apiKeyUrl.lastIndexOf('/');
    final apiKey = apiKeyUrl.substring(dividingIndex + 1);
    final hostURL = apiKeyUrl.substring(0, dividingIndex);
    final gbContext = GBContext(
      apiKey: apiKey,
      enabled: true,
      qaMode: false,
      attributes: _attributes,
      hostURL: hostURL,
      forcedVariation: <String, int>{},
      trackingCallBack: (gbExperiment, gbExperimentResult) {},
    );
    return GrowthBookSDK(
      context: gbContext,
      features: _seedsToGBFeatures(seeds: seeds),
    );
  }

  GrowthBookSDK _createTestClient(
      {Map<String, dynamic>? seeds, List<Map<String, dynamic>>? rules}) {
    final gbContext = GBContext(
      apiKey: 'some-garbage-key-because-we-are-not-using-it',
      hostURL: 'https://cdn.growthbook.io/',
      attributes: _attributes,
      trackingCallBack: (gbExperiment, gbExperimentResult) {},
    );
    return GrowthBookSDK(
      context: gbContext,
      client: UptechGrowthBookWrapperTestClient(seeds: seeds, rules: rules),
      features: _seedsToGBFeatures(seeds: seeds),
    );
  }

  Map<String, GBFeature> _seedsToGBFeatures({Map<String, dynamic>? seeds}) {
    if (seeds != null) {
      return seeds
          .map((key, value) => MapEntry(key, GBFeature(defaultValue: value)));
    } else {
      return {};
    }
  }
}
