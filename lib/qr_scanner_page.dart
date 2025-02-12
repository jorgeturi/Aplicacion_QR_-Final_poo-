import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart'; // Para móvil

// Página para escanear códigos QR y procesar su contenido, incluyendo la apertura de enlaces y validación con Firebase.

class QrScannerPage extends StatefulWidget {
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String? result;
  String? lastResult;
  bool isProcessing = false;

  // Mapa para almacenar los fragmentos recibidos
  Map<int, Uint8List> receivedFragments = {};
  int totalFragments = 0;
  int archCompleto = 0;
  String fileName = "";
  String fileExtension = "";

  Future<void> handleScanResult(String scannedValue) async {
    setState(() {
      isProcessing = true; // Activamos el indicador de procesamiento
    });
      print(scannedValue);
    try {
      // Verificar si el código QR comienza con "arch"
      if (scannedValue.startsWith("arch")) {
        _processFileFragment(scannedValue);
      } else if (scannedValue
          .contains('finalpoo-turinajorge.web.app/validador/?qr=')) {
        // Obtener el correo electrónico del usuario logueado
        final user = FirebaseAuth.instance.currentUser;
        final email = user?.email ?? "Email no disponible"; // Obtener el email

        print("voy a mandar");
        print(email);
        print(user);

        Uri url = Uri.parse(scannedValue).replace(queryParameters: {
          ...Uri.parse(scannedValue)
              .queryParameters, // Mantiene los parámetros existentes
          'email': email, // Agrega el parámetro 'email'
        });

        // Comprobar si se puede abrir la URL
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Si no es un fragmento de archivo ni una URL válida, mostrar error
        _showErrorDialog(context, 'Código QR no reconocido');
      }
    } catch (e) {
      print('Error al intentar procesar el QR: $e');
      _showErrorDialog(context, 'Error al procesar el QR');
    } finally {
      setState(() {
        isProcessing = false; // Desactivamos el indicador de procesamiento
      });
    }
  }

  // Procesa un fragmento de archivo
  void _processFileFragment(String fragment) {
    List<String> parts = fragment.split('|');
    if (parts.length >= 3) {
      int fragmentNumber = int.parse(parts[2]);
      if (fragmentNumber == 0) {
        // Es el fragmento inicial
        totalFragments = int.parse(parts[1]);
        fileName = parts[3];
      } 
        // Es el fragmento final
        //_reconstructFile();
      else {
        // Es un fragmento de datos
        
        // Es un fragmento de datos
        totalFragments = int.parse(parts[1]);
      // Es un fragmento de datos, decodificamos el Base64 y almacenamos los datos
       String base64Data = parts[3]; // Los datos están codificados en Base64
      Uint8List decodedBytes = base64Decode(base64Data); // Decodificamos los datos Base64 a bytes
      receivedFragments[fragmentNumber] = decodedBytes; // Almacenamos los bytes
      }

      // Verificar si todos los fragmentos han sido recibidos
      if ((receivedFragments.length == totalFragments) && (archCompleto == 0)) {
        _reconstructFile();
      }

      // Actualizar la interfaz
      setState(() {});
    }
  }

  void _reconstructFile() async {
  if (receivedFragments.length == totalFragments) {
    archCompleto = 1;
    // Ordenar los fragmentos
    List<Uint8List> sortedFragments = [];
    for (int i = 1; i <= totalFragments; i++) {
      sortedFragments.add(receivedFragments[i]!);
    }

    // Unir los fragmentos
    Uint8List bytes = Uint8List.fromList(
        sortedFragments.expand((s) => s).toList()); // junta sublistas en 1 sola

    // Guardar el archivo
    await _saveFileToDownloads(bytes, fileName);
  } else {
    _showErrorDialog(
        context, 'Faltan fragmentos para reconstruir el archivo');
  }
}

  // Guarda el archivo en la carpeta de descargas (móvil)
  Future<void> _saveFileToDownloads(Uint8List bytes, String fileName) async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      // Ruta pública de descargas
      final downloadDirectory = Directory(
          '/storage/emulated/0/Download'); // Ruta a la carpeta de descargas

      // Verifica si la carpeta de descargas existe, si no la crea
      if (!await downloadDirectory.exists()) {
        await downloadDirectory.create(recursive: true);
      }

      // Crear la ruta del archivo en la carpeta de descargas
      final filePath = '${downloadDirectory.path}/$fileName';
      final file = File(filePath);

      // Escribir los bytes en el archivo
      await file.writeAsBytes(bytes);

      // Mostrar mensaje de éxito con la ruta del archivo
      _showSuccessDialog(context, 'Archivo guardado en: $filePath');
      
    } else {
      throw 'No se pudo obtener el directorio de almacenamiento externo';
    }
  }

  // Muestra un diálogo de éxito
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Éxito'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                archCompleto = 0;
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown, // Ajusta el texto sin desbordar
          child: Text('Escanea tu código QR'),
        ),
        centerTitle: true, // Centra el texto
      ),
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
                    handleScanResult(scannedValue); // Procesar el resultado
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                if (result != null && !result!.startsWith("arch"))
                  Text('Código detectado: $result'),
                if (result != null && result!.startsWith("arch")) ...[
                  if (totalFragments < 150)
                    Column(
                      children: [
                        Text(
                            'Fragmentos recibidos: ${receivedFragments.length}/$totalFragments'),
                        Wrap(
                          children: List.generate(totalFragments, (index) {
                            bool isReceived =
                                receivedFragments.containsKey(index + 1);
                            return Container(
                              margin: EdgeInsets.all(2),
                              width: 10,
                              height: 10,
                              color: isReceived ? Colors.green : Colors.grey,
                            );
                          }),
                        ),
                      ],
                    ),
                  if (totalFragments >= 150)
                    Text(
                        'Fragmentos recibidos: ${receivedFragments.length}/$totalFragments'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
