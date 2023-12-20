import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'package:pos_app/main.dart';

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

    String token = await readData("token") ?? "";
    await sendscannedTicket(scannedTicket, token);
  }

  Future<void> sendscannedTicket(String ticketUid, String token) async {
    final response = await http.post(
      Uri.parse('https://bus4u.fast-table.com/v1/admin/use_ticket'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'ticket_uid': ticketUid},
    );
    print(response.body);

    print("RESPCODE ${response.statusCode}");
    if (response.statusCode == 202) {
      showStatusMessage(
          'Ticket successfully validated. Have a nice trip!', 202);
    } else if (response.statusCode == 422) {
      showStatusMessage(
          'The scanned ticket is invalid or expired. If you think this happened by mistake, please contact the driver.',
          422);
    } else {
      showStatusMessage('Server error, please contact the driver', 404);
    }
  }

  void showStatusMessage(String message, int statusCode) {
    Color backgroundColor;
    Color textColor;

    if (statusCode == 202) {
      backgroundColor = Color.fromARGB(255, 205, 252, 207);
      textColor = Colors.black; // Szövegszín a háttérszínhez illesztve
    } else {
      backgroundColor = Color.fromARGB(255, 255, 185, 180);
      textColor = const Color.fromARGB(
          255, 0, 0, 0); // Szövegszín a háttérszínhez illesztve
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: EdgeInsets.all(10.0), // Add padding on all sides
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 80.0,
                  child: Image(image: AssetImage('assets/pos.png')),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0, // Set font size to 20
                    ),
                    textAlign: TextAlign.center, // Center align the text
                  ),
                ),
              ],
            ),
          ),
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
