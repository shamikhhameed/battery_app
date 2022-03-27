import 'package:battery_app/models/app_usage_data.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AppUsageCard extends StatefulWidget {
  const AppUsageCard(this.appUsageData, {Key? key}) : super(key: key);

  final AppUsageData appUsageData;

  @override
  State<AppUsageCard> createState() => _AppUsageCardState();
}

class _AppUsageCardState extends State<AppUsageCard> {
  @override
  Widget build(BuildContext context) {
    var _packageName = widget.appUsageData.appPacakgeName;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.black54),
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        Row(
          children: [
            if (_packageName != null)
              FutureBuilder<Application?>(
                  future: DeviceApps.getApp(_packageName, true),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CircleAvatar(
                        child: Image.memory(
                            (snapshot.data as ApplicationWithIcon).icon),
                      );
                    }
                    return CircleAvatar(
                      child: Icon(Icons.abc_outlined),
                    );
                    ;
                  }),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.appUsageData.appName}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('${widget.appUsageData.appPacakgeName}'),
                  ),
                ],
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: LinearPercentIndicator(
                  animation: true,
                  lineHeight: 20.0,
                  animationDuration: 2500,
                  percent: widget.appUsageData.presentage ?? 0,
                  center: Text(
                      "${(widget.appUsageData.presentage ?? 0 * 100).toStringAsFixed(2)}%"),
                  barRadius: const Radius.circular(10),
                  progressColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
        Text(
            "${widget.appUsageData.appUsage?.inHours} hours ${widget.appUsageData.appUsage?.inMinutes.remainder(60)} minutes")
      ]),
    );
  }
}
