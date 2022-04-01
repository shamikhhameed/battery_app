import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:app_usage/app_usage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:battery_app/utils/database_helper.dart';
import 'package:battery_app/models/applications.dart';

import 'limit_list.dart';

class LimitUpdate extends StatefulWidget {
  static const String idScreen = "LimitUpdate";

  final String id,appName,hours,note;
  LimitUpdate({required this.id,required this.appName,required this.hours,required this.note}) : super();

  // set parameters for edit
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LimitUpdateState(id,appName,hours,note);
  }
}

class LimitUpdateState extends State<LimitUpdate> {
  String app = "", hours = "",id,appName,hour,notes;
  List list = [];
  TextEditingController note = TextEditingController();

  LimitUpdateState(String this.id, String this.appName, String this.hour,String this.notes);

  // list device apps
  Future<List?> getUsageStats() async {
    try {
      double allTime = 0;
      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 24));
      List<AppUsageInfo> infoList =
          await AppUsage.getAppUsage(startDate, endDate);

      // insert list array
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
    setState(() {
      app=appName;
      hours=hour;
    });
    note.text = notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Limit App"),
        centerTitle: true,
      ),
      
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LimitList()),
          );
        },
        child: Icon(Icons.list),
        backgroundColor: Color.fromARGB(255, 5, 166, 50),
      ),
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
                "Update Limits",
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
                      controller: note,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Note",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
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
                            "Update Limit",
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

  // update data
  void saveData() async {
    await DatabaseHelper()
        .updateApplications(Applications(
            appName: app,
            hours: int.parse(hours),
            note: note.text,
            id:int.parse(id)
    ))
        .then((res) => {
          setState(() {app = "";
            hours = "";}),
          note.text = ""
        })
        .whenComplete(() => {CoolAlert.show(
              context: context,
              type: CoolAlertType.success,
              title: 'Successful',
              text: 'Insert Update!',
              loopAnimation: false,
            ),
        Navigator.pushNamedAndRemoveUntil(context, LimitList.idScreen, (route) => true)
        }
    );
  }
}
