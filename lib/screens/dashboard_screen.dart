import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import '../models/entry_model.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Entry>('entries');
    final data = <String, int>{};

    for (var entry in box.values) {
      data.update(entry.gambit, (value) => value + entry.playerWounds,
          ifAbsent: () => entry.playerWounds);
    }

    final barGroups = data.entries
        .map((e) => BarChartGroupData(
              x: data.keys.toList().indexOf(e.key),
              barRods: [BarChartRodData(toY: e.value.toDouble(), width: 16)],
            ))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.keys.length) {
                    return Text(
                      data.keys.elementAt(index),
                      style: TextStyle(color: Colors.white),
                    );
                  } else {
                    return Text('');
                  }
                },
              ),
            ),
          ),
          barGroups: barGroups,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}