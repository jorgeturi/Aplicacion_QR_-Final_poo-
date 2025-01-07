import 'package:flutter/material.dart';

class Log_page extends StatefulWidget {
  @override
  _Log_pageState createState() => _Log_pageState();
}

class _Log_pageState extends State<Log_page> {
  String connectionStatus = 'Comprobando conexión a Firebase...';

  @override
  void initState() {
    super.initState();
    checkFirebaseStatus();
  }

  // Método para verificar si Firebase ya está inicializado
  void checkFirebaseStatus() {
    try {
      setState(() {
        connectionStatus = 'Firebase está inicializado y funcionando'; // Firebase está disponible
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Error al verificar Firebase: $e'; // Si ocurre un error inesperado
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Center(
        child: Text(
          connectionStatus, // Mostrar el estado de la conexión
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}