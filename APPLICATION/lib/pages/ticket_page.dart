import 'package:flutter/material.dart';


class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
  
}

class _TicketPageState extends State<TicketPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(children: [
          Text(
            "Tickettt",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          
          SizedBox(height: 30),
          Text(
            "More ticket",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ]),
      ),
    );
  }
}