import 'package:bus4u/models/owned_ticket.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
  });

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 32.0),
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        Container(
            padding: const EdgeInsets.all(32.0),
            color: Colors.white,
            child: Center(child: QrImageView(data: ticket.ticketUID))),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    ticket.ticketUID,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text("Route: ${ticket.routeName}"),
                Text("From: ${ticket.startStation}"),
                Text("To: ${ticket.destinationStation}"),
                Text("Price: ${ticket.ticketPrice} lei"),
                Text(
                    "Purchased: ${ticket.createdAt?.year}. ${ticket.createdAt?.month}. ${ticket.createdAt?.day}"),
                Text(
                    "Valid until: ${ticket.validUntil?.year}. ${ticket.validUntil?.month}. ${ticket.validUntil?.day}"),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
