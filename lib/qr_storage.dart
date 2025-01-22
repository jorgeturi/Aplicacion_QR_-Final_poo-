import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'qr_clases.dart';
import 'dart:convert';

class QRStorage {
  // Función para agregar un QR generado a Firestore
 static Future<void> addGeneratedQRToFirestore(QREstatico qr , String? users) async {
  try {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid; // Obtener el UID del usuario autenticado
      final firestore = FirebaseFirestore.instance;

      // Preparar los datos base para Firestore
      final qrData = {
        'url': qr.url,
        'alias': qr.alias,
        'fechaCreacion': qr.fechaCreacion.toIso8601String(),
        'owner': qr.owner,
        'vecesEscaneado': qr.vecesEscaneado,
        'vecesIngresado': qr.vecesIngresado,
      };

      // Si es un QR dinámico, agregar la fecha de expiración
      if (qr is QRdinamico) {
        qrData['fechaExpiracion'] = qr.fechaExpiracion.toIso8601String();
      }

      // Usar el método 'add' para que Firestore genere un ID único automáticamente
      final docRef = await firestore.collection('users').doc(uid).collection('qrs').add(qrData);

      // Obtener el ID generado por Firebase
      final generatedId = docRef.id;

      print('QR agregado a Firestore con ID: $generatedId para el usuario con UID: $uid');

      // Asignar el ID generado al objeto QR local para que lo puedas usar
      qr.id = generatedId;  // Actualizar el objeto QR con el ID generado
      final subCollectionRef = docRef.collection('informacion');
      final infoData = {
        'usuarios permitidos': users,
      };

      // Agregar documento a la subcolección
      await subCollectionRef.doc("usuarios con acceso").set(infoData);

      print("lo guarde en firestore");
      print("ahora veo que qr tiene id");
      print( qr.getId());



    } else {
      print('No hay usuario autenticado.');
    }
  } catch (e) {
    print('Error al agregar QR a Firestore: $e');
  }
}






static Future<List<QREstatico>> loadQRsFromFirestore() async {
  print("Entré a cargar desde Firestore");
  try {
    final User? user = FirebaseAuth.instance.currentUser;
    print("El usuario actual es: $user");

    if (user != null) {
      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      final querySnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('qrs')
          .orderBy('alias', descending: true)
          .get();

      print("Cantidad de documentos recuperados: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isEmpty) {
        print("No se encontraron documentos para este usuario.");
        return [];  // Retornar lista vacía si no hay documentos
      }

      // Mapear los documentos a instancias de QREstatico o QRdinamico
      List<QREstatico> qrList = querySnapshot.docs.map((doc) {
        print("Procesando documento: ${doc.id}");

        final url = doc['url'] as String;
        final alias = doc['alias'] as String;
        final fechaCreacion = DateTime.parse(doc['fechaCreacion'] as String);
        final owner = doc['owner'] as String;
        final id = doc.id; // Este es el ID generado por Firestore
        final vecesEscaneado = doc['vecesEscaneado'] as String? ?? "0";
        final vecesIngresado = doc['vecesIngresado'] as String? ?? "0";

        // Verificar si el campo 'fechaExpiracion' existe antes de acceder a él
        final fechaExpiracionStr = doc.data().containsKey('fechaExpiracion') ? doc['fechaExpiracion'] : null;

        // Imprimir valores para depuración
        print("Alias: $alias, veces Escaneado $vecesEscaneado");

        if (fechaExpiracionStr != null) {
          // Si existe la fecha de expiración, es un QRdinamico
          final fechaExpiracion = DateTime.parse(fechaExpiracionStr as String);
          print("QR Dinámico con fecha de expiración: $fechaExpiracion");
          return QRdinamico(
            url: url,
            alias: alias,
            fechaCreacion: fechaCreacion,
            owner: owner,
            fechaExpiracion: fechaExpiracion,
            id: id,
            vecesEscaneado: vecesEscaneado, // Asegúrate de tener estos valores
            vecesIngresado: vecesIngresado, // Asegúrate de tener estos valores
          );
        } else {
          // Si no existe 'fechaExpiracion', es un QREstatico
          print("QR Estático sin fecha de expiración");
          return QREstatico(
            url: url,
            alias: alias,
            fechaCreacion: fechaCreacion,
            owner: owner,
            id: id,
            vecesEscaneado: vecesEscaneado, // Asegúrate de tener estos valores
            vecesIngresado: vecesIngresado, // Asegúrate de tener estos valores
          );
        }
      }).toList();

      return qrList;
    } else {
      print('No hay usuario autenticado.');
      return [];  // Retornar lista vacía si no hay usuario autenticado
    }
  } catch (e) {
    print('Error cargando QR desde Firestore: $e');
    return [];  // Retornar lista vacía en caso de error
  }
}



  // Función para guardar los QR generados en el archivo local
static Future<void> saveQRsToFile(List<QREstatico> generatedQRs) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/generated_qrs.json');  // Guardamos como JSON

    // Convertimos la lista de objetos a una lista de mapas (JSON)
    final jsonList = generatedQRs.map((qr) => qr.toJson()).toList();  // Convertir objetos a mapa JSON

    // Guardamos la lista en el archivo como una cadena JSON
    final jsonString = jsonEncode(jsonList);
    await file.writeAsString(jsonString);



    print("ahora veo que qr tiene id");
    print( jsonString);

    print('QRs guardados en el archivo local.');
  } catch (e) {
    print('Error guardando QR en el archivo: $e');
  }
}

  // Función para cargar los QR desde el archivo local
