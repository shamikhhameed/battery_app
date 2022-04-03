class Applications {
  int id=0;
  String appName="";
  String note="";
  int hours=0;

  Applications({required this.appName, required this.hours, required this.note,required this.id});

  Applications.withId(this.id, this.appName, this.hours, this.note);

  int get getId => this.id;

  String get getAppName => this.appName;

  String get getNote => this.note;

  int get getHours => this.hours;

  set setAppName(String value) {
    appName = value;
  }

  set setHours(int value) {
    hours = value;
  }

  set setNote(String value) {
    note = value;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['appName'] = appName;
    map['hours'] = hours;
    map['note'] = note;

    return map;
  }

  // Extract a Note object from a Map object
  Applications.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.appName = map['appName'];
    this.hours = map['hours'];
    this.note = map['note'];
  }

  @override
  String toString() {
    return 'application{id: $id, appName: $appName, hours: $hours, note: $note}';
  }

}
