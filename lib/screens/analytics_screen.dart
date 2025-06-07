import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/time_filter_chip.dart';
import '../widgets/custom_app_bar.dart';
import 'dart:math' as math;
import 'home_screen.dart';
import 'history_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  TimeFilter _selectedFilter = TimeFilter.monthly;
  NavItem _selectedNavItem = NavItem.analytics;

  void _onNavItemSelected(NavItem item) {
    if (item == _selectedNavItem) return;

    setState(() {
      _selectedNavItem = item;
    });

    switch (item) {
      case NavItem.home:
        Navigator.pop(context);
        break;
      case NavItem.history:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HistoryScreen(),
            fullscreenDialog: true,
          ),
        );
        break;
      case NavItem.analytics:
        // Already on analytics screen
        break;
      case NavItem.profile:
        // Handle profile navigation if needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<TransactionProvider>(
                  builder: (context, provider, child) {
                    final transactions = provider.transactions;
                    final filteredTransactions =
                        _filterTransactions(transactions);
                    final totalIncome = filteredTransactions
                        .where((t) => !t.isExpense)
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final totalExpense = filteredTransactions
                        .where((t) => t.isExpense)
                        .fold(0.0, (sum, t) => sum + t.amount);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Filter Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getFilterIcon(_selectedFilter),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getFilterLabel(_selectedFilter),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              DropdownButton<TimeFilter>(
                                value: _selectedFilter,
                                underline: const SizedBox(),
                                items:
                                    TimeFilter.values.map((TimeFilter filter) {
                                  return DropdownMenuItem<TimeFilter>(
                                    value: filter,
                                    child: Row(
                                      children: [
                                        Icon(_getFilterIcon(filter)),
                                        const SizedBox(width: 8),
                                        Text(_getFilterLabel(filter)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (TimeFilter? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedFilter = newValue;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Income',
                                totalIncome,
                                Icons.arrow_upward,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                'Expense',
                                totalExpense,
                                Icons.arrow_downward,
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Expense Distribution Chart
                        Text(
                          'Expense Distribution',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: _buildExpenseDistributionChart(
                            filteredTransactions,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Income vs Expense Chart
                        Text(
                          'Income vs Expense',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: _buildIncomeExpenseChart(filteredTransactions),
                        ),
                        const SizedBox(height: 24),

                        // Top Expenses
                        Text(
                          'Top Expenses',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildTopExpensesList(filteredTransactions),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(
                locale: 'en_IN',
                symbol: '₹',
                decimalDigits: 0,
              ).format(amount),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseDistributionChart(List<Transaction> transactions) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    final categories = <String, double>{};

    for (var expense in expenses) {
      categories[expense.category] =
          (categories[expense.category] ?? 0) + expense.amount;
    }

    final total = categories.values.fold(0.0, (sum, amount) => sum + amount);
    final sections = categories.entries.map((entry) {
      final percentage = (entry.value / total * 100).round();
      return PieChartSectionData(
        value: entry.value,
        title: '$percentage%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: 40, sectionsSpace: 2),
    );
  }

  Widget _buildIncomeExpenseChart(List<Transaction> transactions) {
    final days = _selectedFilter == TimeFilter.daily ? 7 : 30;
    final now = DateTime.now();
    final data = List.generate(days, (index) {
      final date = now.subtract(Duration(days: days - 1 - index));
      final dayTransactions = transactions.where((t) {
        final tDate = t.date;
        return tDate.year == date.year &&
            tDate.month == date.month &&
            tDate.day == date.day;
      });

      return {
        'date': date,
        'income': dayTransactions
            .where((t) => !t.isExpense)
            .fold(0.0, (sum, t) => sum + t.amount),
        'expense': dayTransactions
            .where((t) => t.isExpense)
            .fold(0.0, (sum, t) => sum + t.amount),
      };
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.fold(
              0.0,
              (max, item) => math.max(
                max,
                math.max(item['income'] as double, item['expense'] as double),
              ),
            ) *
            1.2,
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item['income'] as double,
                color: Colors.green,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: item['expense'] as double,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length) return const SizedBox();
                final date = data[value.toInt()]['date'] as DateTime;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('d').format(date),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildTopExpensesList(List<Transaction> transactions) {
    final expenses = transactions.where((t) => t.isExpense).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return Column(
      children: expenses.take(5).map((expense) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(expense.title),
            subtitle: Text(expense.category),
            trailing: Text(
              NumberFormat.currency(
                locale: 'en_IN',
                symbol: '₹',
                decimalDigits: 0,
              ).format(expense.amount),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    return transactions.where((t) {
      final date = t.date;
      switch (_selectedFilter) {
        case TimeFilter.daily:
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case TimeFilter.monthly:
          return date.year == now.year && date.month == now.month;
        case TimeFilter.yearly:
          return date.year == now.year;
      }
    }).toList();
  }

  String _getFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.daily:
        return 'Daily';
      case TimeFilter.monthly:
        return 'Monthly';
      case TimeFilter.yearly:
        return 'Yearly';
    }
  }

  IconData _getFilterIcon(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.daily:
        return Icons.calendar_today;
      case TimeFilter.monthly:
        return Icons.calendar_month;
      case TimeFilter.yearly:
        return Icons.calendar_view_month;
    }
  }
}
