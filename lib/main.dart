import 'package:flutter/material.dart';
import 'package:projeto_avaliativo_2/screen/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Trabalho 2",
      home: MainScreen(),
    );
  }
}
