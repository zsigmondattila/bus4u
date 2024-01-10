import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            "About",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          SizedBox(height: 10),
          Text(
            "The project and the team",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          SizedBox(height: 25),
          Text(
            "One of the most environmentally friendly ways to travel is to choose public transport. The more people choose this form of travel, the cleaner environment we can live in, and the less congested the roads would be. Unfortunately, the choice of public transport also comes with many disadvantages."
            "  From the point of view of passengers, it is relatively difficult to choose the right bus for us, because it is not easy to find the timetables of the different companies anywhere. Even if we find this, there is still the possibility that the buses will be late, or worse, leave earlier."
            "  From the point of view of companies, it is often not easy to monitor the condition of the buses, the costs, and to keep track of the profit."
            "By creating this application, we offer solutions to all these problems.",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          SizedBox(height: 25),
          Text(
            "Bus4U team:",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          Text(
            "   Bodo Balint",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          Text(
            "   Portik Szabolcs",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          Text(
            "   Zsigmond Attila",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          SizedBox(height: 25),
          Text(
            "Sapientia EMTE 2023",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ]),
      ),
    );
  }
}
