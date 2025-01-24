part of 'transport_bloc.dart';

@immutable
sealed class TransportState implements Equatable {
  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [];
}

final class TransportInitial extends TransportState {
  final List<m.Route> routes;
  final List<m.Stop> stops;

  TransportInitial()
      : routes = List.empty(),
        stops = List.empty();

  @override
  List<Object?> get props => [routes, stops];
}

final class TransportFetchedAll extends TransportState {
  final List<m.Route> routes;
  final List<m.Stop> stops;

  TransportFetchedAll(this.routes, this.stops);

  @override
  List<Object?> get props => [routes, stops];
}

final class TransportFetchedRoutes extends TransportState {
  final List<m.Route> routes;

  TransportFetchedRoutes(this.routes);

  @override
  List<Object?> get props => [routes];
}

final class TransportFetchedStops extends TransportState {
  final List<m.Stop> stops;

  TransportFetchedStops(this.stops);

  @override
  List<Object?> get props => [stops];
}

final class TransportFetchedTripsForRoute extends TransportState {
  final List<m.Trip> trips;
  final DateTime refTime;
  final m.Direction direction;
  final m.Route route;

  TransportFetchedTripsForRoute(
      this.trips, this.route, this.refTime, this.direction);

  @override
  List<Object?> get props => [trips, route, refTime, direction];
}

final class TransportFetchedTripsForStop extends TransportState {
  final List<m.Trip> trips;
  final DateTime refTime;
  final m.Direction direction;
  final m.Stop stop;

  TransportFetchedTripsForStop(
      this.trips, this.stop, this.refTime, this.direction);

  @override
  List<Object?> get props => [trips, stop, refTime, direction];
}

final class TransportFetchedTripDetails extends TransportState {
  final m.Trip trip;

  TransportFetchedTripDetails(this.trip);

  @override
  List<Object?> get props => [trip];
}

final class TransportFetchedDirectionInfo extends TransportState {
  final m.DirectionInfo directionInfo;

  TransportFetchedDirectionInfo(this.directionInfo);

  @override
  List<Object?> get props => [directionInfo];
}

final class TransportStillFetching extends TransportState {
  final TransportEvent event;

  TransportStillFetching(this.event);

  @override
  List<Object?> get props => [event];  
}

final class TransportFetchFailed extends TransportState {
  final TransportEvent event;
  final m.ErrorType type;

  TransportFetchFailed(this.event, this.type);

  @override
  List<Object?> get props => [type];
}
