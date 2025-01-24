import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:trasportimus_repository/model/direction/direction.dart';
import 'package:trasportimus_repository/model/trip.dart';
import 'package:trentino_trasporti_api/model/model.dart' as m;

class DirectionInfo implements Equatable {
  late final LatLng departurePoint;
  late final LatLng arrivalPoint;

  /// An arrays of the possible ways to go from the `departurePoint` to the
  /// `arrivalPoint`.
  late final List<Way> ways;

  DirectionInfo({
    required this.ways,
    required this.departurePoint,
    required this.arrivalPoint,
  });

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [departurePoint, arrivalPoint];

  DirectionInfo.fromApiDirectionInfo(
      m.DirectionInfo info, Map<int, List<Trip?>> trips) {
    ways = [];
    for (var e in info.ways.indexed) {
      List<Trip?> wayTrips = trips[e.$1]!;
      ways.add(Way.fromApiWay(e.$2, wayTrips));
    }
    departurePoint = info.departurePoint;
    arrivalPoint = info.arrivalPoint;
  }
}
