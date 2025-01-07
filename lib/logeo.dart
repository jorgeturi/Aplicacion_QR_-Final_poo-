import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Log_page extends StatefulWidget {
  @override
  _Log_pageState createState() => _Log_pageState();
}

class _Log_pageState extends State<Log_page> {
  String connectionStatus = 'Comprobando conexión a Firebase...'; // Estado inicial

  // Método para inicializar Firebase y verificar la conexión
  Future<void> checkFirebaseConnection() async {
    try {
      await Firebase.initializeApp(); // Intenta inicializar Firebase
      setState(() {
        connectionStatus = 'Conexión a Firebase exitosa'; // Si la conexión es exitosa
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Error al conectar con Firebase: $e'; // Si ocurre un error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirebaseConnection(); // Llamamos al método cuando la página se carga
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Center(
        child: Text(
          connectionStatus, // Mostramos el estado de la conexión
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}