import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:trasportimus_repository/model/model.dart';
import 'package:trentino_trasporti_api/model/direction/way.dart' as m;

class Way implements Equatable {
  late final LatLng departurePointCoords;
  late final String departurePointName;
  late final LatLng arrivalPointCoords;
  late final String arrivalPointName;
  late final Bounds bounds;
  late final DateTime? departureTime;
  late final DateTime? arrivalTime;
  late final Duration duration;
  late final String polyline;

  /// Distance in meters covered by this way
  late final int distance;
  late final List<Step> steps;

  Way({
    required this.departurePointCoords,
    required this.departurePointName,
    required this.arrivalPointCoords,
    required this.arrivalPointName,
    required this.bounds,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.distance,
    required this.steps,
    required this.polyline,
  });

  @override
  List<Object?> get props => [
        departurePointCoords,
        departurePointName,
        arrivalPointCoords,
        arrivalPointName,
        departureTime,
        arrivalTime,
        duration,
        polyline
      ];

  @override
  bool? get stringify => true;

  Way.fromApiWay(m.Way way, List<Trip?> trips) {
    distance = way.distance;
    duration = way.duration;
    departurePointCoords = way.departurePointCoords;
    departurePointName = way.departurePointName;
    arrivalPointCoords = way.arrivalPointCoords;
    arrivalPointName = way.arrivalPointName;
    departureTime = way.departureTime;
    arrivalTime = way.arrivalTime;
    steps = [];
    for (var e in way.steps.indexed) {
      steps.add(Step.fromApiStep(e.$2, trips[e.$1]));
    }
    bounds = Bounds(
      northEast: way.bounds.northEast,
      southWest: way.bounds.southWest,
    );
    polyline = way.polyline;
  }
}
