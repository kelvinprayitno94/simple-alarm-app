import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_alarm_app/chart/vertical_bar_label_chart_state.dart';
import 'package:simple_alarm_app/core/shared_preferences_repository.dart';

import '../locator.dart';

final verticalBarLabelChartCubit = locator<VerticalBarLabelChartCubit>();

class VerticalBarLabelChartCubit extends Cubit<VerticalBarLabelChartState> {
  VerticalBarLabelChartCubit(VerticalBarLabelChartStateInit initialState)
      : super(initialState);

  getList() async {
    var list = await sharedPreferencesRepository.getNotifDate();
    var notifOpenedDiff =
        await sharedPreferencesRepository.getNotifOpenedDate();

    var max = 0;

    for (var element in notifOpenedDiff) {
      if (max < int.parse(element)) {
        max = int.parse(element);
      }
    }

    emit(VerticalBarLabelChartStateLoad(
        listDate: list.reversed.toList(),
        notifOpenedDiff: notifOpenedDiff.reversed.toList(),
        maxY: max));
  }
}
