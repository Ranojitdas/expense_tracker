import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class ExpenseChart extends StatelessWidget {
  final List<Transaction> transactions;

  const ExpenseChart({super.key, required this.transactions});

  List<FlSpot> _createSpots(List<Transaction> transactions) {
    if (transactions.isEmpty) return [FlSpot(0, 0)];

    final sorted = transactions..sort((a, b) => a.date.compareTo(b.date));
    return List.generate(sorted.length, (index) {
      return FlSpot(index.toDouble(), sorted[index].amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    final incomes = transactions.where((t) => !t.isExpense).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _createSpots(expenses),
              isCurved: true,
              color: Theme.of(context).colorScheme.error,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: _createSpots(incomes),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
