import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:simple_alarm_app/chart/vertical_bar_label_chart.dart';
import 'package:simple_alarm_app/clock/clock_cubit.dart';
import 'package:simple_alarm_app/clock/clock_state.dart';
import 'package:simple_alarm_app/localnotification/notification_service.dart';

import 'clock_face.dart';
import 'clock_text.dart';

typedef TimeProducer = DateTime Function();

const String portName = "MyAppPort";
const String isolateName = 'isolate';
final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

class Clock extends StatefulWidget {
  final Color circleColor;
  final bool showBellsAndLegs;
  final Color bellColor;
  final Color legColor;
  final ClockText clockText;
  final bool showHourHandleHeartShape;
  final TimeProducer getCurrentTime;
  final Duration updateDuration;
  final Duration updateDurations;

  const Clock(
      {Key? key,
      this.circleColor = Colors.black,
      this.showBellsAndLegs = true,
      this.bellColor = const Color(0xFF333333),
      this.legColor = const Color(0xFF555555),
      this.clockText = ClockText.arabic,
      this.showHourHandleHeartShape = false,
      this.getCurrentTime = getSystemTime,
      this.updateDuration = const Duration(seconds: 0),
      this.updateDurations = const Duration(hours: 0)})
      : super(key: key);

  static DateTime getSystemTime() {
    return DateTime.now();
  }

  @override
  State<StatefulWidget> createState() {
    return _Clock();
  }
}

class _Clock extends State<Clock> {
  ReceivePort receivePort = ReceivePort();
  static late SendPort? uiSendPort;

  late Timer _timer;
  static late Timer ringtoneTimer;
  static int _start = 2;
  late DateTime dateTime;
  Duration duration = const Duration();
  String currentAlarm = "-";

  int hours = 0;
  int minutes = 0;

  final baseColor = const Color.fromRGBO(255, 255, 255, 0.3);

  String date = "";

