import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async {
  // Asegúrate de que WidgetsFlutterBinding esté inicializado antes de ejecutar cualquier código que dependa de Flutter.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase antes de ejecutar la app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _testFirestore();
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