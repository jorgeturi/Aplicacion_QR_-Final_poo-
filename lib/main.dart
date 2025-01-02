import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'generate_qr_page.dart'; // Importamos la página de generación
import 'my_qrs_page.dart'; // Importamos la página para mostrar los QR guardados

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Example',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('QR Principal'),
         actions: const [
            MenuDesplegable(), // Agregamos el menú desplegable aquí
          ],),
        body: Center(child: QrCodeGenerator()),
      ),
    );
  }
}

class QrCodeGenerator extends StatefulWidget {
  @override
  _QrCodeGeneratorState createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  String data = "https://google.com";
  double size = 200.0;  // Tamaño personalizable del QR

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        QrImageView(
          data: data,
          size: size,
          version: 6,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
        ),
        Boton(
          texto: 'icono escanear qr',
          onPressed: () {
            setState(() {
              size = size == 100.0 ? 200.0 : 100.0; // Cambia el tamaño entre 100 y 200
            });
          },
        ),
        Boton(
          texto: 'Generar QR',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GenerateQRPage()),
            );
          },
        ),
        Boton(
          texto: 'Mis QR',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyQRsPage()),
            );
          },
        ),
      ],
    );
  }
}

class Boton extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry margin; // Agregar parámetro para el margen

  const Boton({
    Key? key,
    required this.texto,
    required this.onPressed,
    this.margin = const EdgeInsets.all(4), // Valor por defecto para el margen
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin, // Usamos el margen aquí
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue), // Color de fondo cuando el botón está normal
          foregroundColor: MaterialStateProperty.all(Colors.white), // Color del texto
          side: MaterialStateProperty.all(BorderSide(color: Colors.black, width: 2)), // Borde negro
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Hace que el botón sea cuadrado
          )),
          padding: MaterialStateProperty.all(EdgeInsets.all(16)), // Padding para hacer el botón más grande
          overlayColor: MaterialStateProperty.all(Colors.grey), // Color cuando se presiona
        ),
        child: Text(texto),
      ),
    );
  }
}


// Asegúrate de que esta clase solo esté declarada una vez
class MenuDesplegable extends StatelessWidget {
  const MenuDesplegable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'Opción 1') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('aaaaaaaaaaaaaaaaaaaaaaaaaaa')),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seleccionaste: $value')),
        );
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Opción 1',
          child: Text('Opción 1'),
        ),
        const PopupMenuItem<String>(
          value: 'Opción 2',
          child: Row(
            children: [
              Icon(Icons.dark_mode, color: Colors.black),
              const SizedBox(width: 8),
              const Text('Opción 2 (Tema oscuro)'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Opción 3',
          child: Text('Opción 3'),
        ),
      ],
      icon: const Icon(Icons.menu),
    );
  }
}
