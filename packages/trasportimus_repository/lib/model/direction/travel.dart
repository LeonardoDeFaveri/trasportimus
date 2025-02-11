import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:trasportimus_repository/model/model.dart';
import 'package:trentino_trasporti_api/model/model.dart' as m;

sealed class TravelMode implements Equatable {
  const TravelMode();

  @override
  bool? get stringify => true;
}

class Walking extends TravelMode {
  @override
  List<Object?> get props => [];
}

class Transit extends TravelMode {
  late final DateTime departureTime;
  late final DateTime arrivalTime;
  late final int numberOfStops;
  late final TransportType mode;
  late final TransitInfo info;

  Transit({
    required this.departureTime,
    required this.arrivalTime,
    required this.numberOfStops,
    required this.mode,
    required this.info,
  });

  @override
  List<Object?> get props =>
      [departureTime, arrivalTime, numberOfStops, mode, info];

  Transit.fromApiTransit(m.Transit transit, Trip? trip) {
    departureTime = transit.departureTime;
    arrivalTime = transit.arrivalTime;
    numberOfStops = transit.numberOfStops;
    mode = TTC.fromId(transit.mode.id);
    if (trip != null) {
      int start = 0, end = trip.stopTimes.length - 1;
      for (var st in trip.stopTimes) {
        if (st.stop.id == transit.departureStop.id ||
            st.stop.name == transit.departureStop.name) {
          start = st.stopSequence - 1;
        } else if (st.stop.id == transit.arrivalStop.id ||
            st.stop.name == transit.arrivalStop.name) {
          end = st.stopSequence - 1;
        }
      }
      info = RichInfo(trip, start, end);
    } else {
      info = PoorInfo(
          transit.tripId,
          transit.departureStop.name,
          transit.departureStop.location,
          transit.arrivalStop.name,
          transit.arrivalStop.location,
          transit.route.fullName,
          transit.route.shortName,
          transit.headsign,
          transit.route.color);
    }
  }
}

sealed class TransitInfo implements Equatable {
  const TransitInfo();

  String getDepartureStopName();
  LatLng getDepartureStopLoc();
  String getArrivalStopName();
  LatLng getArrivalStopLoc();
  String? getRouteFullName();
  String? getRouteShortName();
  String getRouteHeadSign();
  Color getRouteColor();

  @override
  bool? get stringify => true;
}

class RichInfo extends TransitInfo {
  final Trip trip;
  final int departureStopIndex;
  final int arrivalStopIndex;

  const RichInfo(
    this.trip,
    this.departureStopIndex,
    this.arrivalStopIndex,
  );

  @override
  LatLng getArrivalStopLoc() {
    var stop = trip.stopTimes[arrivalStopIndex].stop;
    return LatLng(stop.latitude, stop.longitude);
  }

  @override
  String getArrivalStopName() {
    return trip.stopTimes[arrivalStopIndex].stop.name;
  }

  @override
  LatLng getDepartureStopLoc() {
    var stop = trip.stopTimes[departureStopIndex].stop;
    return LatLng(stop.latitude, stop.longitude);
  }

  @override
  String getDepartureStopName() {
    return trip.stopTimes[departureStopIndex].stop.name;
  }

  @override
  Color getRouteColor() => trip.route.color;

  @override
  String? getRouteFullName() => trip.route.longName;

  @override
  String? getRouteShortName() => trip.route.shortName;

  @override
  String getRouteHeadSign() => trip.tripHeadSign;

  @override
  List<Object?> get props => [
        trip,
        departureStopIndex,
        arrivalStopIndex,
      ];
}

class PoorInfo extends TransitInfo {
  final String? tripId;
  final String departureStopName;
  final LatLng departureStopLoc;
  final String arrivalStopName;
  final LatLng arrivalStopLoc;
  final String? routeFullName;
  final String? routeShortName;
  final String headSign;
  final Color routeColor;

  const PoorInfo(
    this.tripId,
    this.departureStopName,
    this.departureStopLoc,
    this.arrivalStopName,
    this.arrivalStopLoc,
    this.routeFullName,
    this.routeShortName,
    this.headSign,
    this.routeColor,
  );

  @override
  LatLng getArrivalStopLoc() => arrivalStopLoc;

  @override
  String getArrivalStopName() => arrivalStopName;

  @override
  LatLng getDepartureStopLoc() => departureStopLoc;

  @override
  String getDepartureStopName() => departureStopName;

  @override
  Color getRouteColor() => routeColor;

  @override
  String? getRouteFullName() => routeFullName;

  @override
  String? getRouteShortName() => routeShortName;

  @override
  String getRouteHeadSign() => headSign;

  @override
  List<Object?> get props => [
        tripId,
        departureStopName,
        departureStopLoc,
        arrivalStopName,
        arrivalStopLoc,
        routeFullName,
        routeShortName,
        headSign,
        routeColor,
      ];
}
