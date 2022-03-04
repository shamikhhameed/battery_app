import 'dart:ui';

import 'package:battery_app/pages/charge_history.dart';
import 'package:battery_app/pages/notification_setter.dart';
import 'package:battery_app/pages/usage_last_charge.dart';
import 'package:battery_app/pages/usage_last_week.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Battery battery = Battery();
  int showBatteryLevels = 0;
  BatteryState? batteryState;
  bool? broadcastBattery;

  Color COLOR_RED = Colors.red;
  // Color COLOR_GREEN = Color.fromARGB(255, 0, 169, 181);
  Color COLOR_GREEN = Colors.green;
  Color COLOR_GREY = Colors.grey;

  @override
  void initState() {
    super.initState();
    _broadcastBatteryLevels();
    battery.onBatteryStateChanged.listen((event) {
      setState(() {
        batteryState = event;
      });
    });
  }

  _broadcastBatteryLevels() async {
    broadcastBattery = true;
    while (broadcastBattery!) {
      var batteryLvls = await battery.batteryLevel;
      setState(() {
        showBatteryLevels = batteryLvls;
      });
      await Future.delayed(Duration(seconds: 5));
    }
  }

  @override
  void dispose() {
    super.dispose();
    setState(() {
      broadcastBattery = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Battery Bud"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50),
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 0),
                        // blurRadius: 7,
                        // spreadRadius: -5,
                        // offset: const Offset(4, 4),
                        color: COLOR_GREY
                        ),
                  ]
                ),
                child: SfRadialGauge(
                  axes: [
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      startAngle: 270,
                      endAngle: 270,
                      showLabels: false,
                      showTicks: false,
                      axisLineStyle: AxisLineStyle(
                          thickness: 1,
                          color:
                              showBatteryLevels <= 20 ? COLOR_RED : COLOR_GREEN,
                          thicknessUnit: GaugeSizeUnit.factor),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: double.parse(showBatteryLevels.toString()),
                          width: 0.3,
                          color: Colors.white,
                          pointerOffset: 0.1,
                          cornerStyle: showBatteryLevels == 100
                              ? CornerStyle.bothFlat
                              : CornerStyle.endCurve,
                          sizeUnit: GaugeSizeUnit.factor,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            positionFactor: 0.5,
                            angle: 90,
                            widget: Text(
                              showBatteryLevels == null
                                  ? "0"
                                  : showBatteryLevels.toString() + " %",
                              style: const TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ))
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.width * 0.4,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      batteryContainer(
                          70,
                          Icons.power,
                          40,
                          showBatteryLevels <= 20 ? COLOR_RED : COLOR_GREEN,
                          batteryState == BatteryState.charging ? true : false),
                      batteryContainer(
                          70,
                          Icons.power_off,
                          40,
                          showBatteryLevels <= 20 ? COLOR_RED : COLOR_GREEN,
                          batteryState == BatteryState.discharging
                              ? true
                              : false),
                      batteryContainer(
                          70,
                          Icons.battery_charging_full,
                          40,
                          showBatteryLevels <= 20 ? COLOR_RED : COLOR_GREEN,
                          batteryState == BatteryState.full ? true : false),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 15),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.width * 0.16,
                color: Color.fromARGB(40, 0, 0, 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        batteryState == BatteryState.charging
                            ? "Charging"
                            : batteryState == BatteryState.discharging
                                ? "Discharging"
                                : "Fully Charged",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(ChargeHistory.routeName);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 0.16,
                  color: Color.fromARGB(40, 0, 0, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Battery Charge History",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(NotificationSetter.routeName);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 0.16,
                  color: Color.fromARGB(40, 0, 0, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Notification Setter",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(UsageLastCharge.routeName);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 0.16,
                  color: Color.fromARGB(40, 0, 0, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Last Charge Usage",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(UsageLastWeek.routeName);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 0.16,
                  color: Color.fromARGB(40, 0, 0, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Last 7 Days",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  batteryContainer(double size, IconData icon, double iconSize, Color IconColor,
      bool hasGlow) {
    return Container(
      width: size,
      height: size,
      child: Icon(
        icon,
        size: iconSize,
        color: IconColor,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            hasGlow
                ? BoxShadow(
                    blurRadius: 20,
                    spreadRadius: 6,
                    offset: const Offset(0, 0),
                    color: IconColor)
                : BoxShadow(
                    blurRadius: 7,
                    spreadRadius: -5,
                    offset: const Offset(2, 2),
                    color: COLOR_GREY)
          ]),
    );
  }
}
