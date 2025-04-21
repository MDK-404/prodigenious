import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskProductivityChart extends StatelessWidget {
  final int done;
  final int todo;
  final int inProgress;
  final int terminated;
  final bool showLegend;

  const TaskProductivityChart({
    super.key,
    required this.done,
    required this.todo,
    required this.inProgress,
    required this.terminated,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    int total = done + todo + inProgress + terminated;
    double percent(int value) => total == 0 ? 0 : (value / total) * 100;

    final chartData = [
      {'label': 'Completed Tasks', 'value': done, 'color': Color(0xFF0CC302)},
      {
        'label': 'Terminated Tasks',
        'value': terminated,
        'color': Color(0xffFE0B0B)
      },
      {'label': 'In Progress', 'value': inProgress, 'color': Color(0xFF0B7CFE)},
      {'label': 'To Do', 'value': todo, 'color': Color(0xffFFCF0F)},
    ];

    chartData.sort((a, b) =>
        percent(b['value'] as int).compareTo(percent(a['value'] as int)));

    return Column(
      children: [
        SizedBox(height: 20),
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: [
                PieChartSectionData(
                  value: done.toDouble(),
                  color: Colors.green,
                  title: '',
                  radius: 80,
                ),
                PieChartSectionData(
                  value: terminated.toDouble(),
                  color: Colors.red,
                  title: '',
                  radius: 80,
                ),
                PieChartSectionData(
                  value: inProgress.toDouble(),
                  color: Colors.blue,
                  title: '',
                  radius: 80,
                ),
                PieChartSectionData(
                  value: todo.toDouble(),
                  color: Colors.yellow,
                  title: '',
                  radius: 80,
                ),
              ],
            ),
          ),
        ),
        if (showLegend) ...[
          SizedBox(height: 20),
          ...chartData.map((data) {
            int value = data['value'] as int;
            Color color = data['color'] as Color;
            double pct = percent(value);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: pct / 100,
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("${pct.toInt()}/100%"),
                ],
              ),
            );
          }).toList(),
        ]
      ],
    );
  }
}
