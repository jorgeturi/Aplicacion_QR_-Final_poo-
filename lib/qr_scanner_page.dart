import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'data_handle.dart';

class QrScannerPage extends StatefulWidget {
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String? result;
  String? lastResult;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanea tu código QR')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                if (barcode.rawValue != null && !isProcessing) {
                  final scannedValue = barcode.rawValue!;
                  if (scannedValue != lastResult) {
                    setState(() {
                      isProcessing = true;
                      result = scannedValue;
                      lastResult = scannedValue;
                    });
                    handleScanResult(context, result!);

                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        isProcessing = false;
                      });
                    });
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Código detectado: $result')
                  : Text('Apunta al código QR para escanear'),
            ),
          ),
        ],
      ),
    );
  }
}