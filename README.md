A widget that allows you to animate digits change of any number
without compromising number precision and application performance.

## Features
* 58 FPS in debug mode.
* 60 FPS.
* Low memory usage.
* No use of scroll views for scrolling effects.
* Jank Free

## Demo Video

![The example app running in iOS](https://github.com/akmalviya03/optimised_animated_digits/blob/master/demo.gif)


## Usage

```dart
    ValueNotifier<double> valueNotifier = ValueNotifier(0);
    OptimisedAnimatedDigit(
      milliseconds: 500,
      valueNotifier: valueNotifier,
      positiveColor: Colors.green,
      negativeColor: Colors.red,
      neutralColor: Colors.black,
      textStyle: const TextStyle(fontSize: 20),
      decimal: const FlutterLogo(),
      digitsSeparator: const Text('\$'),
    ),
```

More examples are available inside the `/example` folder.

## Additional information

Connect with Author over [Linkedin](https://www.linkedin.com/in/abhishakkrmalviya/)
