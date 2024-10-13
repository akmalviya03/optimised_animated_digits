import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
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
    ValueNotifier
    return Scaffold(
      body: Center(
        child: StreamBuilder<num>(
            stream: streamController.stream,
            builder: (context, snapshot) {
              return OptimisedAnimatedDigit(
                milliseconds: 100,
                value: snapshot.data ?? 0.0,
                positiveColor: Colors.green,
                negativeColor: Colors.red,
                neutralColor: Colors.black,
                textStyle: const TextStyle(fontSize: 20),
                decimal: const FlutterLogo(),
                digitsSeparator: const Text('\$'),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          double value = openPrice = openPrice +
              (random.nextBool() ? random.nextDouble() : -random.nextDouble());
          streamController.add(value);
        },
        label: const Text('Generate'),
      ),
    );
  }
}
