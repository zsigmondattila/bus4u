import 'package:flutter/material.dart';

class DepartureTimetable extends StatelessWidget {
  const DepartureTimetable({
    super.key,
    required this.departureTimes,
  });

  final List<Map<String, dynamic>> departureTimes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowMaxHeight: double.infinity,
        columnSpacing: 20,
        horizontalMargin: 0,
        columns: departureTimes
            .map((e) => DataColumn(label: Text(e['name'])))
            .toList(),
        rows: [
          DataRow(
            cells: departureTimes.map((time) {
              return DataCell(Column(
                mainAxisSize: MainAxisSize.min,
                children: time['departure_times']
                    .map<Widget>((value) => Text(value))
                    .toList(),
              ));
            }).toList(),
          ),
        ],
      ),
    );
  }
}
