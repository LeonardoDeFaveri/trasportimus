import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:trasportimus_repository/model/model.dart';
import 'package:trentino_trasporti_api/model/model.dart' as m;

/// Classed describing a trip of a transportation mean or a trip passing through
/// a stop.
class Trip implements Equatable {
  late final int tripIndex;
  late final String tripId;
  late final String tripFlag;
  late final String tripHeadSign;
  late final bool closestTripToRefDateTime;
  late final double delay;
  late final Direction direction;
  late final DateTime? lastUpdate;
  late final int lastSequenceDetection;
  late final int busSerialNumber;
  late final DateTime? effectiveArrivalTimeToSelectedStop;
  late final DateTime? programmedArrivalTimeToSelectedStop;
  late final Route route;
  late final Stop? lastStop;
  late final Stop? nextStop;
  late final List<StopTime> stopTimes;
  late final int totalAmountOfTrips;
  late final AreaType areaType;
  late final int wheelchairAccessible;

  Trip.fromApiTrip(
      m.Trip trip, HashMap<Key, Stop> stops, HashMap<Key, Route> routes) {
    AreaType at = ATC.fromId(trip.areaType.id);

    tripIndex = trip.tripIndex;
    tripId = trip.tripId;
    tripFlag = trip.tripFlag;
    tripHeadSign = trip.tripHeadSign;
    closestTripToRefDateTime = trip.closestTripToRefDateTime;
    delay = trip.delay;
    direction = DC.fromId(trip.direction.id ?? 2);
    lastUpdate = trip.lastUpdate;
    lastSequenceDetection = trip.lastSequenceDetection;
    busSerialNumber = trip.busSerialNumber;
    effectiveArrivalTimeToSelectedStop =
        trip.effectiveArrivalTimeToSelectedStop;
    programmedArrivalTimeToSelectedStop =
        trip.programmedArrivalTimeToSelectedStop;
    route = routes[Key(trip.routeId, at)]!;
    lastStop = stops[Key(trip.lastStopId, at)];
    nextStop = stops[Key(trip.nextStopId, at)];
    stopTimes = trip.stopTimes
        .map((stopTime) =>
            StopTime.fromApiStop(stopTime, stops[Key(stopTime.stopId, at)]!))
        .toList();
    totalAmountOfTrips = trip.totalAmountOfTrips;
    areaType = at;
    wheelchairAccessible = trip.wheelchairAccessible;
  }

  @override
  List<Object?> get props => [
        tripIndex,
        tripId,
        tripFlag,
        tripHeadSign,
        closestTripToRefDateTime,
        delay,
        direction,
        lastSequenceDetection,
        busSerialNumber,
        route,
        lastStop,
        nextStop,
        stopTimes,
        totalAmountOfTrips,
        areaType,
        wheelchairAccessible,
        effectiveArrivalTimeToSelectedStop,
        programmedArrivalTimeToSelectedStop
      ];

  @override
  bool? get stringify => true;
}
