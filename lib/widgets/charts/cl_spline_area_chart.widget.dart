import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cl_components/cl_theme.dart';
import '../../models/user_graph_data.model.dart';

class CLSplineAreaChart extends StatefulWidget {
  const CLSplineAreaChart({super.key, required this.userChartData});

  final List<UserGraphData> userChartData;

  @override
  State<CLSplineAreaChart> createState() => _CLSplineAreaChartState();
}

class _CLSplineAreaChartState extends State<CLSplineAreaChart> {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(labelPlacement: LabelPlacement.onTicks),

        legend: Legend(
            position: LegendPosition.top,
            isResponsive: true,
            isVisible: true,
            textStyle: CLTheme.of(context).smallText.copyWith(fontSize: 12),
            overflowMode: LegendItemOverflowMode.wrap),
        series: <CartesianSeries>[
          SplineAreaSeries<UserGraphData, String>(
              name: 'Totali',
              color: Colors.purple.shade300,
              splineType: SplineType.monotonic,
              dataSource: widget.userChartData,
              xValueMapper: (UserGraphData data, _) => data.key,
              yValueMapper: (UserGraphData data, _) => data.total),
          SplineAreaSeries<UserGraphData, String>(
              name: 'Nuove',
              splineType: SplineType.monotonic,
              color: Colors.redAccent.shade100,
              dataSource: widget.userChartData,
              xValueMapper: (UserGraphData data, _) => data.key,
              yValueMapper: (UserGraphData data, _) => data.value),
        ]);
  }
}
