import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Unknown battery level.';
  String _screenSizeInch = '0';

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
              const SizedBox(height: 40.0),
              ElevatedButton(onPressed: _getBatteryLevel, child: Text('Get battery')),
              ElevatedButton(
                  onPressed: _getDeviceScreenSizeInInch, child: Text('Get device screen inch')),
            ],
          ),
        ),
      ),
    );
  }
}
