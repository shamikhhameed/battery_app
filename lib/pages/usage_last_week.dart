import 'package:app_usage/app_usage.dart';
import 'package:battery_app/models/app_usage_data.dart';
import 'package:battery_app/pages/installed_apps.dart';
import 'package:battery_app/presistance/app_details.dart';
import 'package:battery_app/widgets/app_usage_card.dart';
import 'package:device_apps/device_apps.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:cool_alert/cool_alert.dart';

class UsageLastWeek extends StatefulWidget {
  static const String routeName = '/usageLastWeek';
  const UsageLastWeek({Key? key}) : super(key: key);

  @override
  _UsageLastWeekState createState() => _UsageLastWeekState();
}

class _UsageLastWeekState extends State<UsageLastWeek> {
  List<AppUsageInfo> appUsageInfoList = [];
  Duration totalUsage = Duration();

  @override
  void initState() {
    super.initState();
  }

  Future<List<AppUsageInfo>?> getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 7));
      appUsageInfoList = await AppUsage.getAppUsage(startDate, endDate);
      totalUsage = Duration();
      for (var item in appUsageInfoList) {
        totalUsage += item.usage;
      }
      return appUsageInfoList;
    } on AppUsageException catch (exception) {
      print(exception);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var db = Provider.of<MyDatabase>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Last 7 Days Usage"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () async {
              var result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return const AddEditApp();
                },
              );
              if (result is AppDetailsCompanion) {
                await db.createOrUpdateAppDetail(result);
              }
            },
            child: const Icon(Icons.add)),
        body: FutureBuilder(
            future: getUsageStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }
              return StreamBuilder<List<AppDetail>>(
                  stream: db.getAllApps,
                  builder: (context, snapshot) {
                    var data = snapshot.data;
                    if (data == null || data.isEmpty) {
                      return Center(
                          child: Container(
                        decoration: const BoxDecoration(color: Color.fromARGB(255, 12, 11, 10)),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: ListTile(
                            tileColor: Colors.red,
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add),
                              ],
                            ),
                            title: const Text('No apps added'),
                            onTap: () async {
                              var result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return const AddEditApp();
                                },
                              );
                              if (result is AppDetailsCompanion) {
                                await db.createOrUpdateAppDetail(result);
                              }
                            },
                            subtitle: const Text(
                                'Please click + button or click this card to add apps'),
                          ),
                        ),
                      ));
                    }
                    return Column(
                      children: [
                        Expanded(
                            child: ListView.separated(
                                padding: const EdgeInsets.only(
                                    top: 20, right: 18, left: 18, bottom: 100),
                                itemBuilder: (_, i) {
                                  double usageAsPresentage = 0;
                                  Duration usage = Duration();
                                  var app = data[i];
                                  try {
                                    var appdata = appUsageInfoList
                                        .where((element) =>
                                            element.packageName ==
                                            app.appPackageName)
                                        .first;
                                    var precentage = appdata.usage.inMinutes /
                                        totalUsage.inMinutes;
                                    usage = appdata.usage;
                                    if (precentage <= 1 && precentage >= 0) {
                                      usageAsPresentage = precentage;
                                    }
                                  } catch (e) {}

                                  return Slidable(
                                    endActionPane: ActionPane(
                                      openThreshold: 0.3,
                                      motion: ScrollMotion(),
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: SlidableAction(
                                                onPressed: (context) async {
                                                  await db
                                                      .deleteAppDetail(app.id);
                                                  CoolAlert.show(
                                                    context: context,
                                                    type: CoolAlertType.success,
                                                    title:
                                                        'Successfully Deleted',
                                                    loopAnimation: false,
                                                  );
                                                },
                                                backgroundColor: CupertinoColors
                                                    .destructiveRed,
                                                foregroundColor: Colors.white,
                                                icon: Icons.delete,
                                                label: 'Delete',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              var result =
                                                  await showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                builder:
                                                    (BuildContext context) {
                                                  return AddEditApp(
                                                    appData: AppUsageData(
                                                        appId: app.id,
                                                        appName: app.appName,
                                                        appPacakgeName:
                                                            app.appPackageName),
                                                  );
                                                },
                                              );
                                              if (result
                                                  is AppDetailsCompanion) {
                                                await db
                                                    .createOrUpdateAppDetail(
                                                        result);
                                              }
                                            },
                                            child: AppUsageCard(AppUsageData(
                                                appId: app.id,
                                                appName: app.appName,
                                                presentage: usageAsPresentage,
                                                appUsage: usage,
                                                appPacakgeName:
                                                    app.appPackageName)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (_, i) {
                                  return const SizedBox(
                                    height: 10,
                                  );
                                },
                                itemCount: data.length))
                      ],
                    );
                  });
            }));
  }
}

class AddEditApp extends StatefulWidget {
  const AddEditApp({
    this.appData,
    Key? key,
  }) : super(key: key);

  final AppUsageData? appData;

  @override
  State<AddEditApp> createState() => _AddEditAppState();
}

class _AddEditAppState extends State<AddEditApp> {
  final TextEditingController _appName = TextEditingController();
  final TextEditingController _appPacakgeName = TextEditingController();

  int? appId;

  @override
  void initState() {
    _appName.text = widget.appData?.appName ?? '';
    _appPacakgeName.text = widget.appData?.appPacakgeName ?? '';
    appId = widget.appData?.appId;
    super.initState();
  }

  @override
  void dispose() {
    _appName.dispose();
    _appPacakgeName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () async {
                var _selectedApp = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => InstalledApps()));
                if (_selectedApp is Application) {
                  _appPacakgeName.text = _selectedApp.packageName;
                  _appName.text = _selectedApp.appName;
                }
              },
              child: TextFormField(
                controller: _appPacakgeName,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select App',
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            TextFormField(
              controller: _appName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'App Name',
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
                child:
                    Text(widget.appData == null ? 'Add Application' : 'Update'),
                onPressed: () async {
                  if (_appName.text.isNotEmpty &&
                      _appPacakgeName.text.isNotEmpty) {
                    var data = AppDetailsCompanion(
                        id: appId != null
                            ? drift.Value(appId!)
                            : const drift.Value.absent(),
                        appName: drift.Value(_appName.text),
                        appPackageName: drift.Value(_appPacakgeName.text));
                    Navigator.pop(context, data);
                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.success,
                      title: 'Successful',
                      text: 'Application added!',
                      loopAnimation: false,
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.white, onPrimary: Colors.black))
          ],
        ),
      ),
    );
  }
}
