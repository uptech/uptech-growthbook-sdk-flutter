import 'package:uptech_growthbook_sdk_flutter/uptech_growthbook_sdk_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

class ToglTest extends UptechGrowthBookWrapper {
  ToglTest() : super(apiKey: 'dummy-api-key');

  static ToglTest instance = ToglTest();
}

void main() {
  group('UpTechGrowthBookSDKFlutter', () {
    group('#isOn', () {
      const String featureName = 'some-feature-name';

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
          ToglTest.instance.init(
            overridesPath: 'assets/overrides.json',
          );
        });

        test('it returns the overridden value', () {
          expect(ToglTest.instance.isOn(featureName), isTrue);
        });
      });

      group('when an invalid override path is given', () {
        setUp(() {
          ToglTest.instance.init(overridesPath: 'some/invalid/path.json');
        });

        test('it returns false', () {
          expect(ToglTest.instance.isOn(featureName), isFalse);
        });
      });
    });
  });
}
