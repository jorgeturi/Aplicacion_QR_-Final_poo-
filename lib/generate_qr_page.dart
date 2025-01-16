import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'my_qrs_page.dart'; // Importamos MyQRsPage para mostrar los QR guardados
import 'qr_clases.dart';
import 'auth_service.dart';

class GenerateQRPage extends StatefulWidget {
  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final TextEditingController _controller = TextEditingController();
  bool isDynamic = false; // Si es un QR dinámico
  int? expirationTime; // Tiempo de expiración en minutos
  DateTime? expirationDate; // Fecha y hora de expiración
  final TextEditingController _controllertiempo = TextEditingController();
  String ownerId = "local"; // O se podría reemplazar por la ID de Firebase
  final TextEditingController _controllerAlias = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkUserStatus(); // Llamamos al método que chequea si el usuario está logueado
  }

  // Función asincrónica para obtener el ID del usuario
  Future<void> _checkUserStatus() async {
    await _authService.initializeFirebase();  // Inicializa Firebase si aún no se ha hecho
    final user = await _authService.checkIfUserIsLoggedIn();

    setState(() {
      ownerId = user?.uid ?? "local";  // Si el usuario está logueado, usamos su UID; si no, usamos "local"
    });
  }

  // Guardar QR generado
  void _saveQR(String qrText) {
    final newQR = isDynamic
        ? QRdinamico(
            url: qrText,
            alias: _controllerAlias.text,
            fechaCreacion: DateTime.now(),
            owner: ownerId,
            fechaExpiracion: expirationDate!,
            id: "idvaciodinamico",
          )
        : QREstatico(
            url: qrText,
            alias: _controllerAlias.text,
            fechaCreacion: DateTime.now(),
            owner: ownerId,
            id: "idvacioestatico",
          );
    
    // Agregar el QR generado a la lista de QR guardados
    MyQRsPage.addGeneratedQR(newQR);
    // Imprimir en consola
    print("QR Guardado: ${newQR.toString()}");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyQRsPage(),
      ),
    );
  }

  String _generateDynamicQR() {
    print("el dueño es : ");
    print(ownerId);
    if (isDynamic && expirationTime != null) {
      expirationDate = DateTime.now().add(Duration(minutes: expirationTime!));

      // Verificar que la fecha de expiración esté dentro de un rango razonable
      if (expirationDate!.isBefore(DateTime.now())) {
        showError(context, "La fecha de expiración no puede ser en el pasado.");
        _controllertiempo.clear();
        return '';
      }
      return _controller.text;
    }
    return _controller.text; // Si no es dinámico, solo usamos el texto ingresado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generar QR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo para el texto o URL
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Introduce el texto o URL para el QR',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Campo para el alias
            TextField(
              controller: _controllerAlias,
              decoration: InputDecoration(
                hintText: 'Introduce un alias para este QR',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Opción para QR dinámico
            Row(
              children: [
                Text("QR Dinámico: "),
                Checkbox(
                  value: isDynamic,
                  onChanged: (value) {
                    setState(() {
                      isDynamic = value!;
                    });
                  },
                ),
              ],
            ),

            // Campo para el tiempo de validez si es dinámico
            if (isDynamic)
              TextField(
                controller: _controllertiempo,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ingrese el tiempo de validez (minutos)',
                ),
                onChanged: (value) {
                  setState(() {
                    expirationTime = int.tryParse(value);
                  });
                },
              ),
            SizedBox(height: 20),

            // Botón para generar el QR
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Actualiza la interfaz después de cualquier cambio
              },
              child: Text('Generar QR'),
            ),
            SizedBox(height: 20),

            // Muestra el QR generado
            _controller.text.isEmpty
                ? Container()
                : QrImageView(
                    data: _generateDynamicQR(),
                    size: 200,
                  ),
            SizedBox(height: 20),

            // Botón para guardar el QR
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isEmpty ||
                    (isDynamic && int.tryParse(_controllertiempo.text) == null) ||
                    _controllerAlias.text.isEmpty) {
                  showError(context, 'Por favor, complete todos los campos.');
                } else {
                  _saveQR(_generateDynamicQR()); // Guardamos el QR
                }
              },
              child: Text('Guardar QR'),
            ),
          ],
        ),
      ),
    );
  }

  void showError(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
  }
}
