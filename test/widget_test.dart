import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finalpoo_turina/generate_qr_page.dart'; // Asegúrate de que el path sea correcto
import 'package:finalpoo_turina/auth_service.dart'; // Asegúrate de que el path sea correcto

void main() {
  testWidgets('Test GenerateQRPage', (WidgetTester tester) async {
    // Crea el widget a probar
    await tester.pumpWidget(MaterialApp(
      home: GenerateQRPage(),
    ));

    // Verifica si el widget ha cargado correctamente
    expect(find.byType(GenerateQRPage), findsOneWidget);

    // Verifica si el campo de texto para URL existe
    expect(find.byType(TextField), findsNWidgets(2)); // Dos TextFields, uno para URL y otro para alias

    // Simula la interacción con los campos de texto
    await tester.enterText(find.byType(TextField).at(0), 'https://example.com');
    await tester.enterText(find.byType(TextField).at(1), 'Alias del QR');

    // Simula la activación de la opción de QR Dinámico
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pump();

    // Verifica si el campo para el tiempo de validez aparece cuando el QR es dinámico
    expect(find.byType(TextField), findsNWidgets(3)); // Ahora debe haber un tercer TextField para tiempo

    // Ingresa el tiempo de validez
    await tester.enterText(find.byType(TextField).at(2), '30');
    await tester.pump();

    // Simula la acción de presionar el botón para guardar el QR
    await tester.tap(find.text('Guardar QR'));
    await tester.pump();

    // Verifica si el mensaje de error aparece si faltan campos obligatorios
    expect(find.text('Por favor, complete todos los campos.'), findsOneWidget);

    // Asegúrate de probar con datos completos
    await tester.enterText(find.byType(TextField).at(1), 'Nuevo Alias');
    await tester.tap(find.text('Guardar QR'));
    await tester.pump();

    // Aquí podrías verificar si la función de guardado del QR se ejecutó correctamente
    // También puedes comprobar que la navegación o acciones posteriores ocurrieron como se espera
  });
}
