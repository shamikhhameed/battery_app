import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:battery_app/sql_helper.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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

  Color COLOR_RED = Colors.red;
  Color COLOR_GREEN = Colors.green;
  Color COLOR_GREY = Colors.grey;

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
                    margin: const EdgeInsets.all(7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text('Charger was connecetd at ' + _chargeHistory[index]['percentage'] + '%'),
                      // title: Transform.translate(
                      //   offset: const Offset(0, 0),
                      //   child: Text('Charger was connecetd at ' + _chargeHistory[index]['percentage'] + '%'),
                      // ),
                      // subtitle: Text('On ' + _chargeHistory[index]['createdAt'].split(' ')[0] + '\nAt ' + _chargeHistory[index]['createdAt'].split(' ')[1]),
                      subtitle: Transform.translate(
                        offset: const Offset(0, 2),
                        child: Text('On ' + _chargeHistory[index]['createdAt'].split(' ')[0] + '\nAt ' + _chargeHistory[index]['createdAt'].split(' ')[1]),
                      ),
                      isThreeLine: true,
                      trailing: Container(
                        // margin: const EdgeInsets.only(top: 50),
                        // width: MediaQuery.of(context).size.width * 0.5,
                        // height: MediaQuery.of(context).size.width * 0.3,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          // boxShadow: [
                          //   BoxShadow(
                          //       blurRadius: 5,
                          //       spreadRadius: 2,
                          //       offset: const Offset(0, 0),
                          //       // blurRadius: 7,
                          //       // spreadRadius: -5,
                          //       // offset: const Offset(4, 4),
                          //       color: COLOR_GREY
                          //       ),
                          // ]
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
                                      double.parse(_chargeHistory[index]['percentage']) <= 20 ? COLOR_RED : COLOR_GREEN,
                                  thicknessUnit: GaugeSizeUnit.factor),
                              pointers: <GaugePointer>[
                                RangePointer(
                                  value: double.parse(_chargeHistory[index]['percentage'].toString()),
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
                                          : _chargeHistory[index]['percentage'].toString(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    )
                                  )
                              ],
                            )
                          ],
                        ),
                      ),
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
      //test
    );
  }
}
