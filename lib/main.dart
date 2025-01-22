import 'package:finalpoo_turina/auth_service.dart';
import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'styles.dart';
import 'package:finalpoo_turina/logeo.dart';

void main() async {
  // Asegura la inicialización del entorno de Flutter
  WidgetsFlutterBinding.ensureInitialized(); //necesario cuando se usan metodos async en el main

  final authService = AuthService();
  await authService.initializeFirebase();


  final biometricService = BiometricAuthService();
  bool biometricos = await biometricService.loadBiometricPreference();
  if (biometricos == true){
  String authStatus = await biometricService.authenticateBiometrics();
    print(authStatus);  // Imprimir el resultado de la autenticación
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


