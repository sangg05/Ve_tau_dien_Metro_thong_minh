import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/Register_page.dart'; // giữ nguyên tên file có R hoa
import 'pages/home_page.dart';
import 'pages/Buy_ticket.dart';
import 'pages/my_ticket_page.dart';
import 'pages/transaction_history_page.dart';
import 'pages/Settings.dart';
import 'pages/AccountPag.dart';
import 'pages/language_settings_page.dart';
import 'pages/notification_settings_page.dart';
import 'pages/permission_settings_page.dart';
import 'pages/TicketDetailPage.dart';
import 'pages/payment_page.dart';

void main() => runApp(const MetroApp());

class Routes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const buy = '/buy';
  static const myTicket = '/myticket';
  static const journey = '/journey';
  static const settings = '/settings';
  static const account = '/TK';
  static const language = '/language';
  // không khai báo /about nếu chưa có page
}

class MetroApp extends StatelessWidget {
  const MetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HURC Metro',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.login,
      routes: {
        Routes.login: (_) => const LoginPage(),
        Routes.register: (_) => const RegisterPage(),
        Routes.home: (_) => const HomePage(),
        Routes.buy: (_) => const BuyTicketPage(),
        Routes.myTicket: (_) => const MyTicketPage(),
        Routes.journey: (_) => const TransactionHistoryPage(),
        Routes.settings: (_) => const SettingsPage(),
        Routes.account: (_) => const AccountPage(),
        Routes.language: (_) => const LanguageSettingsPage(),
        // Các trang con mở bằng MaterialPageRoute trực tiếp:
        // NotificationSettingsPage, PermissionSettingsPage,
        // TicketDetailPage, PaymentPage
      },
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }
}
