import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:battery_app/sql_helper.dart';

class ChargeHistory extends StatefulWidget {
  static const String routeName = '/chargeHistory';
  const ChargeHistory({Key? key}) : super(key: key);

  @override
  _ChargeHistoryState createState() => _ChargeHistoryState();
}

class _ChargeHistoryState extends State<ChargeHistory> {
  //all charge history details
  List<Map<String, dynamic>> _chargeHistory = [];
  Battery battery = Battery();
  int showBatteryLevels = 0;
  BatteryState? batteryState;
  bool? broadcastBattery;

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshChargeHistory() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _chargeHistory = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _deleteItem();
    _refreshChargeHistory();
    _broadcastBatteryLevels();
    battery.onBatteryStateChanged.listen((event) {
      setState(() {
        batteryState = event;
      });
      print('Battery state change detected');
      // () async {
      if (batteryState == BatteryState.charging) {
        // _addItem();
        _addOrUpdateItem();
        _deleteItem();
        print('DB Updated - charger connected');
      }
      // };
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

  // Insert a new charge data to the database
  Future<void> _addItem() async {
    var batteryLevel = await battery.batteryLevel;
    await SQLHelper.createItem(batteryLevel.toString());
    _refreshChargeHistory();
  }

  //Update an existing journal
  Future<void> _updateItem() async {
    var batteryLevel = await battery.batteryLevel;
    await SQLHelper.updateItem(batteryLevel.toString());
    _refreshChargeHistory();
  }

  // Delete an item
  void _deleteItem() async {
    await SQLHelper.deleteItem();
    _refreshChargeHistory();
  }

  Future<void> _addOrUpdateItem() async {
    var data;
    print(data == null
        ? 'data before getItem = NULL'
        : 'data before getItem = ' + data.toString());
    data = await SQLHelper.getItem();
    print(data == null
        ? 'data after getItem = NULL'
        : 'data after getItem = ' + data.toString());
    // print('data after getItem ' + data);
    if (data.isEmpty) {
      print('saying data NULL');
      await _addItem();
    } else {
      print('saying data NOT NULL');
      await _updateItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Charge History"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _chargeHistory.length,
              itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                      title: Text(_chargeHistory[index]['percentage']),
                      subtitle: Text(_chargeHistory[index]['createdAt']),
                    ),
                  )),
      // Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: const [
      //     Text(
      //       "Charge History including charging details of past 10 days - Shamikh",
      //       textAlign: TextAlign.center,
      //     )
      //   ],
      // ),
    );
  }
}
