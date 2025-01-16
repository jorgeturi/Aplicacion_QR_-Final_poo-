import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' show DefaultFirebaseOptions;
import 'package:flutter/foundation.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inicializar Firebase según la plataforma
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Verificar si el usuario ya está autenticado
  Future<User?> checkIfUserIsLoggedIn() async {
    return _auth.currentUser;
  }

  // Iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;

      // Iniciar sesión de forma silenciosa o con ventana emergente según la plataforma
      if (kIsWeb) {
        googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      } else {
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        return null; // El usuario canceló el inicio de sesión
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Asocia el UID del usuario con su correo en Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
        }, SetOptions(merge: true)); // Usa merge para no sobrescribir documentos existentes
      }

      return user;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
