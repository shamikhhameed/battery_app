import 'package:flutter/material.dart';

class NotificationSetter extends StatefulWidget {
  static const String routeName = '/notificationSetter';
  const NotificationSetter({Key? key}) : super(key: key);

  @override
  _NotificationSetterState createState() => _NotificationSetterState();
}

class _NotificationSetterState extends State<NotificationSetter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Setter"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            "Set desired battery percentage to recieve low battery notification - Shey",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
