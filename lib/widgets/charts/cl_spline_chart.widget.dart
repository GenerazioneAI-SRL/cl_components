import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cl_components/cl_theme.dart';
import '../../models/user_graph_data.model.dart';

class CLSplineChart extends StatefulWidget {
  const CLSplineChart({super.key, required this.userChartData});

  final List<UserGraphData> userChartData;

  @override
  State<CLSplineChart> createState() => _CLSplineChartState();
}

class _CLSplineChartState extends State<CLSplineChart> {
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
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      series: <CartesianSeries>[
        SplineSeries<UserGraphData, String>(
          name: 'A',
          color: Colors.brown,
          splineType: SplineType.monotonic,
          dataSource: widget.userChartData,
          xValueMapper: (UserGraphData data, _) => data.key,
          yValueMapper: (UserGraphData data, _) => data.total,
        ),
        SplineSeries<UserGraphData, String>(
          name: 'B',
          splineType: SplineType.monotonic,
          color: Colors.amber,
          dataSource: widget.userChartData,
          xValueMapper: (UserGraphData data, _) => data.key,
          yValueMapper: (UserGraphData data, _) => data.value,
        ),
      ],
    );
  }
}
