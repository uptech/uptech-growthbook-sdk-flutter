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
of the `UptechGrowthBookWrapper`. *Note:* This is whan needs the `apiKeyUrl` that
should come from your environment config and **not** be hard coded in your app.
This might look as follows maybe in a file called, `lib/togls.dart`. It is
really up to you how you do this. This is just a suggestion.

```dart
class Togls extends UptechGrowthBookWrapper {
  Togls()
      : super(
          // In GrowthBook dashboard > SDK Endpoints url: https://cdn.growthbook.io/api/features/dev_Y1WwxOm9sDnIsO1DLvwJk76z3ribr3VoiTsaOs?project=prj_29g61lbb6s8290
          // Include the entire url above
          apiKey: 'your-api-key-url', 
        );

  static final shared = Togls();
}
```

Once you have the `Togls` class you have two options for initializing the
library. One you can do in `main.dart` as follows. *Note:* You need to include
the `WidgetsFlutterBinding.ensureInitialized()` if you are going to load your
overrides from assets.

```dart
void main() async {
	// ...
	// ...
	WidgetsFlutterBinding.ensureInitialized();
	final overrides = await loadOverridesFromAssets('assets/overrides.json');
	Togls.shared.init(
		seeds: {
		  'example-toggle-higher-fee': false,
		},
		overrides: overrides,
	);
	// ...
	// ...
}
```

The other option is to have your top level widget be a `Stateful` widget and
call `Togls.shared.init` from within it's `initState` method that way it is
being executed once Flutter has been initialized. This would look something
like the following.

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
	loadOverridesFromAssets('assets/overrides.json').then((overrides) {
		Togls.shared.init(
			seeds: {
			  'example-toggle-higher-fee': false,
			},
			overrides: overrides,
		);
	});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

In the above examples we provide `seeds` which are values that are used to
evaulate the toggles prior to it having fetched the toggles from the remote
server. In the happy path this window of time is extremely small to the point
where you won't even notice these values. However, in the case that user
launched the app and the network connection is not working or the GrowthBook
service was down then the toggles would evaluate to the value specified in the
`seeds`.

### Adding attributes

If you want to add attributes at itialization, you can add values into the `attributes` key in the init function. This is useful if, for instance, you are only allowing certain versions of your app to access a feature.
```dart
void main() async {
	// ...
	// ...
	WidgetsFlutterBinding.ensureInitialized();
	final overrides = await loadOverridesFromAssets('assets/overrides.json');
  final version = getVersionNumber(); // this is a method you create and provide the logic for
	Togls.shared.init(
		seeds: {
		  'example-toggle-higher-fee': false,
		},
		overrides: overrides,
    attributes: attributes: {'version': version},
	);
	// ...
	// ...
}
```

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

### Evaluate Feature value

```dart
import 'package:yourproject/togls.dart';

int sampleApplyFee(int amount) {
  // Note: feature value can be of any type
  final featureValue = Togls.shared.value('example-toggle-higher-fee');
  if (featureValue != 0) {
    return amount + 20;
  } else {
    return amount + 10;
  }
}
```

### Set attributes
Additional attributes can be set after initialization. This is a common use case in which an id attribute is set after user login (useful for canary testing). 
```dart
import 'package:yourproject/togls.dart';

int sampleLogIn() {
  final userId = await login(); // Fake method that logs in user and gets user id
  Togls.shared.setAttributes({'id': userId});
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
