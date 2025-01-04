import 'package:flutter/material.dart';
import 'pantalla_principal.dart';

void main() {
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