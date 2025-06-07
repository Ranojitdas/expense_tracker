import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/currency_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'account_settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencySymbol = currencyProvider.symbol;

    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final transactions = transactionProvider.transactions;

        // Calculate totals
        double totalIncome = 0;
        double totalExpenses = 0;

        for (var transaction in transactions) {
          if (transaction.isExpense) {
            totalExpenses += transaction.amount;
          } else {
            totalIncome += transaction.amount;
          }
        }

        final totalBalance = totalIncome - totalExpenses;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
                expandedHeight: 280,
            pinned: true,
                backgroundColor: colorScheme.primary,
                centerTitle: true,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final top = constraints.biggest.height;
                    final expandedHeight = 280.0;
                    final collapsedHeight =
                        kToolbarHeight + MediaQuery.of(context).padding.top;
                    final expandedPercentage = ((top - collapsedHeight) /
                            (expandedHeight - collapsedHeight))
                        .clamp(0.0, 1.0);

                    return FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16 + (expandedPercentage * 16),
                      ),
                      title: AnimatedOpacity(
                        opacity: 1.0 - expandedPercentage,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                    children: [
                      CircleAvatar(
                                    radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Icon(
                                Icons.person,
                                            size: 50,
                                color: Colors.grey,
                              )
                            : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.displayName ?? 'Guest User',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                              const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Not signed in',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Verified Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Quick Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.account_balance_wallet,
                          title: 'Total Balance',
                          value:
                              '${currencySymbol}${totalBalance.toStringAsFixed(2)}',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.arrow_upward,
                          title: 'Income',
                          value:
                              '${currencySymbol}${totalIncome.toStringAsFixed(2)}',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.arrow_downward,
                          title: 'Expenses',
                          value:
                              '${currencySymbol}${totalExpenses.toStringAsFixed(2)}',
                          color: Colors.red,
                            ),
                      ),
                    ],
              ),
            ),
          ),
          // Settings Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context,
                    title: 'Account Settings',
                        subtitle: 'Manage your account details',
                    icon: Icons.person_outline,
                    onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AccountSettingsScreen(),
                            ),
                          );
                    },
                  ),
                  _buildSettingsCard(
                    context,
                    title: 'Notifications',
                        subtitle: 'Configure notification preferences',
                    icon: Icons.notifications_outlined,
                    onTap: () {
                      // TODO: Navigate to notifications settings
                    },
                  ),
                  _buildSettingsCard(
                    context,
                    title: 'Currency',
                        subtitle: 'Change your preferred currency',
                    icon: Icons.currency_rupee,
                    onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Currency'),
                              content: Consumer<CurrencyProvider>(
                                builder: (context, currency, child) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: CurrencyProvider
                                      .supportedCurrencies.entries
                                      .map((entry) => RadioListTile<String>(
                                            title: Text(entry.value),
                                            subtitle: Text(entry.key),
                                            value: entry.key,
                                            groupValue: currency.currency,
                                            onChanged: (String? value) {
                                              if (value != null) {
                                                currency.setCurrency(value);
                                                Navigator.pop(context);
                                              }
                                            },
                                          ))
                                      .toList(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          );
                    },
                  ),
                  _buildSettingsCard(
                    context,
                    title: 'Categories',
                        subtitle: 'Manage transaction categories',
                    icon: Icons.category_outlined,
                    onTap: () {
                      // TODO: Navigate to categories settings
                    },
                  ),
                      _buildSettingsCard(
                        context,
                        title: 'Theme Mode',
                        subtitle: 'Switch between light and dark mode',
                        icon: Icons.brightness_6_outlined,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Choose Theme Mode'),
                              content: Consumer<ThemeProvider>(
                                builder: (context, theme, child) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RadioListTile<ThemeMode>(
                                      title: const Text('Light Mode'),
                                      subtitle: const Text('Use light theme'),
                                      value: ThemeMode.light,
                                      groupValue: theme.themeMode,
                                      onChanged: (ThemeMode? value) {
                                        if (value != null) {
                                          theme.setThemeMode(value);
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                    RadioListTile<ThemeMode>(
                                      title: const Text('Dark Mode'),
                                      subtitle: const Text('Use dark theme'),
                                      value: ThemeMode.dark,
                                      groupValue: theme.themeMode,
                                      onChanged: (ThemeMode? value) {
                                        if (value != null) {
                                          theme.setThemeMode(value);
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                    RadioListTile<ThemeMode>(
                                      title: const Text('System Default'),
                                      subtitle:
                                          const Text('Follow system theme'),
                                      value: ThemeMode.system,
                                      groupValue: theme.themeMode,
                                      onChanged: (ThemeMode? value) {
                                        if (value != null) {
                                          theme.setThemeMode(value);
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
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
          // About Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context,
                    title: 'Help & Support',
                        subtitle: 'Get help and contact support',
                    icon: Icons.help_outline,
                    onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          );
                    },
                  ),
                  _buildSettingsCard(
                    context,
                    title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                    },
                  ),
                  _buildSettingsCard(
                    context,
                    title: 'Terms of Service',
                        subtitle: 'Read our terms of service',
                    icon: Icons.description_outlined,
                    onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TermsOfServiceScreen(),
                            ),
                          );
                    },
                  ),
                  _buildSettingsCard(
                    context,
                    title: 'App Version',
                        subtitle: '1.0.0',
                    icon: Icons.info_outline,
                    onTap: () {
                      // TODO: Show version info
                    },
                  ),
                ],
              ),
            ),
          ),
          // Logout Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () async {
                  try {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            onLogin: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                              content:
                                  Text('Error signing out: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
              ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
