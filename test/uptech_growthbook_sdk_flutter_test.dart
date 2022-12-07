import 'package:uptech_growthbook_sdk_flutter/uptech_growthbook_sdk_flutter.dart';
import 'package:test/test.dart';

class ToglTest extends UptechGrowthBookWrapper {
  ToglTest() : super(apiKey: 'dummy-api-key');

  static ToglTest instance = ToglTest();
}

void main() {
  group('UpTechGrowthBookSDKFlutter', () {
    group('when an overridden value is present', () {
      setUp(() {
        ToglTest.instance.initForTests(seeds: {
          'test-value': true,
        });
      });

      test('it returns the overridden value', () {
        expect(ToglTest.instance.isOn('test-value'), isTrue);
      });
    });

    group('when an overridden value is not present', () {
      setUp(() {
        ToglTest.instance.initForTests(seeds: {
          'some-other-value': true,
        });
      });

      test('it returns false', () {
        expect(ToglTest.instance.isOn('test-value'), isFalse);
      });
    });
  });
}
