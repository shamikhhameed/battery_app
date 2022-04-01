import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:app_usage/app_usage.dart';

import 'limit.dart';
import 'limit_list.dart';

class BatteryPage extends StatefulWidget {
  static const String idScreen = "Battery";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BatteryStates();
  }
}

class BatteryStates extends State<BatteryPage> {
  static const countdownDuration = Duration(minutes: 10);
  var battery = Battery();
  Duration duration = Duration();
  Timer? timer;
  bool batteryFull = false, batteryCharging = false;
  List _infos = [];
  List list = [];

  bool countDown = false;

  Future<List?> getUsageStats() async {
    try {
      String twoDigits(Double n) => n.toString().padRight(2, '0');
      double allTime = 0;
      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 24));
      List<AppUsageInfo> infoList =
          await AppUsage.getAppUsage(startDate, endDate);
      for (var info in infoList.toList()) {
        allTime = allTime + info.usage.inMilliseconds;
      }

      for (var info in infoList) {
        Map map = {
          "appName": info.appName,
          "usage":
              (info.usage.inMilliseconds / allTime * 100).toStringAsFixed(2) +
                  "%",
        };
        list.add(map);
      }
      return list;
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  @override
  void initState() {
    super.initState();
    reset();
    batteryChange();
    this.getUsageStats().then((value) => {
          setState(() {
            _infos = value!;
          }),
          print(value)
        });
  }

  void batteryChange() {
    battery.onBatteryStateChanged.listen((state) {
      if (state == BatteryState.discharging) {
        batteryCharging = true;
        startTimer();
      } else {
        stopTimer();
        reset();
        batteryCharging = false;
        if (state == BatteryState.full) {
          batteryFull = true;
        }
      }
    });
  }

  void reset() {
    if (countDown) {
      setState(() => duration = countdownDuration);
    } else {
      setState(() => duration = Duration());
    }
  }

  void addTime() {
    final addSeconds = countDown ? -1 : 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer?.cancel());
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  @override
  void dispose() async {
    super.dispose(); // Need to call dispose function.
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final second = twoDigits(duration.inSeconds.remainder(60));
    return Scaffold(
      appBar: AppBar(
        title: Text("Battery Status"),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: Column(
                children: [
                  buildImage(),
                  Text(
                    '${twoDigits(duration.inHours)}:${minutes}:${second}',
                    style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                    textAlign: TextAlign.center,
                  ),
                  usageApps(),
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Container(
                          height: 50.0,
                          child: const Center(
                            child: Text(
                              "Limit App",
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: "Brand Bold"),
                            ),
                          ),
                        ),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(24.0),
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, Limit.idScreen, (route) => true);
                        },
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Container(
                          height: 50.0,
                          child: const Center(
                            child: Text(
                              "Limit Apps List",
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: "Brand Bold"),
                            ),
                          ),
                        ),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(24.0),
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, LimitList.idScreen, (route) => true);
                        },
                      )
                  )
                ],
              )
              )
          )
      ),
    );
  }

  Widget buildImage() {
    final batteryFull = this.batteryFull;
    final batteryCharging = this.batteryCharging;

    if (batteryFull) {
      return  Image(
        image: AssetImage("images/bf.png"),
        width: 200.0,
        height: 200.0,
        alignment: Alignment.center,
      );
    } else if (batteryCharging) {
      return  Image(
        image: AssetImage("images/bc.png"),
        width: 200.0,
        height: 200.0,
        alignment: Alignment.center,
      );
    } else {
      return  Image(
        image: AssetImage("images/low-b.png"),
        width: 200.0,
        height: 200.0,
        alignment: Alignment.center,
      );
    }
  }

  Widget usageApps() {
    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: _infos.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: Text(_infos[index]['appName']),
              trailing: Text(_infos[index]['usage'].toString()));
        });
  }
}
