import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trasportimus_repository/model/model.dart' as m;
import 'package:trasportimus_repository/trasportimus_repository.dart';
import 'package:equatable/equatable.dart';

part 'transport_event.dart';
part 'transport_state.dart';

class TransportBloc extends Bloc<TransportEvent, TransportState> {
  late final TrasportimusRepository repo;

  TransportBloc({TransportState? initial})
      : this.reuse(repo: TrasportimusRepository());

  TransportBloc.reuse({required this.repo, TransportState? initial})
      : super(initial ?? TransportInitial()) {
    on<FetchAll>((event, emit) async {
      emit(TransportStillFetching(event));
      List<m.Route>? routes;
      do {
        var result = await repo.getAllRoutes();
        switch (result.runtimeType) {
          case const (m.Ok<List<m.Route>>):
            routes = (result as m.Ok<List<m.Route>>).result;
            break;
          case const (m.Err<List<m.Route>>):
            var err = result as m.Err<List<m.Route>>;
            emit(TransportFetchFailed(event, err.errorType));
            return;
        }
      } while (routes == null);
      List<m.Stop>? stops;
      do {
        var result = await repo.getAllStops();
        switch (result.runtimeType) {
          case const (m.Ok<List<m.Route>>):
            stops = (result as m.Ok<List<m.Stop>>).result;
            break;
          case const (m.Err<List<m.Route>>):
            var err = result as m.Err<List<m.Stop>>;
            emit(TransportFetchFailed(event, err.errorType));
            return;
        }
      } while (stops == null);
      emit(TransportFetchedAll(routes, stops));
    });

    on<FetchRoutes>((event, emit) async {
      emit(TransportStillFetching(event));
      List<m.Route>? routes;
      do {
        var result = await repo.getRoutesForArea(event.area);
        switch (result.runtimeType) {
          case const (m.Ok<List<m.Route>>):
            routes = (result as m.Ok<List<m.Route>>).result;
            break;
          case const (m.Err<List<m.Route>>):
            var err = result as m.Err<List<m.Route>>;
            emit(TransportFetchFailed(event, err.errorType));
            return;
        }
      } while (routes == null);
      emit(TransportFetchedRoutes(routes));
    });

    on<FetchStops>((event, emit) async {
      emit(TransportStillFetching(event));
      List<m.Stop>? stops;
      do {
        var result = await repo.getAllStops();
        switch (result.runtimeType) {
          case const (m.Ok<List<m.Stop>>):
            stops = (result as m.Ok<List<m.Stop>>).result;
            break;
          case const (m.Err<List<m.Stop>>):
            var err = result as m.Err<List<m.Stop>>;
            emit(TransportFetchFailed(event, err.errorType));
            return;
        }
      } while (stops == null);
      emit(TransportFetchedStops(stops));
    });

    on<FetchTripsForRoute>((event, emit) async {
      emit(TransportStillFetching(event));
      List<m.Trip>? trips;
      do {
        var result = await repo.getTripsForRoute(event.route, event.dateTime,
            direction: event.direction);
        switch (result.runtimeType) {
          case const (m.Ok<List<m.Trip>>):
            trips = (result as m.Ok<List<m.Trip>>).result;
            break;
          case const (m.Err<List<m.Trip>>):
            var err = result as m.Err<List<m.Trip>>;
            emit(TransportFetchFailed(event, err.errorType));
            return;
        }
      } while (trips == null);
      emit(TransportFetchedTripsForRoute(
          trips, event.route, event.dateTime, event.direction));
    });

    on<FetchTripsForStop>((event, emit) async {
      emit(TransportStillFetching(event));
      List<m.Trip>? trips;
      do {
        var result = await repo.getTripsForStop(
          event.stop,
          event.dateTime,
        );
        switch (result.runtimeType) {
          case const (m.Ok<List<m.Trip>>):
            trips = (result as m.Ok<List<m.Trip>>).result;
            break;
          case const (m.Err<List<m.Trip>>):
            var err = result as m.Err<List<m.Trip>>;
            emit(TransportFetchFailed(event, err.errorType));
            return;
        }
      } while (trips == null);
      emit(TransportFetchedTripsForStop(
          trips, event.stop, event.dateTime, m.Direction.both));
    });

    on<FetchTripDetails>((event, emit) async {
      emit(TransportStillFetching(event));
      m.Trip? trip;
      do {
        var result = await repo.getTripDetails(
          event.trip.tripId,
        );
        switch (result.runtimeType) {
          case const (m.Ok<List<m.Trip>>):
            trip = (result as m.Ok<m.Trip>).result;
            break;
          case const (m.Err<List<m.Trip>>):
            var err = result as m.Err<m.Trip>;
            emit(TransportFetchFailed(event, err.errorType));
            return;
        }
      } while (trip == null);
      emit(TransportFetchedTripDetails(trip));
    });

    on<FetchDirectionInfo>((event, emit) async {
      emit(TransportStillFetching(event));
      m.DirectionInfo? info;
      do {
        var result = await repo.getDirectionInfo(
          event.from,
          event.to,
          lang: event.lang
        );
        switch (result.runtimeType) {
          case const (m.Ok<m.DirectionInfo>):
            info = (result as m.Ok<m.DirectionInfo>).result;
            break;
          case const (m.Err<m.DirectionInfo>):
            var err = result as m.Err<m.DirectionInfo>;
            emit(TransportFetchFailed(event, err.errorType));
            return;
        }
      } while (info == null);
      emit(TransportFetchedDirectionInfo(info));
    });
  }
}
