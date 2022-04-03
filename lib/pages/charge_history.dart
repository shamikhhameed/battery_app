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
  List<Map<String, dynamic>> _chargeHistory = [];
  Battery battery = Battery();
  int showBatteryLevels = 0;
  BatteryState? batteryState;
  bool? broadcastBattery;

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshChargeHistory() async {
    final data = await SQLHelper.getItems();
    if (mounted) {
      setState(() {
      _chargeHistory = data;
      _isLoading = false;
    });
    }
  }
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
      if (mounted) {
        setState(() {
          batteryState = event;
      });
    }
    if (batteryState == BatteryState.charging) {
      _addOrUpdateItem();
      _deleteItem();
    }
    });
  }

  // Checks for the battery percentage every 5 seconds and sets the state accordingly
  _broadcastBatteryLevels() async {
    broadcastBattery = true;
    while (broadcastBattery!) {
      var batteryLvls = await battery.batteryLevel;
      if (mounted) {
      setState(() {
        showBatteryLevels = batteryLvls;
      });
    }
      await Future.delayed(Duration(seconds: 5));
    }
  }

  // Insert a new row to the database when the charger is connected
  Future<void> _addItem() async {
    var batteryLevel = await battery.batteryLevel;
    await SQLHelper.createItem(batteryLevel.toString());
    _refreshChargeHistory();
  }

  // Updates an existing record in the database
  Future<void> _updateItem() async {
    var batteryLevel = await battery.batteryLevel;
    await SQLHelper.updateItem(batteryLevel.toString());
    _refreshChargeHistory();
  }

  // Delete an existing record from the database
  void _deleteItem() async {
    await SQLHelper.deleteItem();
    _refreshChargeHistory();
  }

  // Adds a new record if a record does not exist for the particular date or else updates the record
  Future<void> _addOrUpdateItem() async {
    List<Map<String, dynamic>> data;
    data = await SQLHelper.getItem();
    if (data.isEmpty) {
      await _addItem();
    } else {
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
                subtitle: Transform.translate(
                  offset: const Offset(0, 2),
                  child: Text('On ' + _chargeHistory[index]['createdAt'].split(' ')[0] + '\nAt ' + _chargeHistory[index]['createdAt'].split(' ')[1]),
                ),
                isThreeLine: true,
                trailing: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
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
                            enableAnimation: true,
                            animationDuration: 1800,
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
            )
          ),
    );
  }
}
