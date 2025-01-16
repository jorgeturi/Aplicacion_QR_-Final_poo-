import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para el manejo de respuestas JSON
import 'package:url_launcher/url_launcher.dart';  // Importar el paquete para abrir la URL

class QrScannerPage extends StatefulWidget {
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String? result;
  String? lastResult;
  bool isProcessing = false;

  Future<void> handleScanResult(BuildContext context, String scannedValue) async {
    try {
      // Realizamos la solicitud HTTP GET con el valor del QR escaneado
      final response = await http.get(Uri.parse('https://finalpoo-turinajorge.web.app/validador/?qr=$scannedValue'));

      if (response.statusCode == 200) {
        // La página respondió correctamente, puedes analizar la respuesta aquí
        // Si la validación del QR fue exitosa, muestra un mensaje de éxito
        // Puedes revisar el contenido de la respuesta, por ejemplo, si la página devuelve JSON, puedes usar jsonDecode.
        final responseBody = response.body;
        if (responseBody.contains('QR encontrado')) {
          // Si el QR es válido
          _showSuccessDialog(context, 'QR válido encontrado', scannedValue);
        } else {
          // Si el QR no fue encontrado
          _showErrorDialog(context, 'QR no encontrado');
        }
      } else {
        // Si hubo algún error en la solicitud HTTP
        _showErrorDialog(context, 'Error de conexión con el servidor');
      }
    } catch (e) {
      print('Error al validar el QR: $e');
      _showErrorDialog(context, 'Error al procesar el QR');
    }
  }

  // Muestra un dialogo de éxito con un botón para abrir la URL
  void _showSuccessDialog(BuildContext context, String message, String qrUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Éxito!'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchURL(qrUrl);  // Llamamos a la función para abrir la URL
              },
              child: Text('Ir a la web'),
            ),
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

  // Muestra un dialogo de error
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

// Función para abrir la URL escaneada en el navegador
Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);  // Convertir el String a Uri
    launchUrl(uri);  // Usar Uri en lugar de String
  } 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanea tu código QR')),
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
                      isProcessing = true;
                      result = scannedValue;
                      lastResult = scannedValue;
                    });
                    handleScanResult(context, result!);

                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        isProcessing = false;
                      });
                    });
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
