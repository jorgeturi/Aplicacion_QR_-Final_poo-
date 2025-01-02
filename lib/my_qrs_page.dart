import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';

class MyQRsPage extends StatefulWidget {
  static List<String> generatedQRs = [];

  static void addGeneratedQR(String qrText) {
    generatedQRs.add(qrText);
    saveQRsToFile();
  }

  static Future<void> saveQRsToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/generated_qrs.txt');
    final text = generatedQRs.join('\n');
    await file.writeAsString(text);
  }

  static Future<void> loadQRsFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/generated_qrs.txt');
    if (await file.exists()) {
      final text = await file.readAsString();
      generatedQRs = text.split('\n');
    }
  }

  static Future<void> clearAllQRs() async {
    generatedQRs.clear();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/generated_qrs.txt');
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  _MyQRsPageState createState() => _MyQRsPageState();
}

class _MyQRsPageState extends State<MyQRsPage> {
  @override
  void initState() {
    super.initState();
    MyQRsPage.loadQRsFromFile().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis QR\'s'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              MyQRsPage.clearAllQRs().then((_) {
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: MyQRsPage.generatedQRs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showQR(MyQRsPage.generatedQRs[index]);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: ListTile(
                title: Text(MyQRsPage.generatedQRs[index]),
                tileColor: Colors.blue[50],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showQR(String qrText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR correspondiente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              height: 300,
              child: QrImageView(
                data: qrText,
                size: 300,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  MyQRsPage.generatedQRs.remove(qrText);
                  MyQRsPage.saveQRsToFile();
                });
                Navigator.of(context).pop();
              },
              child: Text('Eliminar este QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
