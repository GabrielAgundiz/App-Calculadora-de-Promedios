import 'dart:async';
import 'dart:math';
import 'dart:isolate'; 
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora EQ#14',
      theme: ThemeData(
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.black),
        ),
      ),
      home: const MyHomePage(title: 'Calculadora de Promedios'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double _average;

  _MyHomePageState() {
    _average = 0.0;
  }

  Future<void> _updateAverage() async {
    final ReceivePort receivePort = ReceivePort();
    final List<Isolate> isolates = [];
    final Completer<void> completer = Completer<void>();
    final List<double> results = [];

    for (int i = 0; i < 5; i++) {
      final SendPort sendPort = receivePort.sendPort;
      isolates.add(await Isolate.spawn(_calculateAverage, sendPort));
    }

    receivePort.listen((dynamic data) {
      if (data is double) {
        results.add(data);
        if (results.length == 5) {
          final double average = results.reduce((a, b) => a + b) / results.length;
          setState(() {
            _average = average;
          });
          completer.complete();
        }
      }
    });

    await completer.future;
    receivePort.close();

    for (Isolate isolate in isolates) {
      isolate.kill();
    }
  }

  static void _calculateAverage(SendPort sendPort) {
    final random = Random();
    List<int> values = List<int>.generate(2000, (_) => random.nextInt(10000));
    double sum = values.fold(0, (a, b) => a + b);
    double average = sum / values.length;
    sendPort.send(average);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Promedio de los números aleatorios:',
            ),
            Text(
              '$_average',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _updateAverage();
        },
        tooltip: 'Calcular Promedio',
        backgroundColor: Colors.grey[400],
        child: const Icon(Icons.calculate),
      ),
    );
  }
}
