import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_alarm_app/clock/clock_view.dart';

import '../locator.dart';

const String date_list = 'DateList';
const String current_alarm = 'CurrentAlarm';
const String notif_opened_date = 'NotifOpenedDate';

final sharedPreferencesRepository = locator<SharedPreferencesRepository>();

class SharedPreferencesRepository {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> addNotifDate(String date) async {
    final SharedPreferences prefs = await _prefs;

    var list = await getNotifDate();
    list.add(date);

    var _result = prefs.setStringList(date_list, list);

    return _result;
  }

  Future<List<String>> getNotifDate()async{
    final SharedPreferences prefs = await _prefs;
    var list = prefs.getStringList(date_list) ?? [];
    debugPrint("all notif $list");
    return list;
  }

  Future<bool> addNotifOpenedDate(int compare) async {
    final SharedPreferences prefs = await _prefs;

    var list = await getNotifOpenedDate();
    list.add(compare.toString());

    var _result = prefs.setStringList(notif_opened_date, list);

    return _result;
  }

  Future<List<String>> getNotifOpenedDate()async{
    final SharedPreferences prefs = await _prefs;
    var list = prefs.getStringList(notif_opened_date) ?? [];
    debugPrint("all notif opened date $list");
    return list;
  }

  Future<void> setCurrentAlarm(date) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(current_alarm, dateFormat.format(date));
  }

  Future<String> getCurrentAlarm() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(current_alarm) ?? "-";
  }

  Future<bool> removeCurrentAlarm() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.remove(current_alarm);
  }
}
