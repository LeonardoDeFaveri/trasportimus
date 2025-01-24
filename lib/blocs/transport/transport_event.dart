part of 'transport_bloc.dart';

@immutable
sealed class TransportEvent extends Equatable {
  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}

final class FetchAll extends TransportEvent {}

/// User requested the retrieval of all routes info.
final class FetchRoutes extends TransportEvent {
  final m.Area area;

  FetchRoutes(this.area);

  @override
  List<Object?> get props => [area];
}

final class FetchStops extends TransportEvent {}

final class FetchTripsForRoute extends TransportEvent {
  final m.Route route;
  final DateTime dateTime;
  final m.Direction direction;

  FetchTripsForRoute(this.route, this.dateTime, this.direction);

  @override
  List<Object?> get props => [route, dateTime, direction];
}

final class FetchTripsForStop extends TransportEvent {
  final m.Stop stop;
  final DateTime dateTime;

  FetchTripsForStop(this.stop, this.dateTime);

  @override
  List<Object?> get props => [stop, dateTime];
}

final class FetchTripDetails extends TransportEvent {
  final m.Trip trip;

  FetchTripDetails(this.trip);

  @override
  List<Object?> get props => [trip];
}

final class FetchDirectionInfo extends TransportEvent {
  final LatLng from;
  final LatLng to;
  final String? lang;

  FetchDirectionInfo(this.from, this.to, {this.lang});

  @override
  List<Object?> get props => [from, to, lang];
}
