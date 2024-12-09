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
      home: Scaffold(
        appBar: AppBar(title: Text('QR Code Example')),
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
        ElevatedButton(
          onPressed: () {
            setState(() {
              size = size == 200.0 ? 300.0 : 200.0; // Cambia el tamaño entre 200 y 300
            });
          },
          child: Text('Cambiar tamaño del QR'),
        ),
        ElevatedButton(
          onPressed: () {
            // Navegar a la página de generación de QR
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GenerateQRPage()), // Navegación correcta
            );
          },
          child: Text('Generar QR'),
        ),
        ElevatedButton(
          onPressed: () {
            // Navegar a la página de Mis QR
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyQRsPage()), // Navegación al listado
            );
          },
          child: Text('Mis QR'),
        ),
      ],
    );
  }
}
