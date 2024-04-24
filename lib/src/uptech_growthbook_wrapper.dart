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
  UptechGrowthBookWrapper({required this.apiHost, required this.clientKey});

  late GrowthBookSDK _client;
  final String apiHost;
  final String clientKey;
  final Map<String, dynamic> _overrides = {};
  final Map<String, dynamic> _attributes = {};

  /// Initialize for use in app, seeds allow you to specify value of
  /// toggles prior to fetching remote toggle states. These will be
  /// the values if on init it fails to fetch the toggles from the remote.
  Future<void> init({
    // Updates to the growthbook_sdk_flutter package changed the structure of features
    // This workaround allows seeded features to still be passed in using the old format,
    // as well as features using the new format with GBFeature. We simply convert the
    // seeds into GBFeatures and add them to the final Map<String, GBFeature>.
    Map<String, GBFeature> features = const <String, GBFeature>{},
    @Deprecated('Instead use "features" as Map<String, GBFeature>')
        Map<String, dynamic> seeds = const <String, dynamic>{},
    Map<String, dynamic>? overrides,
    Map<String, dynamic>? attributes,
  }) async {
    Map<String, GBFeature> finalFeatures = Map.from(features);
    // Convert seeds to GBFeatures and add to finalFeatures Map
    if (seeds.isNotEmpty) {
      seeds.forEach((key, value) {
        finalFeatures[key] = GBFeature(defaultValue: value);
      });
    }

    _overrides.clear();
    _attributes.clear();
    if (overrides != null) {
      _overrides.addAll(overrides);
    }
    if (attributes != null) {
      _attributes.addAll(attributes);
    }
    _client = await _createLiveClient(
      apiHost: apiHost,
      clientKey: clientKey,
      features: finalFeatures,
    );
    await refresh();
  }

  /// Initialize for use in automated test suite
  Future<void> initForTests(
      {Map<String, GBFeature> features = const <String, GBFeature>{},
      @Deprecated('Instead use "features" as Map<String, GBFeature>')
          Map<String, dynamic> seeds = const <String, dynamic>{},
      Map<String, dynamic>? overrides,
      Map<String, dynamic>? attributes,
      List<Map<String, dynamic>>? rules}) async {
    _overrides.clear();
    _attributes.clear();
    if (overrides != null) {
      _overrides.addAll(overrides);
    }
    if (attributes != null) {
      _attributes.addAll(attributes);
    }
    _client = await _createTestClient(seeds: seeds, rules: rules);
    await refresh();
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

  Future<GrowthBookSDK> _createLiveClient({
    required String apiHost,
    required String clientKey,
    required Map<String, GBFeature> features,
  }) async {
    final app = await GBSDKBuilderApp(
      apiKey: clientKey,
      qaMode: false,
      attributes: _attributes,
      hostURL: apiHost,
      growthBookTrackingCallBack: (gbExperiment, gbExperimentResult) {},
      features: features,
    ).initialize();

    return app;
  }

  Future<GrowthBookSDK> _createTestClient(
      {Map<String, dynamic>? seeds, List<Map<String, dynamic>>? rules}) async {
    final app = await GBSDKBuilderApp(
            apiKey: 'some-garbage-key-because-we-are-not-using-it',
            hostURL: 'https://cdn.growthbook.io/',
            attributes: _attributes,
            growthBookTrackingCallBack: (gbExperiment, gbExperimentResult) {},
            client:
                UptechGrowthBookWrapperTestClient(seeds: seeds, rules: rules))
        .initialize();
    app.featuresFetchedSuccessfully(_seedsToGBFeatures(seeds: seeds));
    return app;
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
