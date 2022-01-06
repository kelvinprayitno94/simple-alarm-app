import 'package:get_it/get_it.dart';
import 'package:simple_alarm_app/chart/vertical_bar_label_chart_cubit.dart';
import 'package:simple_alarm_app/chart/vertical_bar_label_chart_state.dart';
import 'package:simple_alarm_app/clock/clock_cubit.dart';
import 'package:simple_alarm_app/clock/clock_state.dart';

import 'core/shared_preferences_repository.dart';
import 'localnotification/notification_service.dart';

GetIt locator = GetIt.I;

void setupLocator() {
  locator.registerLazySingleton<ClockCubit>(() => ClockCubit(ClockStateInit()));
  locator.registerLazySingleton<VerticalBarLabelChartCubit>(
      () => VerticalBarLabelChartCubit(VerticalBarLabelChartStateInit()));
  locator
      .registerLazySingleton<NotificationService>(() => NotificationService());
  locator.registerLazySingleton<SharedPreferencesRepository>(
      () => SharedPreferencesRepository());
}
