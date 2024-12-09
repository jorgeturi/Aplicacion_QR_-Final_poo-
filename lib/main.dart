import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'generate_qr_page.dart';
import 'my_qrs_page.dart';


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
  int errorCorrectionLevel = 1; // Lo dejamos fijo por ahora, no modificable
  double size = 200.0;  // Tamaño personalizable del QR

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        QrImageView(
          data: data,
          size: size,
          version: 6, // Versión de QR (1-40)
          errorCorrectionLevel: QrErrorCorrectLevel.L, // Usamos la constante para nivel bajo por ahora
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
              MaterialPageRoute(builder: (context) => MyQRsPage()),
            );
          },
          child: Text('Cambiar URL'),
        ),

        ElevatedButton(

          onPressed: () {
            // Navegar a la página de generación de QR
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GenerateQRPage()),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 50, vertical: 10)),
          ),
          child: Text('Test'),
        ),

      ],
    );
  }
}
