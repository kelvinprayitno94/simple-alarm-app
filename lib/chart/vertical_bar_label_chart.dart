import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_alarm_app/chart/vertical_bar_label_chart_cubit.dart';
import 'package:simple_alarm_app/chart/vertical_bar_label_chart_state.dart';

class VerticalBarLabelChartView extends StatefulWidget {
  const VerticalBarLabelChartView({Key? key}) : super(key: key);

  final List<Color> availableColors = const [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

  @override
  _VerticalBarLabelChartViewState createState() =>
      _VerticalBarLabelChartViewState();
}

class _VerticalBarLabelChartViewState extends State<VerticalBarLabelChartView> {
  final Color barBackgroundColor = const Color(0xff72d8bf);

  // final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();

    verticalBarLabelChartCubit.getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            color: const Color(0xff81e5cd),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      const Text(
                        'Jumlah notifikasi yang dibuka, \n'
                            'dan perbedaan detik antara notifikasi muncul dan notifikasi dibuka',
                        style: TextStyle(
                            color: Color(0xff379982),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 38,
                      ),
                      BlocProvider(
                        create: (context) => verticalBarLabelChartCubit,
                        child: BlocBuilder<VerticalBarLabelChartCubit,
                            VerticalBarLabelChartState>(
                          builder: (context, state) {
                            if (state is VerticalBarLabelChartStateLoad) {
                              var list = state.listDate;
                              var notifOpenedDiff = state.notifOpenedDiff;

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: BarChart(mainBarData(
                                      list, notifOpenedDiff, state.maxY)),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.yellow.darken(), width: 1)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 20,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups(
      List<String> list, List<String> notifOpenedDiff) {
    List<BarChartGroupData> barChartList = [];

    var length = 0;

    if (list.length > 5) {
      length = 5;
    } else {
      length = list.length;
    }

    for (int x = 0; x < length; x++) {
      barChartList.add(makeGroupData(
        x, int.parse(notifOpenedDiff[x]).toDouble(),
        // isTouched: i == touchedIndex
      ));
    }

    return barChartList;
  }

  BarChartData mainBarData(
      List<String> list, List<String> notifOpenedDiff, int maxY) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                "Detik" + '\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.y - 1).toString(),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            return list[value.toInt()];
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(list, notifOpenedDiff),
      gridData: FlGridData(show: false),
    );
  }
}
