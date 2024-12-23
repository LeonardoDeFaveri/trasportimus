import 'package:equatable/equatable.dart';
import 'package:osm_api/model/location.dart';
import 'package:trasportimus_repository/model/stop.dart';

abstract class HintType extends Equatable {
  const HintType();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}

final class YourPositionHint extends HintType {}

final class StopHint extends HintType {
  final Stop stop;

  const StopHint(this.stop);

  @override
  List<Object?> get props => [stop];
}

final class LocationHint extends HintType {
  final Location location;

  const LocationHint(this.location);

  @override
  List<Object?> get props => [location];
}
