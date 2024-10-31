import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:projeto_avaliativo_2/screen/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authStatus = "Autenticação";

  @override
  void initState() {
    super.initState();
  }

  // Autentica usuário via biometria
  Future<void> _authenticate() async {
    bool autenticado = false;
    try {
      autenticado = await auth.authenticate(
        localizedReason: 'Use sua digital para autenticar',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      setState(() {
        _authStatus = e.toString();
      });
      return;
    }

    if (autenticado) {
      setState(() {
        _authStatus = "Autenticado com sucesso!";
        _carregarTelaProdutos();
      });
    }
  }

  Future<void> _carregarTelaProdutos() async {
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProdutoListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _authStatus,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _authenticate,
              child: const Icon(
                Icons.fingerprint,
                size: 100,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Toque na biometria para iniciar autenticação',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
