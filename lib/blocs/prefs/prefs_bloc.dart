import 'dart:collection';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

part 'prefs_event.dart';
part 'prefs_state.dart';

class PrefsBloc extends Bloc<PrefsEvent, PrefsState> {
  SharedPreferencesWithCache prefs;

  PrefsBloc(this.prefs) : super(PrefsInitial()) {
    on<FetchAll>((event, emit) {
      emit(PrefsLoadedAll(_fetchRoutes(), _fetchStops()));
    });

    on<FetchRoutes>((event, emit) {
      emit(PrefsLoadedRoutes(_fetchRoutes()));
    });

    on<FetchStops>((event, emit) {
      emit(PrefsLoadedStops(_fetchStops()));
    });

    on<SaveRoutes>((event, emit) {
      _saveRoutes(event.routes);
      emit(PrefsRoutesUpdated(event.routes));
    });

    on<SaveStops>((event, emit) {
      _saveStops(event.stops);
      emit(PrefsStopsUpdated(event.stops));
    });

    on<RemoveRoute>((event, emit) {
      HashSet<m.Route> routes = _fetchRoutes();
      routes.removeWhere((r) => r.id == event.route.id);
      _saveRoutes(routes);
      emit(PrefsRoutesUpdated(routes));
    });

    on<AddRoute>((event, emit) {
      HashSet<m.Route> routes = _fetchRoutes();
      routes.add(event.route);
      _saveRoutes(routes);
      emit(PrefsRoutesUpdated(routes));
    });

    on<RemoveStop>((event, emit) {
      HashSet<m.Stop> stops = _fetchStops();
      stops.removeWhere((s) => s.id == event.stop.id);
      _saveStops(stops);
      emit(PrefsStopsUpdated(stops));
    });

    on<AddStop>((event, emit) {
      HashSet<m.Stop> stops = _fetchStops();
      stops.add(event.stop);
      _saveStops(stops);
      emit(PrefsStopsUpdated(stops));
    });

    on<GetLocale>((event, emit) {
      var locale = prefs.getString('locale');
      emit(PrefsLocaleRead(locale));
    });

    on<SetLocale>((event, emit) {
      prefs.setString('locale', event.locale);
      emit(PrefsLocaleUpdated(event.locale));
    });
  }

  HashSet<m.Route> _fetchRoutes() {
    HashSet<m.Route> routes = HashSet(
      equals: (p0, p1) => p0.id == p1.id,
      hashCode: (p0) => p0.id,
    );
    var rawRoutes = prefs.getStringList('routes') ?? [];
    for (var rawRoute in rawRoutes) {
      routes.add(m.Route.fromJson(json.decode(rawRoute)));
    }
    return routes;
  }

  HashSet<m.Stop> _fetchStops() {
    HashSet<m.Stop> stops = HashSet(
      equals: (p0, p1) => p0.id == p1.id,
      hashCode: (p0) => p0.id,
    );
    var rawStops = prefs.getStringList('stops') ?? [];
    for (var rawStop in rawStops) {
      stops.add(m.Stop.fromJson(jsonDecode(rawStop)));
    }
    return stops;
  }

  void _saveRoutes(HashSet<m.Route> routes) {
    prefs.setStringList(
        'routes', routes.map((r) => json.encode(r.toJson())).toList());
  }

  void _saveStops(HashSet<m.Stop> stops) {
    prefs.setStringList(
        'stops', stops.map((s) => json.encode(s.toJson())).toList());
  }
}
