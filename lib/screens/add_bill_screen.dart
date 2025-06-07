import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';
import '../services/notification_service.dart';

class AddBillScreen extends StatefulWidget {
  final String? billType;

  const AddBillScreen({
    super.key,
    this.billType,
  });

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String _selectedCategory = 'Bills & Utilities';
  bool _isRecurring = false;
  String? _recurringPeriod;
  String? _selectedPeriod;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Electricity Bill',
      'icon': Icons.electric_bolt,
      'color': Colors.amber,
    },
    {
      'title': 'Mobile Recharge',
      'icon': Icons.phone_android,
      'color': Colors.blue,
    },
    {
      'title': 'Water Bill',
      'icon': Icons.water_drop,
      'color': Colors.lightBlue,
    },
    {
      'title': 'Gas Bill',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
    },
    {
      'title': 'Internet Bill',
      'icon': Icons.wifi,
      'color': Colors.purple,
    },
    {
      'title': 'Borrowed Money',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
  ];

  final Map<String, Map<String, int>> _billPeriods = {
    'Mobile Recharge': {
      '28 Days': 28,
      '56 Days': 56,
      '84 Days': 84,
    },
    'Electricity Bill': {
      '1 Month': 30,
      '3 Months': 90,
      '6 Months': 180,
    },
    'Internet Bill': {
      '1 Month': 30,
      '3 Months': 90,
      '6 Months': 180,
    },
    'Water Bill': {
      '1 Month': 30,
      '3 Months': 90,
    },
    'Gas Bill': {
      '1 Month': 30,
      '3 Months': 90,
    },
  };

  @override
  void initState() {
    super.initState();
    if (widget.billType != null) {
      _selectedCategory = widget.billType!;
      _updateDueDate();
    }
  }

  void _updateDueDate() {
    final periods = _billPeriods[_selectedCategory];
    if (periods != null && _selectedPeriod != null) {
      setState(() {
        _dueDate = _selectedDate.add(Duration(days: periods[_selectedPeriod]!));
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateDueDate();
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId == null) return;

      final transaction = Transaction(
        id: const Uuid().v4(),
        userId: userId,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory,
        description: _descriptionController.text,
        isExpense: true,
        dueDate: _dueDate,
      );

      Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transaction);

      // Schedule bill reminder
      NotificationService().scheduleBillReminder(transaction);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final periods = _billPeriods[_selectedCategory];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Add ${widget.billType ?? 'Bill'}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              NotificationService().showTestNotification();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selection
              Text(
                'Select Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['title'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['title'];
                        _updateDueDate();
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category['color'].withOpacity(0.1)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? category['color']
                              : colorScheme.outline.withOpacity(0.5),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'],
                            color: isSelected
                                ? category['color']
                                : colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['title'],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? category['color']
                                          : colorScheme.onSurfaceVariant,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _selectedCategory == 'Borrowed Money'
                      ? 'Person Name'
                      : 'Bill Title',
                  hintText: _selectedCategory == 'Borrowed Money'
                      ? 'Enter person name'
                      : 'Enter bill title',
                  prefixIcon: Icon(
                    _selectedCategory == 'Borrowed Money'
                        ? Icons.person
                        : Icons.receipt_long,
                    color: colorScheme.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                    color: colorScheme.primary,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date Field
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: colorScheme.primary,
                    ),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Period Selection (if available for the category)
              if (periods != null && _selectedCategory != 'Borrowed Money') ...[
                DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Select Period',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  items: periods.keys.map((String period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(period),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPeriod = newValue;
                        _updateDueDate();
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
              // Due Date Selection (for Borrowed Money)
              if (_selectedCategory == 'Borrowed Money') ...[
                InkWell(
                  onTap: () => _selectDueDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      prefixIcon: Icon(
                        Icons.event,
                        color: colorScheme.primary,
                      ),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(_dueDate),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Due Date Display (for other bills)
              if (_selectedCategory != 'Borrowed Money') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Due Date',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_dueDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description (optional)',
                  prefixIcon: Icon(
                    Icons.description,
                    color: colorScheme.primary,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Recurring Bill Option
              if (_selectedCategory != 'Borrowed Money') ...[
                SwitchListTile(
                  title: Text(
                    'Recurring Bill',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  subtitle: Text(
                    'Set this bill to repeat automatically',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                      if (!value) _recurringPeriod = null;
                    });
                  },
                ),
                if (_isRecurring) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _recurringPeriod,
                    decoration: InputDecoration(
                      labelText: 'Repeat Every',
                      prefixIcon: Icon(
                        Icons.repeat,
                        color: colorScheme.primary,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: 'quarterly',
                        child: Text('Quarterly'),
                      ),
                      DropdownMenuItem(
                        value: 'yearly',
                        child: Text('Yearly'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _recurringPeriod = value;
                      });
                    },
                    validator: (value) {
                      if (_isRecurring && (value == null || value.isEmpty)) {
                        return 'Please select a recurring period';
                      }
                      return null;
                    },
                  ),
                ],
              ],
              const SizedBox(height: 24),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.add),
                  label: Text(
                    'Add ${_selectedCategory == 'Borrowed Money' ? 'Borrowed Money' : 'Bill'}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
