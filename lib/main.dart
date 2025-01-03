import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Importamos mobile_scanner
import 'package:url_launcher/url_launcher.dart'; // Importar url_launcher
import 'package:lottie/lottie.dart'; // Importar el paquete Lottie
import 'generate_qr_page.dart'; // Importamos la página de generación
import 'my_qrs_page.dart'; // Importamos la página para mostrar los QR guardados

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("")),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Botones(),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                // Acción para abrir la cámara
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QrScannerPage()),
                );
              },
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              child: 
              Icon(
                Icons.qr_code,
                size: 40.0, // Ajusta el tamaño del icono
              ) // Ícono de cámara
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Centrado abajo
      ),
    );
  }
}

class Botones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // Animación Lottie
        Positioned(
          top: 0, // Ajusta la posición vertical
          child: Lottie.asset(
            'imagenes/main/qr_animacion.json',
            width: 200, // Ajusta el tamaño
            height: 200, // Ajusta el tamaño
            repeat: true, // Hacer que la animación se repita
            reverse: true, // Hacer que la animación se revierta
            animate: true,
          ),
        ),
        // Botones
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
        ),
      ],
    );
  }
}

class Boton extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry margin;

  const Boton({
    Key? key,
    required this.texto,
    required this.onPressed,
    this.margin = const EdgeInsets.all(4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 0, 89, 253)),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          side: MaterialStateProperty.all(BorderSide(color: Colors.black, width: 1)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          )),
          padding: MaterialStateProperty.all(EdgeInsets.all(16)),
          overlayColor: MaterialStateProperty.all(Colors.grey),
        ),
        child: Text(texto),
      ),
    );
  }
}

class QrScannerPage extends StatefulWidget {
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String? result; // Para almacenar el resultado del escaneo

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
                final barcode = barcodeCapture.barcodes.first; // Acceder al primer código detectado
                if (barcode.rawValue != null) {
                  setState(() {
                    result = barcode.rawValue; // Guardamos el resultado del escaneo
                  });
                  _handleScanResult(result!);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Código detectado: $result') // Mostramos el código escaneado
                  : Text('Apunta al código QR para escanear'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleScanResult(String scannedData) async {
    // Divide la URL y la información (antes del "|")
    List<String> parts = scannedData.split('|');
    String url = parts[0];
    String information = parts.length > 1 ? parts[1] : '';

    // Verificamos si tiene el "|" y si el QR es dinámico
    if (parts.length > 1) {
      print('QR dinámico: $scannedData');
      
      // Verificamos si estamos dentro del timestamp definido (suponiendo que el timestamp está en milisegundos)
      int timestamp = int.tryParse(information) ?? 0;
      bool isValidTimestamp = timestamp > DateTime.now().millisecondsSinceEpoch;
      print('Timestamp: $timestamp, válido: $isValidTimestamp');
      
      if (isValidTimestamp) {
        print('QR dentro del tiempo válido');
      } else {
        print('QR fuera del tiempo válido');
      }
    } else {
      print('QR estático: $scannedData');
    }

    bool isValid = true;
    // Validamos la información
    if (information != '') {
      isValid = _validateInformation(information);
    }

    if (isValid) {
      // Si la información es válida, intentamos lanzar la URL
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url'; // Agregar prefijo si falta
      }
      Uri uri = Uri.parse(url);
      if (true) {
        print("URL válida, abriendo...");
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError("No se puede abrir la URL");
      }
    } else {
      _showError("QR inválido");
    }
  }

  bool _validateInformation(String info) {
    // Lógica de validación de la información (por ejemplo, comprobar si el timestamp es válido)
    
    // Intentamos parsear la fecha ISO 8601 (ejemplo: "2025-01-03T15:08:03.369")
    DateTime? parsedDate = DateTime.tryParse(info);
    
    if (parsedDate == null) {
      print('Error: La información no es una fecha válida');
      return false;
    }
    
    int timestamp = parsedDate.millisecondsSinceEpoch; // Convertimos la fecha a milisegundos
    print('Timestamp: $timestamp, válido: ${timestamp > DateTime.now().millisecondsSinceEpoch}');

    return timestamp > DateTime.now().millisecondsSinceEpoch; // Verificamos si el timestamp es mayor que el actual
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
