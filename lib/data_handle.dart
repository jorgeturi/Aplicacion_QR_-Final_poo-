import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void handleScanResult(BuildContext context, String scannedData) async {
  List<String> parts = scannedData.split('|');
  String url = parts[0];
  String information = parts.length > 1 ? parts[1] : '';

  if (parts.length > 1) {
    int timestamp = int.tryParse(information) ?? 0;
    bool isValidTimestamp = timestamp > DateTime.now().millisecondsSinceEpoch;

    if (!isValidTimestamp) {
      showError(context, "QR fuera del tiempo válido");
      return;
    }
  }

  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }

  Uri uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) {
    showError(context, "No se puede abrir la URL");
    return;
  }

  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

void showError(BuildContext context, String message) {
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
}