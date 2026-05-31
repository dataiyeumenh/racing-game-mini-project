import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CowRacingApp());
}

class CowRacingApp extends StatelessWidget {
  const CowRacingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bò Đua',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
