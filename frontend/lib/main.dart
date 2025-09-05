import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/Register_page.dart'; // Import trang đăng ký
import 'pages/Buy_ticket.dart';
import 'pages/my_ticket_page.dart';
import 'pages/transaction_history_page.dart';
import 'pages/AccountPag.dart';
import 'pages/Settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // tắt logo DEBUG
      title: 'Demo Navigation',
      theme: ThemeData(primarySwatch: Colors.blue),
      // routes: định nghĩa đường đi
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const Register_page(), // Thêm route này
        '/buy': (context) => const BuyTicketPage(),
        '/myticket': (context) => const MyTicketPage(),
        '/History': (context) => const TransactionHistoryPage(),
        '/TK': (context) => const AccountPage(),
        '/Setting': (context) => const SettingsPage(),
      },
    );
  }
}
