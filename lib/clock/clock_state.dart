import 'package:equatable/equatable.dart';

abstract class ClockState extends Equatable{
  @override
  List<Object> get props => [];
}

class ClockStateInit extends ClockState{

}

class ClockStateAddNotif extends ClockState{
  final DateTime date;

  ClockStateAddNotif({required this.date});

  @override
  List<Object> get props => [date];
}

class ClockStateCurrentAlarm extends ClockState{
  final String date;

  ClockStateCurrentAlarm({required this.date});

  @override
  List<Object> get props => [date];
}
