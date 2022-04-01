import 'package:battery_app/pages/charge_history.dart';
import 'package:battery_app/pages/home_page.dart';
import 'package:battery_app/pages/notification_setter.dart';
import 'package:battery_app/pages/limit_apps.dart';
import 'package:battery_app/pages/usage_last_week.dart';
import 'package:battery_app/presistance/app_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => MyDatabase(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        initialRoute: HomePage.routeName,
        routes: {
          HomePage.routeName: (context) => const HomePage(),
          ChargeHistory.routeName: (context) => const ChargeHistory(),
          NotificationSetter.routeName: (context) => const NotificationSetter(),
          BatteryPage.routeName: (context) => BatteryPage(),
          UsageLastWeek.routeName: (context) => const UsageLastWeek()
        },
      ),
    );
  }
}
