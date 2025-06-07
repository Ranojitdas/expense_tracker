import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/history_screen.dart';
import '../screens/bills_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../services/notification_service.dart';

enum NavItem { home, history, bills, profile }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavItem _selectedItem = NavItem.home;
  bool _showChart = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _checkNotifications();
  }

  Future<void> _loadTransactions() async {
    await Provider.of<TransactionProvider>(context, listen: false)
        .loadTransactions();
  }

  Future<void> _checkNotifications() async {
    final transactions =
        Provider.of<TransactionProvider>(context, listen: false).transactions;
    await NotificationService().checkExistingBills(transactions);
  }

  void _onItemSelected(NavItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  void _onChartToggle(bool value) {
    setState(() {
      _showChart = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Map<NavItem, Widget> _screens = {
      NavItem.home: const HomeScreen(),
      NavItem.history: const HistoryScreen(),
      NavItem.bills: const BillsScreen(),
      NavItem.profile: const ProfileScreen(),
    };

    return Scaffold(
      body: _screens[_selectedItem],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                  item: NavItem.home,
                ),
                _buildNavItem(
                  icon: Icons.history_outlined,
                  selectedIcon: Icons.history,
                  label: 'History',
                  item: NavItem.history,
                ),
                _buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long,
                  label: 'Bills',
                  item: NavItem.bills,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                  item: NavItem.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required NavItem item,
  }) {
    final isSelected = _selectedItem == item;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _onItemSelected(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
