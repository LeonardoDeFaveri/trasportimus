import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:trentino_trasporti_api/model/direction/utils.dart';

/// A rectangle in geographical coordinates from points at the southwest and
/// northeast corners. Useful for instructing the camera controller of the map
/// viewer.
class Bounds implements Equatable {
  @JsonKey(name: 'northeast', fromJson: readLatLng)
  final LatLng northEast;
  @JsonKey(name: 'southwest', fromJson: readLatLng)
  final LatLng southWest;

  const Bounds({required this.northEast, required this.southWest});

  @override
  List<Object?> get props => [northEast, southWest];

  @override
  bool? get stringify => true;
}
