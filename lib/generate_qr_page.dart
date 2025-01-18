import 'package:finalpoo_turina/qr_storage.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'my_qrs_page.dart'; //para mostrar los QR guardados
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
  bool allowSpecificUsers = false;

  TextEditingController _controllerEmails = TextEditingController();


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
    if (newQR.url != ''){
    MyQRsPage.addGeneratedQR(newQR, _controllerEmails.text);
    // Imprimir en consola
    print("QR Guardado: ${newQR.toString()}");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyQRsPage(),
      ),
    );

    }
  }

  String _generateQR() {
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
      body: SingleChildScrollView(  // para desplazamiento
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo para el texto o URL
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Introduce URL para el QR',
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

                  // Limitar valor
      if (expirationTime != null && expirationTime! > 26280000000) {
        expirationTime = 26280000000; // Limita el valor
        _controllertiempo.text = expirationTime.toString(); // Actualiza el campo
        showError(context, "el limite son 50000 años");
      }

                },
              ),
            SizedBox(height: 20),

            



           Row(
              children: [
                Expanded(
                child : Text("Permitir acceso a usuarios específicos: "),
                ),
                Checkbox(
                  value: allowSpecificUsers,
                  onChanged: (value) {
                    setState(() {
                      allowSpecificUsers = value!;
                    });
                  },
                ),
              ],
            ),

            // Campo para ingresar correos electrónicos, visible solo si se habilita la opción anterior
            if (allowSpecificUsers)
  TextField(
    controller: _controllerEmails,
    maxLines: 3, // Configura el campo para que tenga hasta 3 líneas
    keyboardType: TextInputType.multiline, // Habilita la entrada de varias líneas
    decoration: InputDecoration(
      hintText: 'Introduce correos electrónicos separados por coma',
      border: OutlineInputBorder(),
    ),
  ),
            SizedBox(height: 20),







            // Botón para guardar el QR
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isEmpty ||
                    (isDynamic && int.tryParse(_controllertiempo.text) == null) ||
                    _controllerAlias.text.isEmpty || allowSpecificUsers && _controllerEmails.text.isEmpty) {
                  showError(context, 'Por favor, complete todos los campos.');
                } else {
                  _saveQR(_generateQR()); // Guardamos el QR
                }
              },
              child: Text('Guardar QR'),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void showError(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Atención"),
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
