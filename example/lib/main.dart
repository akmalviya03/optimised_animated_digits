import 'dart:math';
import 'package:flutter/material.dart';
import 'package:optimised_animated_digits/optimised_animated_digits.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ValueNotifier<double> valueNotifierFirst = ValueNotifier(0);
  ValueNotifier<double> valueNotifierSecond = ValueNotifier(10.0);
  ValueNotifier<bool> visibility = ValueNotifier(false);
  Random random = Random();
  double openPrice = 500;

  @override
  void dispose() {
    valueNotifierFirst.dispose();
    valueNotifierSecond.dispose();
    visibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ValueListenableBuilder(
            valueListenable: visibility,
            builder: (context, value, child) {
              return value
                  ? OptimisedAnimatedDigit(
                      milliseconds: 100,
                      valueNotifier: valueNotifierFirst,
                      positiveColor: Colors.green,
                      negativeColor: Colors.red,
                      neutralColor: Colors.black,
                      textStyle: const TextStyle(fontSize: 20),
                      decimal: const FlutterLogo(),
                      digitsSeparator: const Text('\$'),
                    )
                  : OptimisedAnimatedDigit(
                      milliseconds: 200,
                      valueNotifier: valueNotifierSecond,
                      positiveColor: Colors.green,
                      negativeColor: Colors.red,
                      neutralColor: Colors.black,
                      textStyle: const TextStyle(fontSize: 20),
                      decimal: const FlutterLogo(),
                      digitsSeparator: const Text('\$'),
                    );
            }),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            heroTag: "Visibility",
            onPressed: () {
              visibility.value = !visibility.value;
            },
            label: const Text('Toggle Visibility'),
          ),
          FloatingActionButton.extended(
            heroTag: "Generate",
            onPressed: () {
              double value = openPrice = openPrice +
                  (random.nextBool()
                      ? random.nextDouble()
                      : -random.nextDouble());
              if (visibility.value) {
                valueNotifierFirst.value = value;
              } else {
                valueNotifierSecond.value = value;
              }
            },
            label: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}
