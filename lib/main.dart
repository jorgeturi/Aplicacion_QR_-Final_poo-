import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  // Asegura la inicialización del entorno de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase antes de ejecutar la app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Registra el Client ID para Google Sign-In
  GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: '929827470228-tt162jkolsa79a09u20l4h5lj6ve1kfg.apps.googleusercontent.com',
  );

  // Test Firestore
  //await _testFirestore();

  // Ejecuta la app
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

Future<void> _testFirestore() async {
  try {
    // Escribe en Firestore
    await FirebaseFirestore.instance.collection('test').add({
      'message': 'Hola desde Flutter',
    });
    print("Documento agregado con éxito.");
  } catch (e) {
    print("Error al agregar documento: $e");
  }
}
