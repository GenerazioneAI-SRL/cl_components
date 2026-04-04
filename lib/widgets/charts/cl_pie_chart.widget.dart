import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cl_components/models/city_graph_data.model.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';

class CLPieChart extends StatefulWidget {
  const CLPieChart({super.key, required this.data});

  final List<CityGraphData> data;

  @override
  CLPieChartState createState() => CLPieChartState();
}

class CLPieChartState extends State<CLPieChart> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.left,
        textStyle: CLTheme.of(context).smallText.copyWith(fontSize: 12),
      ),
      tooltipBehavior: _tooltip,
      margin: EdgeInsets.all(Sizes.padding),
      series: <CircularSeries<CityGraphData, String>>[
        DoughnutSeries<CityGraphData, String>(
          pointColorMapper: (CityGraphData data, _) => CLTheme.of(context).generateColorFromText(data.key),
          animationDuration: 300,
          explode: true,
          explodeIndex: 0,
          dataSource: widget.data,
          xValueMapper: (CityGraphData data, _) => data.key,
          yValueMapper: (CityGraphData data, _) => data.value,
          radius: '70%',
        ),
      ],
    );
  }
}
