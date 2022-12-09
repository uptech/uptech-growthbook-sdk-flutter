## Uptech GrowthBook SDK Flutter Wrapper

This project is a thin wrapper around the [GrowthBook Flutter SDK][] so that we
can use the [GrowthBook][] service to manage feature toggles while also being
able to manage toggle states properly within automated test suites.

## Development

Get dependencies

```
flutter pub get
```

Run tests

```
flutter test
```

## Setup

To set this up you need an account on [GrowthBook][] or to be hosting it
yourself.

Once you have an account and have setup your Project and the environments the
way you want. You need to get the read-only API key for each of the
environments and configure them in your app per environment.

Then you need to setup a singleton in your app to to house the shared instance
of the `UptechGrowthBookWrapper`. *Note:* This is whan needs the `apiKey` that
should come from your environment config and **not** be hard coded in your app.
This might look as follows maybe in a file called, `lib/togls.dart`. It is
really up to you how you do this. This is just a suggestion.

```dart
class Togls extends UptechGrowthBookWrapper {
  Togls()
      : super(
          apiKey: 'your-api-key', // example: dev_Y1WwxOm9sDnIsO1DLvwJk76z3ribr3VoiTsaOs?project=prj_29g61lbb6s8290
        );

  static final shared = Togls();
}
```

Then in your `main.dart` you initialize the it as follows.

```dart
void main() {
	// ...
	// ...
	Togls.shared.init(
		seeds: {
		  'example-toggle-higher-fee': false,
		},
	);
	// ...
	// ...
}
```

In the above we provide `seeds` which are values that are used to evaulate the
toggles prior to it having fetched the toggles from the remote server. In the
happy path this window of time is extremely small to the point where you won't
even notice these values. However, in the case that user launched the app and
the network connection is not working or the GrowthBook service was down then
the toggles would evaluate to the value specified in the `seeds`.

## Usage

Once you have it setup you are ready to start using it. The following examples
assume that you followed the suggestion above in terms of creating the
singleton. If you did something different you should still be able to use these
as rough examples of how to evaluate a feature and how to control toggles in
automated tests.


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

[GrowthBook Flutter SDK]: https://github.com/alippo-com/GrowthBook-SDK-Flutter
[GrowthBook]: https://www.growthbook.io
