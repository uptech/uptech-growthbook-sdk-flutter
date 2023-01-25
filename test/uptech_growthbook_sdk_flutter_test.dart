import 'package:flutter/widgets.dart';
import 'package:uptech_growthbook_sdk_flutter/uptech_growthbook_sdk_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

class ToglTest extends UptechGrowthBookWrapper {
  ToglTest()
      : super(
            apiHost: 'https://cdn.growthbook.io/', clientKey: 'dummy-api-key');

  static ToglTest instance = ToglTest();
}

void main() {
  group('UpTechGrowthBookSDKFlutter', () {
    group('#isOn', () {
      group('when no value is found for the feature', () {
        setUp(() {
          ToglTest.instance.initForTests(seeds: {
            'some-feature-name': true,
          });
        });

        test('it returns false', () {
          expect(ToglTest.instance.isOn('some-other-feature'), isFalse);
        });
      });

      group('when a feature value is present', () {
        setUp(() {
          ToglTest.instance.initForTests(seeds: {
            'some-feature-name': true,
          });
        });

        test('it returns the feature value', () {
          expect(ToglTest.instance.isOn('some-feature-name'), isTrue);
        });
      });

      group('when an override is present', () {
        setUp(() {
          ToglTest.instance.initForTests(
            overrides: {'some-feature-name': true},
          );
        });

        test('it returns the overridden value', () {
          expect(ToglTest.instance.isOn('some-feature-name'), isTrue);
        });
      });

      group('when the attribute is added at initialization', () {
        group('and the major in the attribute is greater than the rules', () {
          setUp(() {
            const String greaterThan = '\$gt';
            ToglTest.instance.initForTests(
              seeds: {
                'some-feature': false,
              },
              rules: [
                {
                  'condition': {
                    'version': {greaterThan: '1.9.9'}
                  },
                  'force': true
                }
              ],
              attributes: {'version': '2.0.2'},
            );
          });

          test('it returns true', () {
            expect(ToglTest.instance.isOn('some-feature'), isTrue);
          });
        });

        group('and the minor in the attribute is greater than the rules', () {
          setUp(() {
            const String greaterThan = '\$gt';
            ToglTest.instance.initForTests(
              seeds: {
                'some-feature': false,
              },
              rules: [
                {
                  'condition': {
                    'version': {greaterThan: '1.0.9'}
                  },
                  'force': true
                }
              ],
              attributes: {'version': '1.1.1'},
            );
          });

          test('it returns true', () {
            expect(ToglTest.instance.isOn('some-feature'), isTrue);
          });
        });

        group('and the patch in the attribute is greater than the rules', () {
          setUp(() {
            const String greaterThan = '\$gt';
            ToglTest.instance.initForTests(
              seeds: {
                'some-feature': false,
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
            expect(ToglTest.instance.isOn('some-feature'), isTrue);
          });
        });

        group('and the major in the attribute is less than the rules', () {
          setUp(() {
            const String greaterThan = '\$gt';
            ToglTest.instance.initForTests(
              seeds: {
                'some-feature': false,
              },
              rules: [
                {
                  'condition': {
                    'version': {greaterThan: '2.0.0'}
                  },
                  'force': true
                }
              ],
              attributes: {'version': '1.9.9'},
            );
          });

          test('it returns false', () {
            expect(ToglTest.instance.isOn('some-feature'), isFalse);
          });
        });

        group('and the minor in the attribute is less than the rules', () {
          setUp(() {
            const String greaterThan = '\$gt';
            ToglTest.instance.initForTests(
              seeds: {
                'some-feature': false,
              },
              rules: [
                {
                  'condition': {
                    'version': {greaterThan: '1.1.0'}
                  },
                  'force': true
                }
              ],
              attributes: {'version': '1.0.9'},
            );
          });

          test('it returns false', () {
            expect(ToglTest.instance.isOn('some-feature'), isFalse);
          });
        });

        group('and the patch in the attribute is less than the rules', () {
          setUp(() {
            const String greaterThan = '\$gt';
            ToglTest.instance.initForTests(
              seeds: {
                'some-feature': false,
              },
              rules: [
                {
                  'condition': {
                    'version': {greaterThan: '1.0.1'}
                  },
                  'force': true
                }
              ],
              attributes: {'version': '1.0.0'},
            );
          });

          test('it returns false', () {
            expect(ToglTest.instance.isOn('some-feature'), isFalse);
          });
        });
      });

      group('when the attribute is added after initialization', () {
        group('and the attribute meets the condition', () {
          setUp(() {
            const String greaterThan = '\$gt';
            ToglTest.instance.initForTests(
              seeds: {
                'some-feature': false,
              },
              rules: [
                {
                  'condition': {
                    'version': {greaterThan: '1.0.0'}
                  },
                  'force': true
                }
              ],
            );
            ToglTest.instance.setAttributes({'version': '1.0.1'});
          });

          test('it returns true', () {
            expect(ToglTest.instance.isOn('some-feature'), isTrue);
          });
        });

        group('and the attribute does not meet the condition', () {
          setUp(() {
            const String greaterThan = '\$gt';
            ToglTest.instance.initForTests(
              seeds: {
                'some-feature': false,
              },
              rules: [
                {
                  'condition': {
                    'version': {greaterThan: '1.0.0'}
                  },
                  'force': true
                }
              ],
            );

            ToglTest.instance.setAttributes({'version': '0.0.9'});
          });

          test('it returns false', () {
            expect(ToglTest.instance.isOn('some-feature'), isFalse);
          });
        });
      });
    });

    group('#value', () {
      group('when no value is found for the feature', () {
        setUp(() {
          ToglTest.instance.initForTests(seeds: {
            'string-value-feature': 'value',
            'int-value-feature': 1,
            'bool-value-feature': true,
          });
        });

        test('it returns null', () {
          expect(ToglTest.instance.value('some-other-feature'), isNull);
        });
      });

      group('when a feature value is present', () {
        setUp(() {
          ToglTest.instance.initForTests(seeds: {
            'string-value-feature': 'value',
            'int-value-feature': 1,
            'bool-value-feature': true,
          });
        });

        test('it returns the feature value', () {
          expect(
              ToglTest.instance.value('string-value-feature'), equals('value'));
          expect(ToglTest.instance.value('int-value-feature'), equals(1));
          expect(ToglTest.instance.value('bool-value-feature'), isTrue);
        });
      });

      group('when an override is present', () {
        setUp(() {
          ToglTest.instance.initForTests(
            overrides: {
              'string-value-feature': 'value',
              'int-value-feature': 1,
              'bool-value-feature': true,
            },
          );
        });

        test('it returns the overridden value', () {
          expect(
              ToglTest.instance.value('string-value-feature'), equals('value'));
          expect(ToglTest.instance.value('int-value-feature'), equals(1));
          expect(ToglTest.instance.value('bool-value-feature'), isTrue);
        });
      });
    });
  });

  group('loadOverridesFromAssets', () {
    setUp(() {
      ToglTest.instance.initForTests(seeds: {
        'some-feature-name': true,
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
      expect(overrides['some-feature-name'], isTrue);
    });
  });
}
