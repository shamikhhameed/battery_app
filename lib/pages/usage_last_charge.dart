import 'package:flutter/material.dart';

class UsageLastCharge extends StatefulWidget {
  static const String routeName = '/usageLastCharge';
  const UsageLastCharge({Key? key}) : super(key: key);

  @override
  _UsageLastChargeState createState() => _UsageLastChargeState();
}

class _UsageLastChargeState extends State<UsageLastCharge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Last Charge Usage"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            "details of the battery usage since the last charge - Sandini",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
