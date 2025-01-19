import 'package:finalpoo_turina/auth_service.dart';
import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'styles.dart';
import 'package:finalpoo_turina/logeo.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Asegura la inicialización del entorno de Flutter
  WidgetsFlutterBinding.ensureInitialized(); //necesario cuando se usan metodos async en el main

  final authService = AuthService();
  await authService.initializeFirebase();

if (!kIsWeb) {
  final biometricService = BiometricAuthService();
  bool biometricos = await biometricService.loadBiometricPreference();
  if (biometricos == true){
  String authStatus = await biometricService.authenticateBiometrics();
    print(authStatus);  // Imprimir el resultado de la autenticación

  }
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



void mainAppLogic() async{
  // Cuando la app vuelva al primer plano, se debe llamar a la función de biometría:
  // Asegúrate de que logeo.dart esté accesible aquí.
  final biometricService = BiometricAuthService();
  String authStatus = await biometricService.authenticateBiometrics();
  print(authStatus);  // Imprimir el resultado de la autenticación
}