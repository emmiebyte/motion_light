import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

double lastMag = 0.0;
StreamController<Color> trigger = StreamController<Color>();

int counter = 0;
final colors = [
  Colors.amber,
  Colors.blueAccent,
  Colors.deepPurple,
  Colors.teal,
  Colors.indigo,
  Colors.pink,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.cyan,
  Colors.purple,
  Colors.lime,
];
DateTime debounceTimer = DateTime.now();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // gyroscopeEventStream(samplingPeriod: SensorInterval.fastestInterval).listen(
  //   (GyroscopeEvent event) {
  //     print(event);
  //   },
  //   onError: (error) {
  //     // Logic to handle error
  //     // Needed for Android in case sensor is not available
  //     print(error);
  //   },
  //   cancelOnError: true,
  // );
  // // [GyroscopeEvent (x: 0.0, y: 0.0, z: 0.0)]

  trigger.add(colors[counter]);
  userAccelerometerEventStream(samplingPeriod: SensorInterval.fastestInterval)
      .listen(
        (UserAccelerometerEvent event) {
          // print(event);
          event.timestamp;
          final mag = sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );
          final peak =
              mag > 30.0 &&
              lastMag > mag &&
              (DateTime.now().difference(debounceTimer) > Durations.medium1);
          lastMag = mag;
          // print('$peak, ${event.timestamp}, $mag');
          if (peak) {
            debounceTimer = DateTime.now();
            counter = (counter + 1) % colors.length;
            trigger.add(colors[counter]);
          }
        },
        onError: (error) {
          // Logic to handle error
          // Needed for Android in case sensor is not available
        },
        cancelOnError: true,
      );
  // [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: ColorWidget(),
    );
  }
}

class ColorWidget extends StatelessWidget {
  const ColorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        counter = (counter + 1) % colors.length;
        trigger.add(colors[counter]);
      },
      child: StreamBuilder<Color>(
        stream: trigger.stream,
        builder: (context, snapshot) => Container(color: snapshot.data),
      ),
    );
  }
}
