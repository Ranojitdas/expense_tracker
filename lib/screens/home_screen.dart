import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/transaction_item.dart';
import '../widgets/expense_chart.dart';
import '../screens/analytics_screen.dart';
import '../screens/history_screen.dart';
import '../screens/bills_screen.dart';
import '../screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedPeriod = 'Monthly';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TransactionProvider>().loadTransactions(),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'daily':
        return 'Today';
      case 'weekly':
        return 'This Week';
      case 'monthly':
        return 'This Month';
      case 'yearly':
        return 'This Year';
      default:
        return 'This Month';
    }
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    return transactions.where((t) {
      final date = t.date;
      switch (_selectedPeriod) {
        case 'daily':
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case 'weekly':
          final weekStart =
              DateTime(now.year, now.month, now.day - now.weekday + 1);
          final weekEnd = weekStart.add(const Duration(days: 7));
          return date.isAfter(weekStart) && date.isBefore(weekEnd);
        case 'monthly':
          return date.year == now.year && date.month == now.month;
        case 'yearly':
          return date.year == now.year;
        default:
          return date.year == now.year && date.month == now.month;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            floating: false,
            snap: false,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                      colorScheme.tertiary,
                    ],
                  ),
                ),
                child: Consumer<TransactionProvider>(
                  builder: (context, provider, child) {
                    final transactions = provider.transactions;
                    final now = DateTime.now();
                    final currentDay = DateTime(now.year, now.month, now.day);
                    final currentMonth = DateTime(now.year, now.month);
                    final currentYear = DateTime(now.year);

                    // Calculate week boundaries (Monday to Sunday)
                    final weekStart = DateTime(
                        now.year, now.month, now.day - now.weekday + 1);
                    final weekEnd = weekStart.add(const Duration(days: 7));

                    final dailyTransactions = transactions.where((t) {
                      final transactionDate =
                          DateTime(t.date.year, t.date.month, t.date.day);
                      return transactionDate.isAtSameMomentAs(currentDay);
                    }).toList();

                    final weeklyTransactions = transactions.where((t) {
                      final transactionDate = DateTime(
                        t.date.year,
                        t.date.month,
                        t.date.day,
                      );
                      return transactionDate.isAtSameMomentAs(weekStart) ||
                          (transactionDate.isAfter(weekStart) &&
                              transactionDate.isBefore(weekEnd));
                    }).toList();

                    final monthlyTransactions = transactions.where((t) {
                      final transactionDate =
                          DateTime(t.date.year, t.date.month);
                      return transactionDate.isAtSameMomentAs(currentMonth);
                    }).toList();

                    final yearlyTransactions = transactions.where((t) {
                      final transactionDate = DateTime(t.date.year);
                      return transactionDate.isAtSameMomentAs(currentYear);
                    }).toList();

                    final selectedTransactions = switch (_selectedPeriod) {
                      'Daily' => dailyTransactions,
                      'Weekly' => weeklyTransactions,
                      'Monthly' => monthlyTransactions,
                      'Yearly' => yearlyTransactions,
                      _ => monthlyTransactions,
                    };

                    // Calculate totals with proper formatting
                    final totalIncome = selectedTransactions
                        .where((t) => !t.isExpense)
                        .fold<double>(0, (sum, t) => sum + t.amount);

                    final totalExpense = selectedTransactions
                        .where((t) => t.isExpense)
                        .fold<double>(0, (sum, t) => sum + t.amount);

                    final balance = totalIncome - totalExpense;

                    // Get period label
                    final periodLabel = switch (_selectedPeriod) {
                      'Daily' => DateFormat('MMM dd, yyyy').format(currentDay),
                      'Weekly' =>
                        '${DateFormat('MMM dd').format(weekStart)} - ${DateFormat('MMM dd, yyyy').format(weekEnd.subtract(const Duration(days: 1)))}',
                      'Monthly' => DateFormat('MMMM yyyy').format(currentMonth),
                      'Yearly' => currentYear.year.toString(),
                      _ => DateFormat('MMMM yyyy').format(currentMonth),
                    };

                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      periodLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                    ),
                                  ],
                                ),
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  child: IconButton(
                                    icon: const Icon(
                                        Icons.notifications_outlined),
                                    color: Colors.white,
                                    onPressed: () {
                                      // TODO: Implement notifications
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            // Balance Overview Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Balance',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                              ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _selectedPeriod,
                                              dropdownColor:
                                                  colorScheme.primary,
                                              icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.white),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                              items: [
                                                'Daily',
                                                'Weekly',
                                                'Monthly',
                                                'Yearly'
                                              ].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    _selectedPeriod = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'en_IN',
                                            symbol: '₹',
                                            decimalDigits: 0,
                                          ).format(balance),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          balance >= 0
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          color: balance >= 0
                                              ? Colors.green
                                              : Colors.red,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 100,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatCard(
                                              context,
                                              'Income',
                                              totalIncome,
                                              Icons.arrow_upward,
                                              Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildStatCard(
                                              context,
                                              'Expenses',
                                              totalExpense,
                                              Icons.arrow_downward,
                                              Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.show_chart,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Expense Trend',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnalyticsScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        label: Text(
                          'See More',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<TransactionProvider>(
                    builder: (context, provider, child) {
                      final transactions = provider.transactions;
                      final now = DateTime.now();
                      final currentMonth = DateTime(now.year, now.month);

                      // Get last 6 months of data
                      final List<Map<String, dynamic>> monthlyData =
                          List.generate(6, (index) {
                        final month = DateTime(now.year, now.month - index);
                        final monthTransactions = transactions.where((t) {
                          final transactionDate =
                              DateTime(t.date.year, t.date.month);
                          return transactionDate.isAtSameMomentAs(month);
                        }).toList();

                        final totalExpense = monthTransactions
                            .where((t) => t.isExpense)
                            .fold<double>(0, (sum, t) => sum + t.amount);

                        return {
                          'month': month,
                          'amount': totalExpense,
                        };
                      }).reversed.toList();

                      return Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: monthlyData.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No expense data available',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.grey,
                                            ),
                                      ),
                                    )
                                  : LineChart(
                                      LineChartData(
                                        gridData: FlGridData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  '₹${value.toInt()}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                if (value.toInt() >= 0 &&
                                                    value.toInt() <
                                                        monthlyData.length) {
                                                  final month =
                                                      monthlyData[value.toInt()]
                                                          ['month'] as DateTime;
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(
                                                      DateFormat('MMM')
                                                          .format(month),
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: monthlyData
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              return FlSpot(
                                                  entry.key.toDouble(),
                                                  entry.value['amount']);
                                            }).toList(),
                                            isCurved: true,
                                            color: colorScheme.primary,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(show: true),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: colorScheme.primary
                                                  .withOpacity(0.1),
                                            ),
                                          ),
                                        ],
                                        minY: 0,
                                        maxY: monthlyData.isEmpty
                                            ? 1000
                                            : monthlyData
                                                    .map((data) =>
                                                        data['amount']
                                                            as double)
                                                    .reduce((a, b) =>
                                                        a > b ? a : b) *
                                                1.2,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Transactions Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) =>
                                    const AddTransactionSheet(),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add New'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              if (provider.transactions.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add your first transaction',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Sort transactions by date in descending order (newest first)
              final sortedTransactions =
                  List<Transaction>.from(provider.transactions)
                    ..sort((a, b) => b.date.compareTo(a.date));

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return TransactionItem(
                        transaction: sortedTransactions[index],
                      );
                    },
                    childCount: sortedTransactions.length,
                  ),
                ),
              );
            },
          ),
          // Add padding at the bottom to account for FAB
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTransactionSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(
              locale: 'en_IN',
              symbol: '₹',
              decimalDigits: 0,
            ).format(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
