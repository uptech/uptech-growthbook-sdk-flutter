import 'package:flutter/widgets.dart';
import 'package:uptech_growthbook_sdk_flutter/uptech_growthbook_sdk_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

class ToglTest extends UptechGrowthBookWrapper {
  ToglTest() : super(apiKey: 'dummy-api-key');

  static ToglTest instance = ToglTest();
}

void main() {
  const String featureName = 'some-feature-name';
  group('UpTechGrowthBookSDKFlutter', () {
    group('#isOn', () {
      group('when no value is found for the feature', () {
        setUp(() {
          ToglTest.instance.initForTests(seeds: {
            featureName: true,
          });
        });

        test('it returns false', () {
          expect(ToglTest.instance.isOn('some-other-feature'), isFalse);
        });
      });

      group('when a feature value is present', () {
        setUp(() {
          ToglTest.instance.initForTests(seeds: {
            featureName: true,
          });
        });

        test('it returns the feature value', () {
          expect(ToglTest.instance.isOn(featureName), isTrue);
        });
      });

      group('when an override is present', () {
        setUp(() {
          ToglTest.instance.initForTests(
            overrides: {featureName: true},
          );
        });

        test('it returns the overridden value', () {
          expect(ToglTest.instance.isOn(featureName), isTrue);
        });
      });

      group('when the attribute meets the condition', () {
        setUp(() {
          const String greaterThan = '\$gt';
          ToglTest.instance.initForTests(
            seeds: {
              featureName: false,
            },
            rules: [
              {
                'condition': {
                  'version': {greaterThan: '1.0.0'}
                },
                'force': true
              }
            ],
            attributes: {'version': '1.0.1'},
          );
        });

        test('it returns true', () {
          expect(ToglTest.instance.isOn(featureName), isTrue);
        });
      });

      group('when the attribute does not meet the condition', () {
        setUp(() {
          const String greaterThan = '\$gt';
          ToglTest.instance.initForTests(
            seeds: {
              featureName: false,
            },
            rules: [
              {
                'condition': {
                  'version': {greaterThan: '1.0.0'}
                },
                'force': true
              }
            ],
            attributes: {'version': '0.0.9'},
          );
        });

        test('it returns false', () {
          expect(ToglTest.instance.isOn(featureName), isFalse);
        });
      });
    });
  });

  group('loadOverridesFromAssets', () {
    setUp(() {
      ToglTest.instance.initForTests(seeds: {
        featureName: true,
      });
    });

    test('returns empty overrides when asset file not found', () async {
      WidgetsFlutterBinding.ensureInitialized();
      final overrides =
          await loadOverridesFromAssets('assets/some_missing_asset_file.json');
      expect(overrides, equals({}));
    });

    test('fetches overrides', () async {
      WidgetsFlutterBinding.ensureInitialized();
      final overrides = await loadOverridesFromAssets('assets/overrides.json');
      expect(overrides[featureName], isTrue);
    });
  });
}
