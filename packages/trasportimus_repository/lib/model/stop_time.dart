import 'package:equatable/equatable.dart';
import 'package:trasportimus_repository/model/model.dart';
import 'package:trentino_trasporti_api/model/model.dart' as m;

class StopTime implements Equatable {
  late final DateTime arrivalTime;
  late final DateTime departureTime;
  late final Stop stop;
  late final int stopSequence;
  late final String tripId;
  late final AreaType areaType;

  StopTime.fromApiStop(m.StopTime stopTime, this.stop) {
    arrivalTime = stopTime.arrivalTime;
    departureTime = stopTime.departureTime;
    stopSequence = stopTime.stopSequence;
    tripId = stopTime.tripId;
    areaType = ATC.fromId(stopTime.areaType.id);
  }

  @override
  List<Object?> get props =>
      [arrivalTime, departureTime, stop, stopSequence, tripId, areaType];

  @override
  bool? get stringify => true;
}
