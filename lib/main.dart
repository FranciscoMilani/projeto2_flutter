import 'package:flutter/material.dart';
import 'package:projeto_avaliativo_2/screen/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Gerenciador de Produtos', home: AuthScreen());
  }
}
