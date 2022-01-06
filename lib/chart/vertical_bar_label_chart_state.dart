import 'package:equatable/equatable.dart';

abstract class VerticalBarLabelChartState extends Equatable {
  @override
  List<Object> get props => [];
}

class VerticalBarLabelChartStateInit extends VerticalBarLabelChartState {}

class VerticalBarLabelChartStateLoad extends VerticalBarLabelChartState {
  final List<String> listDate;
  final List<String> notifOpenedDiff;
  final int maxY;

  VerticalBarLabelChartStateLoad({required this.listDate,
    required this.notifOpenedDiff,
    required this.maxY});

  @override
  List<Object> get props => [listDate, notifOpenedDiff, maxY];
}
