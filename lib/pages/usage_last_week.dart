import 'package:flutter/material.dart';

class UsageLastWeek extends StatefulWidget {
  static const String routeName = '/usageLastWeek';
  const UsageLastWeek({Key? key}) : super(key: key);

  @override
  _UsageLastWeekState createState() => _UsageLastWeekState();
}

class _UsageLastWeekState extends State<UsageLastWeek> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Last 7 Days"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            "details of the battery usage hours durng last 7 days - Nethmi",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
