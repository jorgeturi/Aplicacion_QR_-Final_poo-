import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart'; 


void main() async {
  // Asegúrate de que WidgetsFlutterBinding esté inicializado antes de ejecutar cualquier código que dependa de Flutter.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase antes de ejecutar la app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: pantalla_principal(),
    );
  }
}