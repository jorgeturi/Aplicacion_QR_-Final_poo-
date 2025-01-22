import 'qr_clases.dart';
import 'qr_storage.dart';
import 'package:flutter/foundation.dart'; //para el manejo de la lista

class QRManager {
  static List<QREstatico> _generatedQRs = [];

  // Getter para acceder a la lista de QRs generados
  static List<QREstatico> get generatedQRs => _generatedQRs;

  // Método para agregar un QR a la lista de QRs generados
  static Future<void> addGeneratedQR(QREstatico qr, String users) async {
    if (!generatedQRs.any((existingQR) => existingQR.id == qr.id)) {
    
      await QRStorage.addGeneratedQRToFirestore(qr, users); // Espera que Firestore termine
      generatedQRs.add(qr);
      await QRStorage.saveQRsToFile(generatedQRs); // Guarda el QR en el archivo

    }
  }

  // Método para cargar todos los QRs desde Firestore y archivos
  static Future<void> loadAllQRs() async {
    print("Cargando todos los QRs..."); // Mensaje de depuración
    
    final fileQRs =
        <QREstatico>[]; // Lista para almacenar los QRs desde el archivo
    final firestoreQRs =
        await QRStorage.loadQRsFromFirestore(); // Cargar QRs desde Firestore
    print("de firestore tengo");
    print("");
    print(firestoreQRs);

    await QRStorage.loadQRsFromFile(fileQRs); // Cargar QRs desde el archivo
    print("de farchivo tengo");
    print("");
    print(fileQRs);
    final allQRsMap =
        <String, QREstatico>{}; // Usamos un Map para evitar duplicados

    // Combinamos los QRs de los dos orígenes y evitamos duplicados
    for (var qr in [...fileQRs, ...firestoreQRs]) {
      if (qr != null) {
        allQRsMap[qr.getId()] = qr; // Insertamos en el mapa por ID
      }
    }
    
    final allQRs = allQRsMap.values.toList(); // Lista final sin duplicados

    if (!listEquals(allQRs, _generatedQRs)) {
      _generatedQRs = allQRs;
      print("QRs cargados y actualizados: ${_generatedQRs.length}");
    } else {
      print("Los QRs ya están actualizados.");
    }
  }

  // Método para eliminar un QR de la lista
  static Future<void> deleteQR(QREstatico qr) async {
    generatedQRs.removeWhere((existingQR) => existingQR.id == qr.id);
    await QRStorage.deleteQRFromFirestore(
        qr.getId()); // Elimina del almacenamiento remoto
    //await QRStorage.deleteQRFromFile(qr); // Elimina del almacenamiento local
  }

  // Método para limpiar todos los QRs
  static Future<void> clearAllQRs() async {
    generatedQRs.clear();
    await QRStorage.deleteAllQRsFromFirestore();
    await QRStorage.deleteLocalFile();
  }

  static void remove(QREstatico qr) {
    generatedQRs.removeWhere((existingQR) => existingQR.id == qr.id);
  }

  static Future<String?> getUsuariosPermitidos(String qrId) async {
    try {
      // Intentar obtener los usuarios permitidos
      final usuarios = await QRStorage.getUsuariosPermitidos(qrId);
      return usuarios; // Retorna el resultado directamente
    } catch (e) {
      print('Error al obtener usuarios permitidos: $e');
      return null; // En caso de error, retorna null
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerInformacion(String qrId) async {
      try {
       List<Map<String, dynamic>> informacion = await QRStorage.obtenerInformacion(qrId);
      return informacion; // Retorna el resultado directamente
    } catch (e) {
      print('Error al obtener usuarios permitidos: $e');
      return []; // En caso de error, retorna null
    }
  }


  static void agregarNuevaInformacion(QREstatico qr, String nuevaInfo) async {
    QRStorage.agregarNuevaInformacion(qr, nuevaInfo);
  }

  static Future<void> deleteQRFromFirestore(String qrId) async {
    QRStorage.deleteQRFromFirestore(qrId);
  }

  static Future<void> saveQRsToFile(List<QREstatico> generatedQRs) async {
    QRStorage.saveQRsToFile(generatedQRs);
  }


}
