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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
        
        Text(
          "Info",
          style: TextStyle(color: Colors.black, fontSize: 20),
          
        ),
        SizedBox(height: 25),
        Text(
          "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxxxxxxxxxxxXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        SizedBox(height: 350),
        Text(
          "Email: xxxxxxxxxx@xxxxx.xxx",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        Text(
          "Tel: 0000000000",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        SizedBox(height: 25),
        Text(
          "Created by: Bodo Balint, Portik Szabolcs, Zsigmond Attila",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        Text(
          "Sapientia EMTE 2023",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ]),
    );
  }
}
