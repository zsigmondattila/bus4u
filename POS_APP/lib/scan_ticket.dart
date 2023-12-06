import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
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
      scannedTicket = code.rawContent;
    });

    await sendscannedTicket(scannedTicket);
  }

  Future<void> sendscannedTicket(String ticketUid) async {
    final response = await http.post(
      Uri.parse('https://bus4u.fast-table.com/v1/admin/use_ticket'),
      body: {'ticket_uid': ticketUid},
    );

    print("RESPCODE ${response.statusCode}");
    if (response.statusCode == 202) {
      showStatusMessage('Have a nice trip!', 202);
    } else if (response.statusCode == 422) {
      showStatusMessage(
          'The scanned ticket is invalid, please try again!', 422);
    } else {
      showStatusMessage('API error, please try again', 404);
    }
  }

  void showStatusMessage(String message, int statusCode) {
    Color backgroundColor;

    if (statusCode == 202) {
      backgroundColor = const Color.fromARGB(255, 161, 255, 164);
    } else {
      backgroundColor = const Color.fromARGB(255, 255, 75, 62);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          backgroundColor: backgroundColor,
        );
      },
    );

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pop(context);

      scanQRCode();
    });
  }

  Future<void> sendscannedTicket(String ticketUid) async {
    final response = await http.post(
      Uri.parse('https://bus4u.fast-table.com/v1/admin/use_ticket'),
      body: {'ticket_uid': ticketUid},
    );

    if (response.statusCode == 200) {
      showStatusMessage('Have a nice trip!', 200);
    } else if (response.statusCode == 201) {
      showStatusMessage('The scanned ticket is invalid, please try again!', 201);
    } else {
      showStatusMessage('API error, please try again', 404);
    }
  }

 void showStatusMessage(String message, int statusCode) {
  Color backgroundColor;

  if (statusCode == 200) {
    backgroundColor = const Color.fromARGB(255, 161, 255, 164);
  }  else {
    backgroundColor = const Color.fromARGB(255, 255, 75, 62);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        backgroundColor: backgroundColor,
      );
    },
  );

  Future.delayed(Duration(seconds: 5), () {
    Navigator.pop(context);

    scanQRCode();
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
