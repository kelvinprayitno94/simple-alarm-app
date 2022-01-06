import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_alarm_app/clock/clock_state.dart';
import 'package:simple_alarm_app/clock/clock_view.dart';
import 'package:simple_alarm_app/core/shared_preferences_repository.dart';

import '../locator.dart';

final clockCubit = locator<ClockCubit>();

class ClockCubit extends Cubit<ClockState> {
  ClockCubit(ClockStateInit initialState) : super(initialState);

  addNotif(DateTime date) {
    var now = DateTime.now();

    if (date.compareTo(now) > 0) {
      debugPrint("date $date");
      emit(ClockStateAddNotif(date: date));
      sharedPreferencesRepository.setCurrentAlarm(date);
    } else {
      debugPrint(
          "date ${dateFormat.format(date.add(const Duration(days: 1)))}");
      emit(ClockStateAddNotif(date: date.add(const Duration(days: 1))));
      sharedPreferencesRepository
          .setCurrentAlarm(date.add(const Duration(days: 1)));
    }
  }

  checkList() async {
    var list = await sharedPreferencesRepository.getNotifDate();
    var diffList = await sharedPreferencesRepository.getNotifOpenedDate();

    debugPrint("data chart ${list[0]} - ${diffList[0]}");
  }

  getCurrentAlarm() async {
    var date = await sharedPreferencesRepository.getCurrentAlarm();
    emit(ClockStateCurrentAlarm(date: date));
  }

  Future<String> getCurrentAlarmForNotif() async {
    var pref = SharedPreferencesRepository();
    var date = await pref.getCurrentAlarm();
    return date;
  }

  removeCurrentAlarm() async {
    var pref = SharedPreferencesRepository();

    var isRemoved = await pref.removeCurrentAlarm();

    if (isRemoved) getCurrentAlarm();
  }
}