  // The callback for our alarm
  static Future<void> callback() async {
    NotificationService _notificationService = NotificationService();
    ClockCubit _clockCubit = ClockCubit(ClockStateInit());

    debugPrint("Alarm fired!");

    FlutterRingtonePlayer.play(
        android: AndroidSounds.alarm,
        ios: IosSounds.alarm,
        looping: false,
        volume: 1,
        asAlarm: false);

    startRingtoneTimer();

    var date = await _clockCubit.getCurrentAlarmForNotif();

    _notificationService.showNotifications(date);

    _clockCubit.removeCurrentAlarm();

    uiSendPort = IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  @override
  void initState() {
    super.initState();

    AndroidAlarmManager.initialize();

    dateTime = DateTime.now();
    hours = dateTime.hour;
    minutes = dateTime.minute;
    debugPrint("init hour $hours, minutes $minutes");

    duration = widget.updateDurations;
    _timer = Timer.periodic(widget.updateDuration, setTime);

    clockCubit.getCurrentAlarm();
  }

  void setTime(Timer timer) {
    setState(() {
      var now = DateTime.now();
      dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hours,
        minutes,
        now.second,
      );
      date = dateFormat.format(dateTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    ringtoneTimer.cancel();
    FlutterRingtonePlayer.stop();
    super.dispose();
  }

  void _updateHour(int init, int end, int laps) {
    setState(() {
      hours = end;
    });

    duration = Duration(hours: hours, minutes: minutes);
    _timer = Timer.periodic(widget.updateDuration, setTime);
  }

  void _updateMinute(int init, int end, int laps) {
    setState(() {
      minutes = end;
    });

    duration = Duration(hours: hours, minutes: minutes);
    _timer = Timer.periodic(widget.updateDuration, setTime);
  }

  static startRingtoneTimer() {
    _start = 2;
    ringtoneTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          FlutterRingtonePlayer.stop();
        } else {
          _start--;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("tanggal $date"),
      ),
      floatingActionButton: BlocProvider(
        create: (context) => clockCubit,
        child: BlocListener<ClockCubit, ClockState>(
          listener: (context, state) async {
            if (state is ClockStateAddNotif) {
              var date = state.date;

              setState(() {
                currentAlarm = dateFormat.format(date);
              });

              const int alarmId = 0;
              // await AndroidAlarmManager.oneShot(const Duration(seconds: 5), alarmId, callback,
              //     alarmClock: true, exact: true)
              //     .then((val) => debugPrint("one shot then $val"));
              await AndroidAlarmManager.oneShotAt(date, alarmId, callback,
                      alarmClock: true, exact: true)
                  .then((val) => debugPrint("one shot then $val"));
            }
          },
          child: FloatingActionButton(
            onPressed: () async {
              clockCubit.addNotif(dateTime);
            },
            child: const Center(
              child: Text("Pasang Alarm", style: TextStyle(
                fontSize: 12
              ), textAlign: TextAlign.center,),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.blue[200],
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              AspectRatio(
                aspectRatio: 1.0,
                child: (widget.showBellsAndLegs)
                    ? Stack(children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: CustomPaint(
                            painter: BellsAndLegsPainter(
                                bellColor: widget.bellColor,
                                legColor: widget.legColor),
                          ),
                        ),
                        buildClockCircle(context)
                      ])
                    : buildClockCircle(context),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text("Pilih Jam"),
              SingleCircularSlider(
                24,
                hours,
                height: 220.0,
                width: 220.0,
                primarySectors: 6,
                secondarySectors: 24,
                baseColor: const Color.fromRGBO(255, 255, 255, 0.1),
                selectionColor: baseColor,
                handlerColor: Colors.white,
                handlerOutterRadius: 12.0,
                onSelectionChange: _updateHour,
                onSelectionEnd: (newInit, newEnd, laps) => debugPrint(
                    "hour newInit: $newInit, newEnd $newEnd, laps $laps"),
                child: Center(
                  child: Text("Jam $hours"),
                ),
                showRoundedCapInSelection: true,
                showHandlerOutter: false,
                shouldCountLaps: false,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("Pilih menit"),
              SingleCircularSlider(
                60,
                minutes,
                height: 220.0,
                width: 220.0,
                primarySectors: 6,
                secondarySectors: 24,
                baseColor: const Color.fromRGBO(255, 255, 255, 0.1),
                selectionColor: baseColor,
                handlerColor: Colors.white,
                handlerOutterRadius: 12.0,
                onSelectionChange: _updateMinute,
                onSelectionEnd: (newInit, newEnd, laps) => debugPrint(
                    "minutes newInit: $newInit, newEnd $newEnd, laps $laps"),
                child: Center(
                  child: Text("Menit $minutes"),
                ),
                showRoundedCapInSelection: true,
                showHandlerOutter: false,
                shouldCountLaps: false,
              ),
              const SizedBox(
                height: 10,
              ),
              BlocProvider(
                create: (context) => clockCubit,
                child: BlocListener<ClockCubit, ClockState>(
                  listener: (context, state) {
                    if (state is ClockStateCurrentAlarm) {
                      var date = state.date;
                      setState(() {
                        currentAlarm = date;
                      });
                    }
                  },
                  child: Column(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const VerticalBarLabelChartView()));
                          },
                          child: const Text("Buka halaman chart")),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("Alarm selanjutny $currentAlarm"),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Container buildClockCircle(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.circleColor,
        boxShadow: const [
          BoxShadow(
            offset: Offset(0.0, 5.0),
            blurRadius: 5.0,
          )
        ],
      ),
      child: ClockFace(
        clockText: widget.clockText,
        showHourHandleHeartShape: widget.showHourHandleHeartShape,
        dateTime: dateTime,
      ),
    );
  }
}

class BellsAndLegsPainter extends CustomPainter {
  final Color bellColor;
  final Color legColor;
  final Paint bellPaint;
  final Paint legPaint;

  BellsAndLegsPainter(
      {this.bellColor = const Color(0xFF333333),
      this.legColor = const Color(0xFF555555)})
      : bellPaint = Paint(),
        legPaint = Paint() {
    bellPaint.color = bellColor;
    bellPaint.style = PaintingStyle.fill;

    legPaint.color = legColor;
    legPaint.style = PaintingStyle.stroke;
    legPaint.strokeWidth = 10.0;
    legPaint.strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    canvas.save();

    canvas.translate(radius, radius);

    //draw the handle
    Path path = Path();
    path.moveTo(-60.0, -radius - 10);
    path.lineTo(-50.0, -radius - 50);
    path.lineTo(50.0, -radius - 50);
    path.lineTo(60.0, -radius - 10);

    canvas.drawPath(path, legPaint);

    //draw right bell and left leg
    canvas.rotate(2 * pi / 12);
    drawBellAndLeg(radius, canvas);

    //draw left bell and right leg
    canvas.rotate(-4 * pi / 12);
    drawBellAndLeg(radius, canvas);

    canvas.restore();
  }

  //helps draw the leg and bell
  void drawBellAndLeg(radius, canvas) {
    //bell
    Path path1 = Path();
    path1.moveTo(-55.0, -radius - 5);
    path1.lineTo(55.0, -radius - 5);
    path1.quadraticBezierTo(0.0, -radius - 75, -55.0, -radius - 10);

    //leg
    Path path2 = Path();
    path2.addOval(
        Rect.fromCircle(center: Offset(0.0, -radius - 50), radius: 3.0));
    path2.moveTo(0.0, -radius - 50);
    path2.lineTo(0.0, radius + 20);

    //draw the bell on top on the leg
    canvas.drawPath(path2, legPaint);
    canvas.drawPath(path1, bellPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
