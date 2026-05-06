import 'package:flutter/material.dart';
import 'pages/login.dart';

void main() {
  runApp(const ClimoraApp());
}

class ClimoraApp extends StatelessWidget {
  const ClimoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Climora',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginPage(), 
    );
  }
}