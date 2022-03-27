import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InstalledApps extends StatefulWidget {
  const InstalledApps({Key? key}) : super(key: key);

  @override
  State<InstalledApps> createState() => _InstalledAppsState();
}

class _InstalledAppsState extends State<InstalledApps> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select App'),
      ),
      body: FutureBuilder<List<Application>>(
          future: DeviceApps.getInstalledApplications(
              includeAppIcons: true,
              onlyAppsWithLaunchIntent: true,
              includeSystemApps: true),
          builder: (_, snapshot) {
            var data = snapshot.data;
            if (data == null) {
              return Center(
                child: CupertinoActivityIndicator(),
              );
            } else if (data.isEmpty) {
              return Center(
                child: Text('No apps detected or permission not granted'),
              );
            } else {
              return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (_, i) {
                    return ListTile(
                        onTap: () {
                          Navigator.pop(context, data[i]);
                        },
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.apps),
                          ],
                        ),
                        title: Text(data[i].appName),
                        subtitle: Text(data[i].packageName));
                  },
                  separatorBuilder: (_, i) {
                    return SizedBox(
                      height: 10,
                    );
                  },
                  itemCount: snapshot.data?.length ?? 0);
            }
          }),
    );
  }
}
