import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'styles.dart';
import 'auth_service.dart';
import 'package:finalpoo_turina/logeo.dart';

void main() async {
  // Asegura la inicialización del entorno de Flutter
  WidgetsFlutterBinding.ensureInitialized(); //necesario cuando se usan metodos async en el main

  await AuthService().initializeFirebase();

  final biometricService = BiometricAuthService();
  bool biometricos = await biometricService.loadBiometricPreference();
  if (biometricos == true){
   await biometricService.authenticateBiometrics();
  }

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


