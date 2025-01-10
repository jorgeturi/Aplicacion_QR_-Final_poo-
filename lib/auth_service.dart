// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' show DefaultFirebaseOptions;
import 'package:flutter/foundation.dart'; 

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inicializar Firebase según la plataforma
  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase inicializado correctamente");
    } catch (e) {
      print("Error al inicializar Firebase: $e");
    }
  }

  // Verificar si el usuario ya está autenticado
  Future<User?> checkIfUserIsLoggedIn() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      print("Error al verificar si el usuario está autenticado: $e");
      return null;
    }
  }

  // Iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        googleUser = await _googleSignIn.signInSilently();
        print("Intentando inicio de sesión silencioso en la web.");
      } else {
        googleUser = await _googleSignIn.signIn();
        print("Iniciando sesión en dispositivo no web.");
      }

      if (googleUser == null) {
        print("El usuario canceló el inicio de sesión");
        return null; // Usuario cancela el inicio de sesión
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("Google Auth Token: ${googleAuth.accessToken}");
      print("Google Auth ID Token: ${googleAuth.idToken}");

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("Usuario autenticado: ${userCredential.user?.displayName}");
      return userCredential.user;
    } catch (e) {
      print('Error al iniciar sesión con Google: $e');
      // Agregar más detalles sobre el error
      if (e is FirebaseAuthException) {
        print("FirebaseAuthError: ${e.code} - ${e.message}");
      } else if (e is GoogleSignInAccount) {
        print("GoogleSignInError: $e");
      }
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print("Sesión cerrada correctamente");
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}
