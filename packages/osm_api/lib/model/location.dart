import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:osm_api/model/address.dart';

part 'location.g.dart';

@JsonSerializable()
class Location extends Equatable {
  @JsonKey(name: 'osm_id')
  final int id;
  @JsonKey(name: 'lat')
  final double lat;
  @JsonKey(name: 'lon')
  final double lon;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'display_name')
  final String displayName;
  @JsonKey(name: 'address')
  final Address address;

  const Location({
    required this.id,
    required this.lat,
    required this.lon,
    required this.name,
    required this.displayName,
    required this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);

  @override
  List<Object?> get props => [id];
}
