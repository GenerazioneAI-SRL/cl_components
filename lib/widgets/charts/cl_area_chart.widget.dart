import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../cl_theme.dart';

class CLAreaChart extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  CLAreaChart({super.key});

  @override
  CLAreaChartState createState() => CLAreaChartState();
}

class CLAreaChartState extends State<CLAreaChart> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    data = [
      _ChartData('CHN', 12),
      _ChartData('GER', 15),
      _ChartData('RUS', 30),
      _ChartData('BRZ', 6.4),
      _ChartData('IND', 14)
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
        tooltipBehavior: _tooltip,
        series: <CartesianSeries<_ChartData, String>>[
          AreaSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData data, _) => data.x,
              yValueMapper: (_ChartData data, _) => data.y,
              name: 'Gold',
              color: CLTheme.of(context).primary.withAlpha(121),)
        ]);
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}