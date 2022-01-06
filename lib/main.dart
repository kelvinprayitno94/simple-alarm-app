import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'clock/clock_text.dart';
import 'clock/clock_view.dart';
import 'localnotification/notification_service.dart';
import 'locator.dart';

void printHello() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  debugPrint("[$now] Hello, world! isolate=$isolateId function='$printHello'");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().init();

  final ReceivePort port = ReceivePort();

  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );

  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Clock(
          circleColor: Colors.black,
          showBellsAndLegs: false,
          bellColor: Colors.blue,
          clockText: ClockText.roman,
          showHourHandleHeartShape: false),
    );
  }
}
