import 'package:cl_components/cl_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CLBarChart extends StatefulWidget {
  const CLBarChart({super.key});

  @override
  State<CLBarChart> createState() => _CLBarChartState();
}

class _CLBarChartState extends State<CLBarChart> {
  int touchedIndex = -1;
  final _values = {
    "Gen": 60000,
    "Feb": 72000,
    "Mar": 25000,
    "Apr": 67000,
    "Mag": 80000,
    "Giu": 38000,
    "Lug": 63000,
    "Ago": 40000,
    "Set": 75000,
    "Ott": 36000,
    "Nov": 64000,
    "Dic": 45000,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Column(
          children: [
            const SizedBox(height: 24),
            Flexible(
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: 80100,
                  gridData: const FlGridData(drawVerticalLine: false, drawHorizontalLine: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      maxContentWidth: 240,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final date = (
                          groupIndex <= 0 ? _values.keys.toList()[groupIndex] : _values.keys.toList()[groupIndex - 1],
                          _values.keys.toList()[groupIndex],
                        );

                        final value = NumberFormat.simpleCurrency(decimalDigits: 0, locale: locale.countryCode).format(rod.toY);

                        return BarTooltipItem("${date.$1}-${date.$2} ${'Giugno'} 2024\n${'ritirato'}: $value", theme.textTheme.bodyMedium!);
                      },
                      getTooltipColor: (touchedSpot) {
                        return isDark ? theme.colorScheme.tertiaryContainer : Colors.white;
                      },
                    ),
                  ),
                  barGroups: List.generate(_values.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [BarChartRodData(toY: _values.values.toList()[index].toDouble(), color: CLTheme.of(context).success)],
                    );
                  }),
                  titlesData: FlTitlesData(
                    topTitles: _getTitlesData(context, show: false),
                    rightTitles: _getTitlesData(context, show: false),
                    leftTitles: _getTitlesData(
                      context,
                      reservedSize: 34,
                      interval: 20000,
                      getTitlesWidget: (value, titleMeta) {
                        const titlesMap = {0: '0', 20000: '20k', 40000: '40k', 60000: '60k', 80000: '80k'};

                        return Text(titlesMap[value.toInt()] ?? '', style: CLTheme.of(context).bodyText);
                      },
                    ),
                    bottomTitles: _getTitlesData(
                      context,
                      interval: 1,
                      reservedSize: 28,
                      getTitlesWidget: (value, titleMeta) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(top: 8),
                          child: Transform.rotate(
                            angle: size.width < 400 ? (-45 * (3.1416 / 180)) : 0,
                            child: Text(_values.keys.toList()[value.toInt()], style: CLTheme.of(context).bodyText),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  AxisTitles _getTitlesData(
    BuildContext context, {
    bool show = true,
    Widget Function(double value, TitleMeta titleMeta)? getTitlesWidget,
    double reservedSize = 22,
    double? interval,
  }) {
    return AxisTitles(
      sideTitles: SideTitles(showTitles: show, getTitlesWidget: getTitlesWidget ?? defaultGetTitle, reservedSize: reservedSize, interval: interval),
    );
  }
}
