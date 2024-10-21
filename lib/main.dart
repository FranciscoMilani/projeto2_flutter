import 'package:flutter/material.dart';
import 'package:projeto_avaliativo_2/screen/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Gerenciador de Produtos', home: AuthScreen());
  }
}
