part of 'prefs_bloc.dart';

sealed class PrefsState extends Equatable {
  const PrefsState();

  @override
  List<Object> get props => [];
}

final class PrefsInitial extends PrefsState {}

final class PrefsLoading extends PrefsState {}

final class PrefsLoadedAll extends PrefsState {
  final HashSet<m.Route> routes;
  final HashSet<m.Stop> stops;

  const PrefsLoadedAll(this.routes, this.stops);

  @override
  List<Object> get props => [routes, stops];
}

final class PrefsLoadedRoutes extends PrefsState {
  final HashSet<m.Route> routes;

  const PrefsLoadedRoutes(this.routes);

  @override
  List<Object> get props => [routes];
}

final class PrefsLoadedStops extends PrefsState {
  final HashSet<m.Stop> stops;

  const PrefsLoadedStops(this.stops);

  @override
  List<Object> get props => [stops];
}

final class PrefsRoutesUpdated extends PrefsState {
  final HashSet<m.Route> routes;

  const PrefsRoutesUpdated(this.routes);

  @override
  List<Object> get props => [routes];
}

final class PrefsStopsUpdated extends PrefsState {
  final HashSet<m.Stop> stops;

  const PrefsStopsUpdated(this.stops);

  @override
  List<Object> get props => [stops];
}
