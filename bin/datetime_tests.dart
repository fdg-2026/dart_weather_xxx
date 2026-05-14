import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  var now = DateTime.now();
  print("now: $now");
  var nowInUtc = now.toUtc();
  print("nowInUtc: $nowInUtc");
  var backToLocal = nowInUtc.toLocal();
  print("backToLocal: $backToLocal");

  assert(now.isUtc == false);
  assert(nowInUtc.isUtc == true);
  assert(backToLocal.isUtc == false);

  var parsed = DateTime.parse("2026-03-22T00:00");
  print("parsed: $parsed");
  assert(parsed.isUtc == false);

  var parsedZ = DateTime.parse("2026-03-22T00:00Z");
  print("parsedZ: $parsedZ");
  assert(parsedZ.isUtc == true);

  // DST winter -> summer :

  var winSomInUTC = DateTime.parse("2026-03-29T00:00Z");
  for (int i = 0; i < 6; i++) {
    var dt = winSomInUTC.add(Duration(hours: i));
    print("DateTime in UTC: $dt");
  }

  var winSomLocal = winSomInUTC.toLocal();
  for (int i = 0; i < 6; i++) {
    var dt = winSomLocal.add(Duration(hours: i));
    print("DateTime local: $dt");
  }

  tz.initializeTimeZones();
  var timezoneName = "Europe/Berlin";
  final tzLocation = tz.getLocation(timezoneName);
  var winSomTZ = tz.TZDateTime.from(winSomInUTC, tzLocation);
  for (int i = 0; i < 6; i++) {
    var dt = winSomTZ.add(Duration(hours: i));
    print("with TZDateTime: $dt");
  }

  // the "Unix Epoch"

  print("now.microsecondsSinceEpoch: ${now.microsecondsSinceEpoch}");
  print("nowInUtc.microsecondsSinceEpoch: ${nowInUtc.microsecondsSinceEpoch}");
  var dtEpoch = DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true);
  print("dtEpoch: $dtEpoch");
  var dDay = DateTime.utc(1944, 6, 6);
  print("dday.microsecondsSinceEpoch: ${dDay.microsecondsSinceEpoch}");

  // max micro seconds:         8,640,000,000,000,000,000
  // 24*3600*1000*1000 (1 day): 86,400,000,000
  // max int native (64bit):    9,223,372,036,854,775,807 = 2^63 - 1

  var microsec = 8640000000000000000 - 86400000000;
  var test = DateTime.fromMicrosecondsSinceEpoch(microsec, isUtc: true);
  print(test); // 275760-09-12 00:00:00.000Z

  test = test.add(Duration(days: 1));
  print(test); // 275760-09-13 00:00:00.000Z

  //test = test.add(Duration(days: 1)); // RangeError

  test = DateTime(275760);
  print(test); // 275760-01-01 00:00:00.000

  //test = DateTime(275761); // ArgumentError
  //test = DateTime(312000); // ArgumentError

  // Strange: following line does not throw Exception
  test = DateTime(313000);
  print(test); // -271555-12-13 15:58:10.448384
}
