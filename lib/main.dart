import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('samples.flutter.dev/channel');
  String _batteryLevel = 'Unknown battery level.';
  String _screenSizeInch = 'Unknown device screen inch.';
  int _counter = 0;

  @override
  void initState() {
    platform.setMethodCallHandler(
      (call) async {
        print('call.method: ${call.method} - call.arguments: ${call.arguments}');
        switch (call.method) {
          case "triggerNativeCallbackFlutter":
            {
              setState(() {
                _counter = call.arguments as int;
              });
            }
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_batteryLevel),
              Text(_screenSizeInch),
              Text('Counter: $_counter'),
              const SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: _getBatteryLevel,
                child: const Text('Get battery'),
              ),
              ElevatedButton(
                onPressed: _getDeviceScreenSizeInInch,
                child: const Text('Get device screen inch'),
              ),
              ElevatedButton(
                onPressed: _triggerNativeCallbackFlutter,
                child: const Text('Trigger native call back to Flutter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getDeviceScreenSizeInInch() async {
    String batteryLevel;
    try {
      final result = await platform.invokeMethod('getDeviceScreenSizeInInch');
      batteryLevel = '$result inch';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get screen size in inch: '${e.message}'.";
    }
    setState(() {
      _screenSizeInch = batteryLevel;
    });
  }

  Future<void> _triggerNativeCallbackFlutter() async {
    try {
      await platform.invokeMethod('triggerNativeCallbackFlutter');
    } on PlatformException catch (e) {
      print("Failed to trigger native call back: '${e.message}'.");
    }
    print('ok');
  }
}
