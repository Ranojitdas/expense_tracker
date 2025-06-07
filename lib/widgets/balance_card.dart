import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'time_filter_chip.dart';

class BalanceCard extends StatefulWidget {
  final TransactionProvider provider;

  const BalanceCard({super.key, required this.provider});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  TimeFilter _selectedFilter = TimeFilter.monthly;

  double _getFilteredAmount(List<Transaction> transactions, bool isExpense) {
    final now = DateTime.now();
    final filteredTransactions = transactions.where((t) {
      if (t.isExpense != isExpense) return false;
      switch (_selectedFilter) {
        case TimeFilter.daily:
          return t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day;
        case TimeFilter.monthly:
          return t.date.year == now.year && t.date.month == now.month;
        case TimeFilter.yearly:
          return t.date.year == now.year;
      }
    });
    return filteredTransactions.fold(0, (sum, t) => sum + (t.amount ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final transactions = widget.provider.transactions;
    final totalBalance = transactions.fold<double>(
      0,
      (sum, t) => sum + (t.isExpense ? -(t.amount ?? 0) : (t.amount ?? 0)),
    );
    final income = _getFilteredAmount(transactions, false);
    final expenses = _getFilteredAmount(transactions, true);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Balance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                TimeFilterChip(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(
                locale: 'en_IN',
                symbol: '₹',
                decimalDigits: 0,
              ).format(totalBalance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: totalBalance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildAmountCard(
                    context,
                    'Money I Have',
                    income,
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAmountCard(
                    context,
                    'Money I Spent',
                    expenses,
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              locale: 'en_IN',
              symbol: '₹',
              decimalDigits: 0,
            ).format(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
