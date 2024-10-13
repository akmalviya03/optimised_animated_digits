import 'dart:async';
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
  final StreamController<num> streamController = StreamController();
  Random random = Random();
  double openPrice = 500;

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<num>(
          stream: streamController.stream,
          builder: (context, snapshot) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OptimisedAnimatedDigit(
                    milliseconds: 500,
                    value: snapshot.data ?? 0.0,
                    differentDigitsColor: false,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  OptimisedAnimatedDigit(
                    milliseconds: 100,
                    value: snapshot.data ?? 0.0,
                    differentDigitsColor: true,
                    positiveColor: Colors.green,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  OptimisedAnimatedDigit(
                    milliseconds: 100,
                    value: snapshot.data ?? 0.0,
                    differentDigitsColor: true,
                    positiveColor: Colors.green,
                    negativeColor: Colors.red,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  OptimisedAnimatedDigit(
                    milliseconds: 100,
                    value: snapshot.data ?? 0.0,
                    differentDigitsColor: true,
                    positiveColor: Colors.green,
                    negativeColor: Colors.red,
                    neutralColor: Colors.blueGrey,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  OptimisedAnimatedDigit(
                    milliseconds: 100,
                    value: snapshot.data ?? 0.0,
                    differentDigitsColor: true,
                    positiveColor: Colors.green,
                    negativeColor: Colors.red,
                    neutralColor: Colors.black,
                    textStyle: const TextStyle(fontSize: 20),
                    decimal: const FlutterLogo(),
                  ),
                  OptimisedAnimatedDigit(
                    milliseconds: 100,
                    value: snapshot.data ?? 0.0,
                    differentDigitsColor: true,
                    positiveColor: Colors.green,
                    negativeColor: Colors.red,
                    neutralColor: Colors.black,
                    textStyle: const TextStyle(fontSize: 20),
                    digitsSeparator: const Text('\$'),
                  ),
                  OptimisedAnimatedDigit(
                    milliseconds: 100,
                    value: snapshot.data ?? 0.0,
                    differentDigitsColor: false,
                    positiveColor: Colors.green,
                    negativeColor: Colors.red,
                    neutralColor: Colors.black,
                    textStyle: const TextStyle(fontSize: 20),
                    decimal: const FlutterLogo(),
                    digitsSeparator: const Text('\$'),
                  ),
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          double value = openPrice +
              (random.nextBool() ? random.nextDouble() : -random.nextDouble());
          streamController.add(value);
        },
        label: const Text('Generate'),
      ),
    );
  }
}
