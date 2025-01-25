library trasportimus_repository;

import 'dart:collection';

import 'package:latlong2/latlong.dart';
import 'package:trasportimus_repository/model/model.dart';
import 'package:trentino_trasporti_api/trentino_trasporti_api.dart';
import 'package:trentino_trasporti_api/model/model.dart' as m;

class TrasportimusRepository {
  final TrentinoTrasportiApiClient _client;
  final int _retryFor;
  HashMap<Key, Stop>? _stops;
  HashMap<Key, Route>? _routes;

  TrasportimusRepository({int? retryFor})
      : _client = TrentinoTrasportiApiClient(),
        _retryFor = retryFor ?? 0;

  /// Retrieves all the routes available.
  Future<Result<List<Route>>> getAllRoutes(
      {int? retryFor, bool? forceRefresh}) async {
    Result<List<Route>> repoResult;

    if (_routes != null && !(forceRefresh ?? false)) {
      return Ok(_routes!.values.toList());
    }

    ApiResult<List<m.Route>> apiResult =
        await _fetchRoutesUntil(retryFor ?? _retryFor);

    switch (apiResult.runtimeType) {
      case const (ApiOk<List<m.Route>>):
        List<m.Route> result = (apiResult as ApiOk<List<m.Route>>).result;
        var routes = result.map((route) => Route.fromApiRoute(route));
        _routes = HashMap.fromIterable(
          routes,
          key: (route) => Key(route.id, route.areaType),
          value: (route) => route,
        );
        repoResult = Ok(routes.toList());
      default:
        ApiErr<List<m.Route>> err = apiResult as ApiErr<List<m.Route>>;
        if (err.mayRetry) {
          repoResult = Err(ErrorType.tryAgain);
        } else {
          repoResult = Err(ErrorType.serviceunreachable);
        }
    }

    return repoResult;
  }

  /// Gets all routes for `area`.
  Future<Result<List<Route>>> getRoutesForArea(Area area,
      {int? retryFor}) async {
    Result<List<Route>> result = await getAllRoutes(retryFor: retryFor);
    if (result is Err) return result;
    List<Route> routes = (result as Ok<List<Route>>).result;
    routes.removeWhere((route) => route.area != area);
    return Ok(routes);
  }

  /// Returns all stops available.
  Future<Result<List<Stop>>> getAllStops(
      {int? retryFor, bool? forceRefresh}) async {
    if (_stops != null && !(forceRefresh ?? false)) {
      return Ok(_stops!.values.toList());
    }

    Result<List<Stop>> repoResult;
    ApiResult<List<m.Stop>> apiResult =
        await _fetchStopsUntil(retryFor ?? _retryFor);

    switch (apiResult.runtimeType) {
      case const (ApiOk<List<m.Stop>>):
        List<m.Stop> result = (apiResult as ApiOk<List<m.Stop>>).result;
        var stops = result.map((stop) => Stop.fromApiStop(stop));
        _stops = HashMap.fromIterable(
          stops,
          key: (stop) => Key(stop.id, stop.areaType),
          value: (stop) => stop,
        );
        repoResult = Ok(stops.toList());
      default:
        ApiErr<List<m.Stop>> err = apiResult as ApiErr<List<m.Stop>>;
        if (err.mayRetry) {
          repoResult = Err(ErrorType.tryAgain);
        } else {
          repoResult = Err(ErrorType.serviceunreachable);
        }
    }

    return repoResult;
  }

  /// Returns all trips associated to a route.
  Future<Result<List<Trip>>> getTripsForRoute(Route route, DateTime dateTime,
      {Direction? direction,
      int? limit,
      int? retryFor,
      bool? forceRefresh}) async {
    Result<List<Trip>> repoResult;

    // Fills local stop map
    if (_stops == null || forceRefresh == true) {
      Result<List<Stop>> res = await getAllStops(forceRefresh: forceRefresh);
      if (res is Err<List<Stop>>) {
        repoResult = Err<List<Trip>>(res.errorType);
        return repoResult;
      }
    }

    if (_routes == null || forceRefresh == true) {
      Result<List<Route>> res = await getAllRoutes(forceRefresh: forceRefresh);
      if (res is Err<List<Route>>) {
        repoResult = Err<List<Trip>>(res.errorType);
        return repoResult;
      }
    }

    ApiResult<List<m.Trip>> apiResult = await _fetchTripsForRouteUntil(
      route.id,
      route.areaType,
      direction ?? Direction.both,
      limit ?? 5,
      dateTime,
      retryFor ?? _retryFor,
    );

    switch (apiResult.runtimeType) {
      case const (ApiOk<List<m.Trip>>):
        List<m.Trip> result = (apiResult as ApiOk<List<m.Trip>>).result;
        repoResult = Ok(result
            .map((trip) => Trip.fromApiTrip(trip, _stops!, _routes!))
            .toList());
      default:
        ApiErr<List<m.Trip>> err = apiResult as ApiErr<List<m.Trip>>;
        if (err.mayRetry) {
          repoResult = Err(ErrorType.tryAgain);
        } else {
          repoResult = Err(ErrorType.serviceunreachable);
        }
    }
    return repoResult;
  }

