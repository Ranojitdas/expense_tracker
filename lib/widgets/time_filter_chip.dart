import 'package:flutter/material.dart';

enum TimeFilter { daily, weekly, monthly, yearly }

class TimeFilterChip extends StatelessWidget {
  final TimeFilter selectedFilter;
  final Function(TimeFilter) onFilterChanged;

  const TimeFilterChip({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: DropdownButton<TimeFilter>(
        value: selectedFilter,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        isExpanded: false,
        elevation: 8,
        dropdownColor: colorScheme.surface,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
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
                  color: colorScheme.primary,
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

  String _getFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.daily:
        return 'Today';
      case TimeFilter.weekly:
        return 'This Week';
      case TimeFilter.monthly:
        return 'This Month';
      case TimeFilter.yearly:
        return 'This Year';
    }
  }

  IconData _getFilterIcon(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.daily:
        return Icons.today;
      case TimeFilter.weekly:
        return Icons.calendar_view_week;
      case TimeFilter.monthly:
        return Icons.calendar_month;
      case TimeFilter.yearly:
        return Icons.calendar_today;
    }
  }
}
