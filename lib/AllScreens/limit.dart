import 'dart:math';

import 'package:battery_app/AllScreens/limit_list.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:app_usage/app_usage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:battery_app/utils/database_helper.dart';
import 'package:battery_app/models/applications.dart';

class Limit extends StatefulWidget {
  static const String idScreen = "/Limit";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LimitState();
  }
}

class LimitState extends State<Limit> {
  String app = "", hours = "";
  List list = [];
  TextEditingController note = TextEditingController();

  Future<List?> getUsageStats() async {
    try {
      double allTime = 0;
      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 24));
      List<AppUsageInfo> infoList =
          await AppUsage.getAppUsage(startDate, endDate);

      for (var info in infoList) {
        Map map = {
          "display": info.appName,
          "value": info.appName,
        };
        list.add(map);
      }
      return list;
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  void initState() {
    super.initState();
    this.getUsageStats().then((value) => {
          setState(() {
            list = value!;
          }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Limit App"),
        centerTitle: true,
      ),
      // backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => LimitList()),
      //     );
      //   },
      //   child: Icon(Icons.list),
      //   backgroundColor: Colors.green.shade600,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 35.0,
              ),
              Image(
                image: AssetImage("images/bt_logo.png"),
                width: 200.0,
                height: 200.0,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "Set Limit for Apps",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.0,
                    ),
                    DropDownFormField(
                      titleText: 'Device Applications',
                      hintText: 'Please choose one',
                      value: app,
                      onSaved: (value) {
                        setState(() {
                          app = value;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          app = value;
                        });
                      },
                      dataSource: list,
                      textField: 'display',
                      valueField: 'value',
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    DropDownFormField(
                      titleText: 'Limited Hours',
                      hintText: 'Please choose one',
                      value: hours,
                      onSaved: (value) {
                        setState(() {
                          hours = value;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          hours = value;
                        });
                      },
                      dataSource: [
                        {
                          "display": "1 hours",
                          "value": "1",
                        },
                        {
                          "display": "2 hours",
                          "value": "2",
                        },
                        {
                          "display": "3 hours",
                          "value": "3",
                        },
                        {
                          "display": "4 hours",
                          "value": "4",
                        },
                        {
                          "display": "5 hours",
                          "value": "5",
                        },
                        {
                          "display": "6 hours",
                          "value": "6",
                        },
                        {
                          "display": "7 hours",
                          "value": "7",
                        },
                        {
                          "display": "8 hours",
                          "value": "8",
                        },
                        {
                          "display": "9 hours",
                          "value": "9",
                        },
                        {
                          "display": "10 hours",
                          "value": "10",
                        },
                        {
                          "display": "11 hours",
                          "value": "11",
                        },
                        {
                          "display": "12 hours",
                          "value": "12",
                        },
                        {
                          "display": "13 hours",
                          "value": "13",
                        },
                        {
                          "display": "14 hours",
                          "value": "14",
                        },
                        {
                          "display": "15 hours",
                          "value": "15",
                        },
                        {
                          "display": "16 hours",
                          "value": "16",
                        },
                        {
                          "display": "17 hours",
                          "value": "17",
                        },
                        {
                          "display": "18 hours",
                          "value": "18",
                        },
                        {
                          "display": "19 hours",
                          "value": "19",
                        },
                        {
                          "display": "20 hours",
                          "value": "20",
                        },
                      ],
                      textField: 'display',
                      valueField: 'value',
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      cursorColor: Colors.white,
                      controller: note,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Note",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                          focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      color: Colors.white,
                      textColor: Colors.black,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Set Limit",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Brand Bold",
                                color: Colors.black),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: () {
                        if (app.isEmpty || app == "") {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.warning,
                            title: 'Oops...',
                            text: 'Select App!',
                            loopAnimation: false,
                          );
                        } else if (hours.isEmpty || hours == "") {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.warning,
                            title: 'Oops...',
                            text: 'Select Hours!',
                            loopAnimation: false,
                          );
                        } else if (note.text.isEmpty) {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.warning,
                            title: 'Oops...',
                            text: 'Note is Required!',
                            loopAnimation: false,
                          );
                        } else {
                          saveData();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveData() async {
    await DatabaseHelper()
        .insertApplications(Applications(
            appName: app,
            hours: int.parse(hours),
            note: note.text,
            id: Random().nextInt(100)))
        .then((res) => {
              setState(() {
                app = "";
                hours = "";
              }),
              note.text = ""
            })
        .whenComplete(() => CoolAlert.show(
              context: context,
              type: CoolAlertType.success,
              title: 'Successful',
              text: 'Insert Successful!',
              loopAnimation: false,
            ));
  }
}
