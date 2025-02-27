import 'dart:convert';
import 'package:bus4u/components/ticket_card.dart';
import 'package:bus4u/models/owned_ticket.dart';
import 'package:bus4u/pages/login_page.dart';
import 'package:bus4u/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  List<Ticket> tickets = [];
  bool isLoading = false;

  @override
  void initState() {
    getTickets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<UserService>(context).isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Please log in to see your tickets'),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage())),
                child: const Text('Log in'))
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          : Column(
              children: tickets.reversed
                  .map((ticket) => TicketCard(ticket: ticket))
                  .toList()),
    );
  }

  void getTickets() async {
    isLoading = true;
    var userData = context.read<UserService>();
    try {
      final response = await http.get(
          Uri.https('api.bus4u.online', '/v1/tickets_of_user',
              {'uid': userData.userUid ?? ''}),
          headers: {'Authorization': userData.token ?? ''});
      switch (response.statusCode) {
        case 200:
          setState(() {
            tickets = json
                .decode(response.body)
                .map<Ticket>((item) => Ticket.fromJson(item))
                .toList();
          });
          break;
        case 404:
          setState(() {
            tickets.clear();
          });
        default:
          debugPrint('Get tickets failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error during getTickets: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
