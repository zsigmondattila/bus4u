import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;

class ScanTicket extends StatefulWidget {
  @override
  _ScanTicketState createState() => _ScanTicketState();
}

class _ScanTicketState extends State<ScanTicket> {
  String scannedTicket = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => scanQRCode());
  }

  Future<void> scanQRCode() async {
      final ScanResult code = await BarcodeScanner.scan();
      setState(() {
        scannedCode = code.rawContent;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scannedTicket,
            ),
          ],
        ),
      ),
    );
  }
}
