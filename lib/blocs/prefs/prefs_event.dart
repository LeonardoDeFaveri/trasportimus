part of 'prefs_bloc.dart';

sealed class PrefsEvent extends Equatable {
  const PrefsEvent();

  @override
  List<Object> get props => [];
}

final class FetchAll extends PrefsEvent {}

final class FetchRoutes extends PrefsEvent {}

final class FetchStops extends PrefsEvent {}

final class SaveRoutes extends PrefsEvent {
  final HashSet<m.Route> routes;

  const SaveRoutes(this.routes);

  @override
  List<Object> get props => [routes];
}

final class SaveStops extends PrefsEvent {
  final HashSet<m.Stop> stops;

  const SaveStops(this.stops);

  @override
  List<Object> get props => [stops];
}

final class RemoveRoute extends PrefsEvent {
  final m.Route route;

  const RemoveRoute(this.route);

  @override
  List<Object> get props => [route];
}

final class AddRoute extends PrefsEvent {
  final m.Route route;

  const AddRoute(this.route);

  @override
  List<Object> get props => [route];
}

final class RemoveStop extends PrefsEvent {
  final m.Stop stop;

  const RemoveStop(this.stop);

  @override
  List<Object> get props => [stop];
}

final class AddStop extends PrefsEvent {
  final m.Stop stop;

  const AddStop(this.stop);

  @override
  List<Object> get props => [stop];
}

final class GetLocale extends PrefsEvent {
  const GetLocale();

  @override
  List<Object> get props => [];
}

final class SetLocale extends PrefsEvent {
  final String locale;

  const SetLocale(this.locale);

  @override
  List<Object> get props => [locale];
}
