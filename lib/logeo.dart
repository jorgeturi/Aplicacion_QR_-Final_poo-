import 'package:flutter/material.dart';

class Log_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Center(
        child: Text(
          'Página de Logeo',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}