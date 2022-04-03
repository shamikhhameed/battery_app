import 'package:battery_app/AllScreens/limit_update.dart';
import 'package:flutter/material.dart';
import 'package:battery_app/AllScreens/limit.dart';
import 'package:battery_app/utils/database_helper.dart';
import 'package:battery_app/models/applications.dart';
import 'package:animated_button/animated_button.dart';

class LimitList extends StatefulWidget {
  static const String idScreen = "LimitList";

  @override
  State<LimitList> createState() => _LimitListState();
}

class _LimitListState extends State<LimitList> {
  late DatabaseHelper helper;
  List list = [];

  @override
  void initState() {
    super.initState();
    helper = DatabaseHelper();
    helper.initializeDB().whenComplete(() async {
      this.getList().then((value) => {
            setState(() {
              list = value!;
            }),
            print(value)
          });
    });
  }

  Future<List?> getList() async {
    List<Applications> limitList = await helper.applicationsList();
    for (var app in limitList) {
      Map map = {
        "id": app.id,
        "appName": app.appName,
        "hours": app.hours,
        "note": app.note,
      };
      list.add(map);
    }
    return list;
  }

  Future<void> _onRefresh() async {
    this.getList().then((value) => {
          setState(() {
            list = value!;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Limit Apps List'),
        centerTitle: true,
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => Limit()),
      //     );
      //   },
      //   child: Icon(Icons.add),
      //   backgroundColor: Colors.white,
      // ),
      body: Padding(padding: const EdgeInsets.all(20.0), child: limitApps()),
    );
  }

  Widget limitApps() {
    return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("App Name : " + list[index]['appName']),
                subtitle: Text("Limit Hours:" +
                    list[index]['hours'].toString() +
                    "| Note:" +
                    list[index]['note'].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: CircleBorder(),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LimitUpdate(
                                  id: list[index]['id'].toString(),
                                  appName: list[index]['appName'].toString(),
                                  hours: list[index]['hours'].toString(),
                                  note: list[index]['note'].toString()),
                            ));
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: CircleBorder(),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await helper.deleteApplications(list[index]['id']);
                        setState(() {
                          list.remove(list[index]);
                        });
                      },
                    ),
                  ],
                ),
              );
            }));
  }
}
