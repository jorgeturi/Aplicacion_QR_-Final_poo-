import 'package:finalpoo_turina/auth_service.dart';
import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'styles.dart';

void main() async {
  // Asegura la inicialización del entorno de Flutter
  WidgetsFlutterBinding.ensureInitialized(); //necesario cuando se usan metodos async en el main

  final authService = AuthService();
  await authService.initializeFirebase();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: pantalla_principal(),
      theme: appTheme(),
    );
  }
}