  /// Returns all trips associated to a stop
  Future<Result<List<Trip>>> getTripsForStop(Stop stop, DateTime dateTime,
      {int? limit, int? retryFor, bool? forceRefresh}) async {
    Result<List<Trip>> repoResult;

    // Fills local stop map
    if (_stops == null || forceRefresh == true) {
      Result<List<Stop>> res = await getAllStops(forceRefresh: forceRefresh);
      if (res is Err<List<Stop>>) {
        repoResult = Err<List<Trip>>(res.errorType);
        return repoResult;
      }
    }

    // Fills local route map
    if (_routes == null || forceRefresh == true) {
      Result<List<Route>> res = await getAllRoutes(forceRefresh: forceRefresh);
      if (res is Err<List<Route>>) {
        repoResult = Err<List<Trip>>(res.errorType);
        return repoResult;
      }
    }

    ApiResult<List<m.Trip>> apiResult = await _fetchTripsForStopUntil(
      stop.id,
      stop.areaType,
      limit ?? 30,
      dateTime,
      retryFor ?? _retryFor,
    );

    switch (apiResult.runtimeType) {
      case const (ApiOk<List<m.Trip>>):
        List<m.Trip> result = (apiResult as ApiOk<List<m.Trip>>).result;
        repoResult = Ok(result
            .map((trip) => Trip.fromApiTrip(trip, _stops!, _routes!))
            .toList());
      default:
        ApiErr<List<m.Trip>> err = apiResult as ApiErr<List<m.Trip>>;
        if (err.mayRetry) {
          repoResult = Err(ErrorType.tryAgain);
        } else {
          repoResult = Err(ErrorType.serviceunreachable);
        }
    }
    return repoResult;
  }

  Future<Result<Trip>> getTripDetails(String tripId,
      {int? retryFor, bool? forceRefresh}) async {
    Result<Trip> repoResult;

    // Fills local stop map
    if (_stops == null || forceRefresh == true) {
      Result<List<Stop>> res = await getAllStops(forceRefresh: forceRefresh);
      if (res is Err<List<Stop>>) {
        repoResult = Err<Trip>(res.errorType);
        return repoResult;
      }
    }

    // Fills local route map
    if (_routes == null || forceRefresh == true) {
      Result<List<Route>> res = await getAllRoutes(forceRefresh: forceRefresh);
      if (res is Err<List<Route>>) {
        repoResult = Err<Trip>(res.errorType);
        return repoResult;
      }
    }

    ApiResult<m.Trip> apiResult = await _fetchTripDetailsUntil(
      tripId,
      retryFor ?? _retryFor,
    );

    switch (apiResult.runtimeType) {
      case const (ApiOk<m.Trip>):
        m.Trip result = (apiResult as ApiOk<m.Trip>).result;
        repoResult = Ok(Trip.fromApiTrip(result, _stops!, _routes!));
      default:
        ApiErr<m.Trip> err = apiResult as ApiErr<m.Trip>;
        if (err.mayRetry) {
          repoResult = Err(ErrorType.tryAgain);
        } else {
          repoResult = Err(ErrorType.serviceunreachable);
        }
    }
    return repoResult;
  }

  Future<Result<DirectionInfo>> getDirectionInfo(
      LatLng from, LatLng to, DateTime refDateTime,
      {String? lang, int? retryFor}) async {
    Result<DirectionInfo> repoResult;

    ApiResult<m.DirectionInfo> apiResult = await _fetchDirectionInfoUntil(
      from,
      to,
      refDateTime,
      lang ?? 'it',
      retryFor ?? _retryFor,
    );

    switch (apiResult.runtimeType) {
      case const (ApiOk<m.DirectionInfo>):
        m.DirectionInfo result = (apiResult as ApiOk<m.DirectionInfo>).result;
        Map<int, List<Trip?>> trips = {};
        for (var e in result.ways.indexed) {
          List<Trip?> wayTrips = [];
          for (var step in e.$2.steps) {
            if (step.travelMode is m.Transit) {
              var mode = step.travelMode as m.Transit;
              if (mode.tripId != null) {
                var trip = await getTripDetails(mode.tripId!);
                if (trip is Ok<Trip>) {
                  wayTrips.add(trip.result);
                } else {
                  wayTrips.add(null);
                }
              } else {
                wayTrips.add(null);
              }
            } else {
              wayTrips.add(null);
            }
          }
          trips[e.$1] = wayTrips;
        }
        repoResult = Ok(DirectionInfo.fromApiDirectionInfo(result, trips));
      default:
        ApiErr<m.DirectionInfo> err = apiResult as ApiErr<m.DirectionInfo>;
        if (err.mayRetry) {
          repoResult = Err(ErrorType.tryAgain);
        } else {
          repoResult = Err(ErrorType.serviceunreachable);
        }
    }
    return repoResult;
  }

