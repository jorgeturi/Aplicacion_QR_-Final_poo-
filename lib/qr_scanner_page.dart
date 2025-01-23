import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QrScannerPage extends StatefulWidget {
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String? result;
  String? lastResult;
  bool isProcessing = false;

  Future<void> handleScanResult(String scannedValue) async {
    setState(() {
      isProcessing = true; // Activamos el indicador de procesamiento
    });

    try {
      // Construir la URL a partir del valor escaneado
      Uri url = Uri.parse(scannedValue);

      if (scannedValue.contains('finalpoo-turinajorge.web.app/validador/?qr=')) {
        // Obtener el correo electrónico del usuario logueado
        
        final user = FirebaseAuth.instance.currentUser;
        final email = user?.email ?? "Email no disponible"; // Obtener el email
        
        print("voy a mandar");
        print(email);
        print(user);

        url = url.replace(queryParameters: {
        ...url.queryParameters, // Mantiene los parámetros existentes
        'email': email,         // Agrega el parámetro 'email'
        });


      }








      // Comprobar si se puede abrir la URL
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error al intentar abrir la URL: $e');
      _showErrorDialog(context, 'Error al procesar el QR');
    } finally {
      setState(() {
        isProcessing = false; // Desactivamos el indicador de procesamiento
      });
    }
  }

  // Muestra un diálogo de error
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Expanded(child : Text('Escanea tu código QR'))),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                if (barcode.rawValue != null && !isProcessing) {
                  final scannedValue = barcode.rawValue!;
                  if (scannedValue != lastResult) {
                    setState(() {
                      result = scannedValue;
                      lastResult = scannedValue;
                    });
                    handleScanResult(
                        scannedValue); // Abrir la página directamente
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Código detectado: $result')
                  : Text('Apunta al código QR para escanear'),
            ),
          ),
        ],
      ),
    );
  }
}
