import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

class QRStorage {
  // Función para agregar un QR generado a Firestore
  static Future<void> addGeneratedQRToFirestore(String qrText) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final uid = user.uid; // Obtener el UID del usuario autenticado
        final firestore = FirebaseFirestore.instance;

        await firestore.collection('users').doc(uid).collection('qrs').add({
          'qrText': qrText,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('QR agregado a Firestore para el usuario con UID: $uid');
      } else {
        print('No hay usuario autenticado.');
      }
    } catch (e) {
      print('Error al agregar QR a Firestore: $e');
    }
  }

  // Función para cargar los QR desde Firestore
  static Future<List<String>> loadQRsFromFirestore() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final uid = user.uid;
        final firestore = FirebaseFirestore.instance;

        final querySnapshot = await firestore
            .collection('users')
            .doc(uid)
            .collection('qrs')
            .orderBy('createdAt', descending: true)
            .get();

        final qrList = querySnapshot.docs.map((doc) => doc['qrText'] as String).toList();

        print('QRs cargados desde Firestore para el usuario con UID: $uid');
        return qrList;
      } else {
        print('No hay usuario autenticado.');
        return [];
      }
    } catch (e) {
      print('Error cargando QR desde Firestore: $e');
      return [];
    }
  }

  // Función para cargar los QR desde el archivo local
  static Future<void> loadQRsFromFile(List<String> generatedQRs) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/generated_qrs.txt');

      if (await file.exists()) {
        final text = await file.readAsString();
        generatedQRs.addAll(text.split('\n'));
      } else {
        print('No se encontró el archivo de QR generados.');
      }
    } catch (e) {
      print('Error cargando QR desde el archivo: $e');
    }
  }

  // Función para guardar los QR generados en el archivo local
  static Future<void> saveQRsToFile(List<String> generatedQRs) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/generated_qrs.txt');
      final text = generatedQRs.join('\n');

      await file.writeAsString(text);
      print('QRs guardados en el archivo local.');
    } catch (e) {
      print('Error guardando QR en el archivo: $e');
    }
  }

  // Función para eliminar un QR específico de Firestore
  static Future<void> deleteQRFromFirestore(String qrText) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final uid = user.uid;
        final firestore = FirebaseFirestore.instance;

        final querySnapshot = await firestore
            .collection('users')
            .doc(uid)
            .collection('qrs')
            .where('qrText', isEqualTo: qrText)
            .get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }

        print('QR eliminado de Firestore para el usuario con UID: $uid');
      } else {
        print('No hay usuario autenticado.');
      }
    } catch (e) {
      print('Error al eliminar QR de Firestore: $e');
    }
  }



static Future<File> getLocalQRFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/generated_qrs.txt');
}


  static Future<void> deleteLocalFile() async {
final file = await getLocalQRFile();
  if (await file.exists()) {
    await file.delete(); // Borra el archivo si existe
  }
}

}

