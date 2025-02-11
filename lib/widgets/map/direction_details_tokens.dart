import 'dart:ui';

import 'package:latlong2/latlong.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

abstract class DirectionDetailsToken {
  const DirectionDetailsToken();
}

class StartLocation extends DirectionDetailsToken {
  final String name;
  final String address;
  final LatLng location;
  final DateTime time;
  final bool showWalking;
  final m.Stop? stop;

  const StartLocation(
      this.name, this.address, this.location, this.time, this.stop,
      {required this.showWalking});
}

class EndLocation extends DirectionDetailsToken {
  final String name;
  final String address;
  final LatLng location;
  final DateTime time;
  final bool showWalking;
  final m.Stop? stop;

  const EndLocation(
      this.name, this.address, this.location, this.time, this.stop,
      {required this.showWalking});
}

class WalkingInfo extends DirectionDetailsToken {
  final Duration duration;
  final int distance;
  final Duration? waitingTime;

  const WalkingInfo(this.duration, this.distance, this.waitingTime);
}

class Transferring extends DirectionDetailsToken {
  const Transferring();
}

class TransitStartLocation extends DirectionDetailsToken {
  final String name;
  final String address;
  final LatLng location;
  final m.TransportType mode;
  final bool showWalking;
  final m.Stop? stop;
  final m.TransitInfo transitInfo;

  const TransitStartLocation(this.name, this.address, this.location, this.mode,
      this.stop, this.transitInfo,
      {required this.showWalking});
}

class TransitRouteInfo extends DirectionDetailsToken {
  final String? shortName;
  final String? longName;
  final String headSign;
  final DateTime time;
  final Color color;
  final m.TransportType mode;
  final m.Trip? trip;

  const TransitRouteInfo(this.shortName, this.longName, this.headSign,
      this.time, this.color, this.mode, this.trip);
}

class TransitStopLocation extends DirectionDetailsToken {
  final String name;
  final String address;
  final LatLng location;
  final bool showWalking;
  final m.Stop? stop;
  final m.TransitInfo transitInfo;
  final DateTime arrivalTime;
  final Color color;

  const TransitStopLocation(this.name, this.address, this.location, this.stop,
      this.transitInfo, this.arrivalTime, this.color,
      {required this.showWalking});
}

class TransitIntermediateLocationHeader extends DirectionDetailsToken {
  final int quantity;
  final Duration duration;
  final bool isExpanded;
  final bool canExpand;
  final Color color;
  final int id;

  const TransitIntermediateLocationHeader(
    this.quantity,
    this.duration,
    this.isExpanded,
    this.canExpand,
    this.color,
    this.id
  );
}

class TransitIntermediateLocationSingle extends DirectionDetailsToken {
  final String name;
  final m.Stop? stop;
  final Color color;

  const TransitIntermediateLocationSingle(this.name, this.stop, this.color);
}