  /// Auxiliary function that fetches routes until definitive success or failure
  /// or up tu `retryFor` times.
  Future<ApiResult<List<m.Route>>> _fetchRoutesUntil(int retryFor) async {
    ApiResult<List<m.Route>> result;
    do {
      result = await _client.getRoutes();
      switch (result.runtimeType) {
        case const (ApiOk<List<m.Route>>):
          retryFor = 0;
        case const (ApiErr<List<m.Route>>):
          var err = result as ApiErr<List<m.Route>>;
          if (err.mayRetry) {
            retryFor--;
          } else {
            retryFor = 0;
          }
      }
    } while (retryFor > 0);
    return result;
  }

  /// Auxiliary function that fetches stop until definitive success or failure
  /// or up tu `retryFor` times.
  Future<ApiResult<List<m.Stop>>> _fetchStopsUntil(int retryFor) async {
    ApiResult<List<m.Stop>> result;
    do {
      result = await _client.getStops();
      switch (result.runtimeType) {
        case const (ApiOk<List<m.Stop>>):
          retryFor = 0;
        case const (ApiErr<List<m.Stop>>):
          var err = result as ApiErr<List<m.Stop>>;
          if (err.mayRetry) {
            retryFor--;
          } else {
            retryFor = 0;
          }
      }
    } while (retryFor > 0);
    return result;
  }

  Future<ApiResult<List<m.Trip>>> _fetchTripsForRouteUntil(
      int routeId,
      AreaType areaType,
      Direction direction,
      int limit,
      DateTime dateTime,
      int retryFor) async {
    ApiResult<List<m.Trip>> result;
    do {
      result = await _client.getTripsForRoute(
        routeId,
        m.AId.fromId(areaType.id),
        m.DId.fromId(direction.id),
        limit,
        dateTime,
      );
      switch (result.runtimeType) {
        case const (ApiOk<List<m.Trip>>):
          retryFor = 0;
        case const (ApiErr<List<m.Trip>>):
          var err = result as ApiErr<List<m.Trip>>;
          if (err.mayRetry) {
            retryFor--;
          } else {
            retryFor = 0;
          }
      }
    } while (retryFor > 0);
    return result;
  }

  Future<ApiResult<List<m.Trip>>> _fetchTripsForStopUntil(int stopId,
      AreaType areaType, int limit, DateTime dateTime, int retryFor) async {
    ApiResult<List<m.Trip>> result;
    do {
      result = await _client.getTripsForStop(
        stopId,
        m.AId.fromId(areaType.id),
        limit,
        dateTime,
      );
      switch (result.runtimeType) {
        case const (ApiOk<List<m.Trip>>):
          retryFor = 0;
        case const (ApiErr<List<m.Trip>>):
          var err = result as ApiErr<List<m.Trip>>;
          if (err.mayRetry) {
            retryFor--;
          } else {
            retryFor = 0;
          }
      }
    } while (retryFor > 0);
    return result;
  }

  Future<ApiResult<m.Trip>> _fetchTripDetailsUntil(
      String tripId, int retryFor) async {
    ApiResult<m.Trip> result;
    do {
      result = await _client.getTripDetails(tripId);
      switch (result.runtimeType) {
        case const (ApiOk<m.Trip>):
          retryFor = 0;
        case const (ApiErr<m.Trip>):
          var err = result as ApiErr<m.Trip>;
          if (err.mayRetry) {
            retryFor--;
          } else {
            retryFor = 0;
          }
      }
    } while (retryFor > 0);
    return result;
  }

  Future<ApiResult<m.DirectionInfo>> _fetchDirectionInfoUntil(LatLng from,
      LatLng to, DateTime refDateTime, String lang, int retryFor) async {
    ApiResult<m.DirectionInfo> result;
    do {
      result =
          await _client.getDirectionInfo(from, to, refDateTime, lang: lang);
      switch (result.runtimeType) {
        case const (ApiOk<m.DirectionInfo>):
          retryFor = 0;
        case const (ApiErr<m.DirectionInfo>):
          var err = result as ApiErr<m.DirectionInfo>;
          if (err.mayRetry) {
            retryFor--;
          } else {
            retryFor = 0;
          }
      }
    } while (retryFor > 0);
    return result;
  }
}