static Future<void> loadQRsFromFile(List<QREstatico> generatedQRs) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/generated_qrs.json');  // Cargamos el archivo JSON

    if (await file.exists()) {
      final text = await file.readAsString();

      // Convertimos el texto JSON en una lista de objetos QR
      final jsonList = jsonDecode(text) as List<dynamic>;
      generatedQRs.addAll(jsonList.map((json) {
        // Convertimos el mapa JSON de nuevo en un objeto QR, puede ser QREstatico o QRdinamico
        return QREstatico.fromJson(json);  // Llama al método de fábrica de tu clase
      }).toList());

      print('QRs cargados desde el archivo local.');
    } else {
      print('No se encontró el archivo de QR generados.');
    }
  } catch (e) {
    print('Error cargando QR desde el archivo: $e');
  }
}

  // Función para eliminar un QR específico de Firestore usando su ID
static Future<void> deleteQRFromFirestore(String qrId) async {
  try {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      // Buscar el documento en Firestore usando el ID único del QR
      final querySnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('qrs')
          .where(FieldPath.documentId, isEqualTo: qrId)  // Usamos el ID del documento
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('QR con ID $qrId eliminado de Firestore para el usuario con UID: $uid');
    } else {
      print('No hay usuario autenticado.');
    }
  } catch (e) {
    print('Error al eliminar QR de Firestore: $e');
  }
}

static Future<void> deleteAllQRsFromFirestore() async {
  try {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      // Buscar todos los documentos en la colección de QR
      final querySnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('qrs')
          .get();

      // Eliminar cada documento encontrado
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('Todos los QR han sido eliminados de Firestore para el usuario con UID: $uid');
    } else {
      print('No hay usuario autenticado.');
    }
  } catch (e) {
    print('Error al eliminar los QR de Firestore: $e');
  }
}

static Future<File> getLocalQRFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/generated_qrs.json');
}


  static Future<void> deleteLocalFile() async {
final file = await getLocalQRFile();
  if (await file.exists()) {
    await file.delete(); // Borra el archivo si existe
  }
}





static Future<String?> getUsuariosPermitidos(String qrId) async {
  try {
    // Obtener el usuario autenticado
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid; // UID del usuario autenticado
      final firestore = FirebaseFirestore.instance;

      // Ruta al documento en la subcolección 'informacion'
      final docRef = firestore
          .collection('users')
          .doc(uid)
          .collection('qrs')
          .doc(qrId)
          .collection('informacion')
          .doc('usuarios con acceso');

      // Obtener el documento
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Extraer el campo 'usuarios permitidos'
        final data = docSnapshot.data();
        if (data != null && data.containsKey('usuarios permitidos')) {
          return data['usuarios permitidos'] as String;
        } else {
          print('El campo "usuarios permitidos" no existe en el documento.');
          return null;
        }
      } else {
        print('El documento no existe en Firestore.');
        return null;
      }
    } else {
      print('No hay usuario autenticado.');
      return null;
    }
  } catch (e) {
    print('Error al obtener "usuarios permitidos" de Firestore: $e');
    return null;
  }
}



void agregarNuevaInformacion(QREstatico qr, String nuevaInfo) async {
  // Lógica para manejar la información
  final id = qr.getId();
  final User? user = FirebaseAuth.instance.currentUser;
  
  if (user != null) {
      final uid = user.uid; // UID del usuario autenticado
      final firestore = FirebaseFirestore.instance;

      // Ruta al documento en la subcolección 'informacion'
      final docRef = firestore
          .collection('users')
          .doc(uid)
          .collection('qrs')
          .doc(qr.getId())
          .collection('informacion');

      // Crear un nuevo documento con el timestamp y mensaje
      await docRef.add({
        'timestamp': FieldValue.serverTimestamp(),  // Guardar el timestamp del servidor
        'mensaje': nuevaInfo,  // El mensaje que se pasa como parámetro
      });

      print('Información agregada exitosamente.');
    } else {
      print('No hay usuario autenticado.');
    }
}








Future<List<Map<String, dynamic>>> obtenerInformacion(String qrId) async {
  try {
    //AuthService authService = AuthService(); // Crear una instancia
    //final user = await authService.checkIfUserIsLoggedIn();
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid; // UID del usuario autenticado
      final firestore = FirebaseFirestore.instance;

      // Ruta al documento en la subcolección 'informacion'
      final docRef = firestore
          .collection('users')
          .doc(uid)
          .collection('qrs')
          .doc(qrId)
          .collection('informacion');

      // Obtener todos los documentos en la subcolección 'informacion'
      final querySnapshot = await docRef.orderBy('timestamp', descending: true).get();

      // Extraer la data de los documentos
      List<Map<String, dynamic>> informacion = [];
      querySnapshot.docs.forEach((doc) {
        informacion.add(doc.data());
      });

      return informacion;
    } else {
      print('No hay usuario autenticado.');
      return [];
    }
  } catch (e) {
    print('Error al obtener información: $e');
    return [];
  }
}









}

