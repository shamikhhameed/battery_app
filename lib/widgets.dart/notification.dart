import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//NOTIFICATION PLUGIN

//Create an instance of Local notifications
void sendNotification({String? title, String? body}) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

//Set the settings for various platforms
  // Initialise the plugin
  //For the Android Initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  //For the IOS Initialization
  const IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: true,
          requestSoundPermission: true,
          requestBadgePermission: true);

  //For the Linux Initialization
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'hello');

  //Initialize and register the settings
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      linux: initializationSettingsLinux);

  //Initialize the flutter notifications (package)
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  //Register the notification channel to the Android device
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high channel', 'High Importance notification',
      description: "This channel is used for important notifications",
      importance: Importance.max);

  //Sends the notification
  flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description)),
  );
}
