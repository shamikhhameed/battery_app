import 'dart:async';
import 'package:battery_app/sql_helper.dart';
import 'package:battery_app/widgets/notification.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:flutter/material.dart';

class NotificationSetter extends StatefulWidget {
  static const String routeName = '/notificationSetter';
  const NotificationSetter({Key? key}) : super(key: key);

  @override
  State<NotificationSetter> createState() => _NotificationSetterState();
}

class _NotificationSetterState extends State<NotificationSetter> {
  // late final BatteryDB _crudStorage;
  late final SQLHelper _crudStorage;

  Timer? timer;
  int _batteryLevel = 0;
  List<Battery> _batteryList = [];

  @override
  void initState() {
    // _crudStorage = BatteryDB(dbName: 'db.sqlite');
    _crudStorage = SQLHelper(dbName: 'batteryapp2.db');
    _crudStorage.open();
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _crudStorage.close();
    timer?.cancel();
    super.dispose();
  }

  // Start Timer
  startTimer() {
    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => checkBatteryLevel());
  }

  // Get battery level as a int value
  checkBatteryLevel() {
    checkAlerts();
    BatteryInfoPlugin().androidBatteryInfoStream.listen((data) {
      _batteryLevel = data!.batteryLevel!;
    });
  }

  // Check that alert available to display
  checkAlerts() {
    if (_batteryList
        .any((p) => (p.batteryLevel == _batteryLevel && p.isTriggered == 0))) {
      timer?.cancel();
      Battery t =
          _batteryList.firstWhere((el) => el.batteryLevel == _batteryLevel);

      return sendNotification(
          title: "Battery Alert", body: " Battery level ${t.batteryLevel} %");
    }
  }

//   void test()  async{
  @override
  Widget build(BuildContext context) {
    // test();
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text("Battery Alert"),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: _crudStorage.all(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.waiting:
                if (snapshot.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final batteryinfo = snapshot.data as List<Battery>;
                _batteryList = batteryinfo;

                return Column(
                  children: [
                    ComposeWidget(
                      onCompose: (batteryLevel) async {
                        await _crudStorage.create(batteryLevel, 0);
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.only(
                              top: 10, right: 10, left: 10, bottom: 100),
                          itemCount: batteryinfo.length,
                          itemBuilder: (context, index) {
                            final battery = batteryinfo[index];
                            return Card(
                              elevation: 5,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    onTap: () async {
                                      final editedBattery =
                                          await showUpdateDialog(
                                        context,
                                        battery,
                                      );
                                      if (editedBattery != null) {
                                        await _crudStorage
                                            .update(editedBattery);
                                      }
                                    },
                                    title: const Text('Battery Alert'),
                                    subtitle: Text(
                                        'Battery Level:${battery.batteryLevel}'),
                                    trailing: TextButton(
                                      onPressed: () async {
                                        final shouldDelete =
                                            await showDeleteDialog(context);

                                        if (shouldDelete) {
                                          await _crudStorage.delete(battery);
                                        }
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),

                                    //
                                  ),
                                  const Divider(),
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                );

              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          }),
    );
  }
}

Future<bool> showDeleteDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  ).then((value) {
    if (value is bool) {
      return value;
    } else {
      return false;
    }
  });
}

final _batteryLevelController = TextEditingController();

Future<Battery?> showUpdateDialog(BuildContext context, Battery battery) {
  _batteryLevelController.text = battery.batteryLevel.toString();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update battery level:'),
            TextField(controller: _batteryLevelController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final editedBattery = Battery(
                  id: battery.id,
                  batteryLevel: int.parse(
                    _batteryLevelController.text,
                  ),
                  isTriggered: 0);
              Navigator.of(context).pop(editedBattery);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  ).then((value) {
    if (value is Battery) {
      return value;
    } else {
      return null;
    }
  });
}

typedef OnCompose = void Function(int batteryLevel); //callback definition

class ComposeWidget extends StatefulWidget {
  final OnCompose onCompose;
  const ComposeWidget({Key? key, required this.onCompose}) : super(key: key);

  @override
  State<ComposeWidget> createState() => _ComposeWidgetState();
}

class _ComposeWidgetState extends State<ComposeWidget> {
  late final TextEditingController _batteryLevelContraller;

  @override
  void initState() {
    _batteryLevelContraller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _batteryLevelContraller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
            controller: _batteryLevelContraller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter battery level',
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              //focusColor: Color.fromARGB(255, 28, 114, 114),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
              onPressed: () {
                final batteryLevel = int.parse(_batteryLevelContraller.text);
                //final batteryLevel = int.parse("30");
                widget.onCompose(batteryLevel);

                _batteryLevelContraller.text = '';
              },
              child: const Text(
                'Add alert',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }
}

class Battery implements Comparable {
  final int id;
  final int batteryLevel;
  final int isTriggered;

  const Battery({
    required this.id,
    required this.batteryLevel,
    required this.isTriggered,
  });

  Battery.fromRow(Map<String, Object?> row)
      : id = row['ID'] as int,
        batteryLevel =
            row['BATTERY_LEVEL'] == null ? 0 : row['BATTERY_LEVEL'] as int,
        isTriggered =
            row['IS_TRIGGERED'] == null ? 0 : row['IS_TRIGGERED'] as int;

  @override
  int compareTo(covariant Battery other) => other.id.compareTo(id);

  @override
  bool operator ==(covariant Battery other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Battery,id = $id, batteryLevel: $batteryLevel, isTriggered: $isTriggered';
}
