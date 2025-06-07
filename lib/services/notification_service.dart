import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'bill_reminders',
          channelName: 'Bill Reminders',
          channelDescription: 'Notifications for bill due dates',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          icon: 'resource://drawable/ic_launcher',
        ),
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> scheduleBillReminder(Transaction bill) async {
    if (bill.dueDate == null) return;

    final reminderDate = bill.dueDate!.subtract(const Duration(days: 1));
    if (reminderDate.isBefore(DateTime.now())) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: bill.id.hashCode,
        channelKey: 'bill_reminders',
        title: '📅 Bill Due Tomorrow',
        body:
            '${bill.title}\nAmount: ${bill.amount}\nDue: Tomorrow\nTap to view details',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        backgroundColor: Colors.blue,
        color: Colors.white,
        payload: {'billId': bill.id},
        icon: 'resource://drawable/ic_launcher',
      ),
      schedule: NotificationCalendar.fromDate(date: reminderDate),
    );
  }

  Future<void> cancelBillReminder(String billId) async {
    await AwesomeNotifications().cancel(billId.hashCode);
  }

  Future<void> showBillOverdueNotification(Transaction bill) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: bill.id.hashCode,
        channelKey: 'bill_reminders',
        title: '⚠️ Bill Overdue',
        body:
            '${bill.title}\nAmount: ${bill.amount}\nStatus: Overdue\nTap to pay now',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        backgroundColor: Colors.red,
        color: Colors.white,
        payload: {'billId': bill.id},
        icon: 'resource://drawable/ic_launcher',
      ),
    );
  }

  Future<void> checkExistingBills(List<Transaction> transactions) async {
    final now = DateTime.now();
    double totalDue = 0;
    int overdueCount = 0;

    for (var bill in transactions) {
      if (bill.dueDate != null) {
        if (bill.dueDate!.isBefore(now)) {
          totalDue += bill.amount;
          overdueCount++;
          await showBillOverdueNotification(bill);
        } else {
          await scheduleBillReminder(bill);
        }
      }
    }

    // Show summary notification if there are overdue bills
    if (overdueCount > 0) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999,
          channelKey: 'bill_reminders',
          title: '📊 Bill Summary',
          body:
              'You have $overdueCount overdue bills\nTotal Due: $totalDue\nTap to view all bills',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          backgroundColor: Colors.orange,
          color: Colors.white,
          icon: 'resource://drawable/ic_launcher',
        ),
      );
    }
  }

  Future<void> showTestNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 888,
        channelKey: 'bill_reminders',
        title: '📊 Bill Summary',
        body:
            'You have 2 overdue bills\nTotal Due: 1500\nTap to view all bills',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        backgroundColor: Colors.orange,
        color: Colors.white,
      ),
    );
  }
}
