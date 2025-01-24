import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:trasportimus_repository/model/model.dart';
import 'package:trentino_trasporti_api/model/model.dart' as m;

class Step implements Equatable {
  late final LatLng startLocation;
  late final LatLng endLocation;
  late final TravelMode travelMode;
  late final int distance;
  late final Duration duration;

  Step({
    required this.startLocation,
    required this.endLocation,
    required this.travelMode,
    required this.distance,
    required this.duration,
  });

  @override
  List<Object?> get props => [
        startLocation,
        endLocation,
        travelMode,
        distance,
        duration,
      ];

  @override
  bool? get stringify => true;

  Step.fromApiStep(m.Step step, Trip? trip) {
    startLocation = step.startLocation;
    endLocation = step.endLocation;
    distance = step.distance;
    duration = step.duration;
    if (step.travelMode is m.Walking) {
      travelMode = Walking();
    } else {
      travelMode = Transit.fromApiTransit(step.travelMode as m.Transit, trip);
    }
  }
}
