class RouteTicket {
  final String startStation;
  final String destinationStation;
  final String startStationUID;
  final String destinationStationUID;
  final String companyName;
  final String companyUID;
  final String routeName;
  final String routeUID;
  final double ticketPrice;
  final int departureTime;
  int quantity;

  RouteTicket({
    required this.startStation,
    required this.destinationStation,
    required this.startStationUID,
    required this.destinationStationUID,
    required this.companyName,
    required this.companyUID,
    required this.routeName,
    required this.routeUID,
    required this.ticketPrice,
    required this.departureTime,
    required this.quantity,
  });
}
