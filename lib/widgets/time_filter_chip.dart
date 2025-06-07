import 'package:flutter/material.dart';

enum TimeFilter { daily, monthly, yearly }

class TimeFilterChip extends StatelessWidget {
  final TimeFilter selectedFilter;
  final Function(TimeFilter) onFilterChanged;

  const TimeFilterChip({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  String _getFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.daily:
        return 'Today';
      case TimeFilter.monthly:
        return 'This Month';
      case TimeFilter.yearly:
        return 'This Year';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<TimeFilter>(
        value: selectedFilter,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
        items: TimeFilter.values.map((TimeFilter filter) {
          return DropdownMenuItem<TimeFilter>(
            value: filter,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getFilterIcon(filter),
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(_getFilterLabel(filter)),
              ],
            ),
          );
        }).toList(),
        onChanged: (TimeFilter? newValue) {
          if (newValue != null) {
            onFilterChanged(newValue);
          }
        },
      ),
    );
  }

  IconData _getFilterIcon(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.daily:
        return Icons.today;
      case TimeFilter.monthly:
        return Icons.calendar_month;
      case TimeFilter.yearly:
        return Icons.calendar_today;
    }
  }
}
