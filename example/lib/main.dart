import 'dart:math';
import 'package:advanced_value_notifier/advanced_value_notifier.dart';
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
  TransformerHistoryValueNotifier<num, List<String>> valueNotifier =
      TransformerHistoryValueNotifier(
    value: 0.0,
    transformer: generateDigits,
  );
  Random random = Random();
  double openPrice = 500;

  @override
  void dispose() {
    valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: OptimisedAnimatedDigit(
          milliseconds: 100,
          valueNotifier: valueNotifier,
          positiveColor: Colors.green,
          negativeColor: Colors.red,
          neutralColor: Colors.black,
          textStyle: const TextStyle(fontSize: 20),
          decimal: const FlutterLogo(),
          digitsSeparator: const Text('\$'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          double value = openPrice = openPrice +
              (random.nextBool() ? random.nextDouble() : -random.nextDouble());
          valueNotifier.value = value;
        },
        label: const Text('Generate'),
      ),
    );
  }
}
