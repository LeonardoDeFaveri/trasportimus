import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trasportimus_repository/model/model.dart';
import 'package:trentino_trasporti_api/model/model.dart' as m;

part 'stop.g.dart';

@JsonSerializable()
class Stop implements Equatable {
  late final double? distance;
  late final List<Route> routes;
  late final String code;
  late final String name;
  late final String description;
  late final int id;
  late final double latitude;
  late final double longitude;
  late final int level;
  late final String street;
  late final String town;
  late final AreaType areaType;
  late final int wheelchairBoarding;

  Stop(
      {required this.routes,
      required this.code,
      required this.name,
      required this.description,
      required this.id,
      required this.latitude,
      required this.longitude,
      required this.level,
      required this.street,
      required this.town,
      required this.areaType,
      required this.wheelchairBoarding,
      this.distance});

  factory Stop.fromJson(Map<String, dynamic> json) => _$StopFromJson(json);
  Map<String, dynamic> toJson() => _$StopToJson(this);

  Stop.fromApiStop(m.Stop stop) {
    distance = stop.distance;
    routes = stop.routes.map((route) => Route.fromApiRoute(route)).toList();
    code = stop.code;
    name = stop.name;
    description = stop.description;
    id = stop.id;
    latitude = stop.latitude;
    longitude = stop.longitude;
    level = stop.level;
    street = stop.street;
    town = stop.town;
    areaType = ATC.fromId(stop.areaType.id);
    wheelchairBoarding = stop.wheelchairBoarding;
  }

  @override
  List<Object?> get props => [
        routes,
        code,
        name,
        description,
        id,
        latitude,
        longitude,
        level,
        street,
        town,
        areaType,
        wheelchairBoarding,
        distance
      ];

  @override
  bool? get stringify => true;
}
