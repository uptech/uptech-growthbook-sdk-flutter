## Usage

### Setup Singleton

```dart
class Togls extends UptechGrowthBookWrapper {
  Togls()
      : super(
          apiKey: 'your-api-key', // example: dev_Y1WwxOm9sDnIsO1DLvwJk76z3ribr3VoiTsaOs?project=prj_29g61lbb6s8290
        );

  static final shared = Togls();
}
```

### Evaluate Feature

```dart
import 'package:yourproject/togls.dart';

int sampleApplyFee(int amount) {
  if (Togls.shared.isOn('example-toggle-higher-fee')) {
    return amount + 20;
  } else {
    return amount + 10;
  }
}
```

### Control toggles in automated tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yourproject/toggle_samples.dart';
import 'package:yourproject/togls.dart';

void main() {
  group('Toggle Samples', () {
    group('sampleApplyFee', () {
      group('when example-toggle-higher-fee is off', () {
        setUp(() {
          Togls.shared
              .initForTests(seeds: {'example-toggle-higher-fee': false});
        });

        test('it returns amount with fee of 10 added', () {
          final res = sampleApplyFee(2);
          expect(res, 12);
        });
      });

      group('when example-toggle-higher-fee is on', () {
        setUp(() {
          Togls.shared.initForTests(seeds: {'example-toggle-higher-fee': true});
        });

        test('it returns amount with fee of 20 added', () {
          final res = sampleApplyFee(2);
          expect(res, 22);
        });
      });
    });
  });
}
```
