import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  @override
  void initState() {
    // launchUrl(Uri.parse('https://bus4u.online/tickets'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(children: [
        Text(
          "List of tickets",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ]),
    );
  }
}
