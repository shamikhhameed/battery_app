import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:app_usage/app_usage.dart';

import '../AllScreens/limit.dart';
import '../AllScreens/limit_list.dart';

class BatteryPage extends StatefulWidget {
  static const String routeName = '/batteryPage';

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

  // List device apps
  Future<List?> getAppUsage() async {
    try {
      double allTime = 0;
      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 24));
      List<AppUsageInfo> infoList =
          await AppUsage.getAppUsage(startDate, endDate);
      // count usage all time
      for (var info in infoList.toList()) {
        allTime = allTime + info.usage.inMilliseconds;
      }
      
      // insert list array
      for (var info in infoList) {
        Map map = {
          "appName": info.appName,
          "usage":
              (info.usage.inMilliseconds / allTime * 100).toStringAsFixed(2) +
                  "%", // calculate the percentage
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
    this.getAppUsage().then((value) => {
          setState(() {
            _infos = value!;
          }),
          print(value)
        });
  }

  // find device charging state
  void batteryChange() {
    battery.onBatteryStateChanged.listen((state) {
      if (state == BatteryState.charging) {
        batteryCharging = true;
        startTimer(); 
      } else if(state == BatteryState.discharging){
        batteryCharging = false;
        startTimer();
      } else {
        stopTimer();
        reset();
        if (state == BatteryState.full) {
          batteryFull = true;
        }
      }
    });
  }

  // reseting the timer
  void reset() {
    if (countDown) {
      setState(() => duration = countdownDuration);
    } else {
      setState(() => duration = Duration());
    }
  }

  // add seconds to the timer
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

  // stop timer
  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer?.cancel());
  }

  // start timer
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  @override
  void dispose() async {
    super.dispose(); // Need to call dispose function.
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0'); // set to two digits
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final second = twoDigits(duration.inSeconds.remainder(60));
    return Scaffold(
      appBar: AppBar(
        title: Text("Battery Status"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: Column(
                children: [
                  SizedBox(height: 30),
                  buildImage(),
                  Text(
                    '${twoDigits(duration.inHours)}:${minutes}:${second}',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontFamily: "Brand Bold",
                    ),
                    textAlign: TextAlign.center,
                  ),
                  usageApps(),
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        color: Colors.white,
                        textColor: Colors.black,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Limit()),
                          );
                        },
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                      child: RaisedButton(
                        color: Colors.white,
                        textColor: Colors.black,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LimitList()),
                          );
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

  // build battery state images
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

  // build usage apps list
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
