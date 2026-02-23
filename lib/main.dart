import 'package:flutter/material.dart';
import 'screens/customer/customer_landing_page.dart';

void main() {
  runApp(const QlessApp());
}

class QlessApp extends StatelessWidget {
  const QlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qless',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const CustomerLandingPage(),
    );
  }
}

