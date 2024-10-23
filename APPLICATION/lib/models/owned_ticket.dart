class Ticket {
  final String ticketUID;
  final String startStation;
  final String destinationStation;
  final String startStationUID;
  final String destinationStationUID;
  final String routeName;
  final String routeUID;
  final double ticketPrice;
  final DateTime? validUntil;
  final DateTime? createdAt;
  bool isValid;

  Ticket({
    required this.ticketUID,
    required this.startStation,
    required this.destinationStation,
    required this.startStationUID,
    required this.destinationStationUID,
    required this.routeName,
    required this.routeUID,
    required this.ticketPrice,
    required this.validUntil,
    required this.createdAt,
    this.isValid = true,
  });

  Ticket.fromJson(Map<String, dynamic> json)
      : ticketUID = json['ticket_uid'],
        startStation = json['from_station_name'],
        destinationStation = json['to_station_name'],
        startStationUID = json['from_station_uid'],
        destinationStationUID = json['to_station_uid'],
        routeName = json['route_name'],
        routeUID = json['route_uid'],
        ticketPrice = double.parse(json['ticket_price']) / 100,
        validUntil = DateTime.tryParse(json['expiration_date']),
        createdAt = DateTime.tryParse(json['date_of_purchase']),
        isValid = json['is_valid'];
}
