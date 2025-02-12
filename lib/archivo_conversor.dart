import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart'; // Para detectar la plataforma

class QRGeneratorScreen extends StatefulWidget {
  @override
  _QRGeneratorScreenState createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  List<String> qrFragments = []; // Almacena los fragmentos del archivo
  int currentIndex = 0; // Índice del fragmento actual
  Timer? _timer; // Timer para cambiar los códigos QR
  int switchInterval = 650; // Intervalo de cambio en milisegundos
  bool isTransmitting = false; // Indica si se está transmitiendo

  // ValueNotifier para actualizar solo el QR
  final ValueNotifier<String> _qrDataNotifier = ValueNotifier<String>('');

  // Selecciona un archivo y lo convierte en fragmentos
  void _pickFile() async {
    // Comprobamos si estamos en la web o en un dispositivo móvil
    if (kIsWeb) {
      // Si es en la web, usamos el enfoque actual (como ya lo tienes)
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        Uint8List? bytes = result.files.single.bytes; // Obtener los bytes del archivo
        String fileName = result.files.single.name; // Obtener el nombre del archivo

        if (bytes != null) {
          _generateQRFragments(bytes, fileName); // Generar fragmentos
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No se pudo leer el archivo")),
          );
        }
      }
    } else {
      // Si es un dispositivo móvil (Android/iOS), usamos un enfoque distinto
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path!); // Obtener el archivo como File
        String fileName = result.files.single.name; // Obtener el nombre del archivo

        // Leer los bytes del archivo
        Uint8List bytes = await file.readAsBytes();

        // Generar los fragmentos del archivo
        _generateQRFragments(bytes, fileName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo seleccionar el archivo")),
        );
      }
    }
  }

  // Genera los fragmentos del archivo en el formato especificado con datos binarios puros
  void _generateQRFragments(Uint8List bytes, String fileName) {
    int chunkSize = 1000; // Tamaño del fragmento en bytes
    int totalChunks = (bytes.length / chunkSize).ceil();
    List<String> chunks = [];

    for (int i = 0; i < totalChunks; i++) {
      Uint8List chunk = bytes.sublist(
        i * chunkSize,
        (i + 1) * chunkSize > bytes.length ? bytes.length : (i + 1) * chunkSize,
      );

      // Aquí, los datos siguen siendo binarios, pero se añaden como texto.
      // Debes manejar estos binarios como texto adecuado, como con Base64.
      String fragment = base64Encode(chunk);

      chunks.add("arch|$totalChunks|${i + 1}|$fragment");
    }

    qrFragments.clear();
    qrFragments.add("arch|$totalChunks|0|$fileName");
    qrFragments.addAll(chunks);
    //qrFragments.add("arch|$totalChunks|${totalChunks + 1}");

    setState(() {
      currentIndex = 0;
      isTransmitting = true;
    });

    // Iniciar la rotación de los códigos QR
    _startQRRotation();
  }

  // Inicia la rotación de los códigos QR
  void _startQRRotation() {
    _timer = Timer.periodic(Duration(milliseconds: switchInterval), (timer) {
      currentIndex = (currentIndex + 1) % qrFragments.length;
      _qrDataNotifier.value = qrFragments[currentIndex]; // Actualiza solo el valor del QR
    });
  }

  // Detiene la rotación de los códigos QR
  void _stopQRRotation() {
    _timer?.cancel();
    setState(() {
      isTransmitting = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _qrDataNotifier.dispose(); // Liberar el ValueNotifier
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Envio por QR")),
    body: Center( // Centra todo el contenido
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
        crossAxisAlignment: CrossAxisAlignment.center, // Centra horizontalmente
        children: [
          ElevatedButton(
            onPressed: _pickFile,
            child: Text("Elegir archivo"),
          ),
          SizedBox(height: 20),
          if (qrFragments.isNotEmpty) ...[
            ValueListenableBuilder<String>(
              valueListenable: _qrDataNotifier,
              builder: (context, qrData, child) {
                return QrImageView(
                  data: qrData,
                  size: 300.0,
                  version: 29,
                );
              },
            ),
            SizedBox(height: 20),
            if (isTransmitting)
              ElevatedButton(
                onPressed: _stopQRRotation,
                child: Text("Cancelar transmision"),
              ),
          ]
        ],
      ),
    ),
  );
}
}