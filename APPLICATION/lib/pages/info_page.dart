import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(children: [
        Text(
          "About",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        Text(
          "The project and the team",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        SizedBox(height: 30),
        Text(
          "One of the most environmentally friendly ways to travel is to choose public transport. The more people choose this form of travel, the cleaner environment we can live in, and the less congested the roads would be. Unfortunately, the choice of public transport also comes with many disadvantages."
          "  From the point of view of passengers, it is relatively difficult to choose the right bus for us, because it is not easy to find the timetables of the different companies anywhere. Even if we find this, there is still the possibility that the buses will be late, or worse, leave earlier."
          "  From the point of view of companies, it is often not easy to monitor the condition of the buses, the costs, and to keep track of the profit."
          "By creating this application, we offer solutions to all these problems.",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        SizedBox(height: 30),
        Text(
          "Bus4U team",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        Text(
          "  Bodo Balint"
          "  Portik Szabolcs"
          "  Zsigmond Attila",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        SizedBox(height: 30),
        Text(
          "Sapientia EMTE 2023",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ]),
    );
  }
}
